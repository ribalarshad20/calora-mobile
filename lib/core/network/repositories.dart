import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../models/models.dart';
import 'api_client.dart';

final caloraRepositoryProvider = Provider((ref) => CaloraRepository(ref.watch(apiClientProvider)));

String todayKey() => DateFormat('yyyy-MM-dd').format(DateTime.now());

class CaloraRepository {
  CaloraRepository(this._api);

  final ApiClient _api;

  Future<AuthUser> register({
    required String email,
    required String password,
    required String name,
    String? inviteCode,
  }) async {
    final res = await _api.dio.post('/v1/auth/register', data: {
      'email': email,
      'password': password,
      'name': name,
      if (inviteCode != null && inviteCode.isNotEmpty) 'inviteCode': inviteCode,
      'deviceLabel': 'android',
    });
    final data = res.data['data'] as Map<String, dynamic>;
    await _api.saveTokens(
      accessToken: data['accessToken'] as String,
      refreshToken: data['refreshToken'] as String,
    );
    return AuthUser.fromJson(data['user'] as Map<String, dynamic>);
  }

  Future<AuthUser> login({required String email, required String password}) async {
    final res = await _api.dio.post('/v1/auth/login', data: {
      'email': email,
      'password': password,
      'deviceLabel': 'android',
    });
    final data = res.data['data'] as Map<String, dynamic>;
    await _api.saveTokens(
      accessToken: data['accessToken'] as String,
      refreshToken: data['refreshToken'] as String,
    );
    return AuthUser.fromJson(data['user'] as Map<String, dynamic>);
  }

  Future<void> logout() async {
    final refresh = await _api.readRefreshToken();
    if (refresh != null) {
      try {
        await _api.dio.post('/v1/auth/logout', data: {'refreshToken': refresh});
      } catch (_) {}
    }
    await _api.clearTokens();
  }

  Future<Map<String, dynamic>> me() async {
    final res = await _api.dio.get('/v1/users/me');
    return res.data['data'] as Map<String, dynamic>;
  }

  Future<Profile> upsertProfile(Map<String, dynamic> body) async {
    final res = await _api.dio.put('/v1/profile/me', data: body);
    return Profile.fromJson(res.data['data'] as Map<String, dynamic>);
  }

  Future<Profile> getProfile() async {
    final res = await _api.dio.get('/v1/profile/me');
    return Profile.fromJson(res.data['data'] as Map<String, dynamic>);
  }

  Future<void> setTheme(String theme) async {
    await _api.dio.patch('/v1/profile/theme', data: {'theme': theme});
  }

  Future<({DaySummary summary, List<DiaryEntry> entries})> day(String date) async {
    final res = await _api.dio.get('/v1/diary/day/$date');
    final data = res.data['data'] as Map<String, dynamic>;
    final summary = DaySummary.fromJson(data['summary'] as Map<String, dynamic>);
    final entries = (data['entries'] as List)
        .map((e) => DiaryEntry.fromJson(e as Map<String, dynamic>))
        .toList();
    return (summary: summary, entries: entries);
  }

  Future<DiaryEntry> addEntry(Map<String, dynamic> body) async {
    final res = await _api.dio.post('/v1/diary/entries', data: body);
    return DiaryEntry.fromJson(res.data['data'] as Map<String, dynamic>);
  }

  Future<void> deleteEntry(String id) async {
    await _api.dio.delete('/v1/diary/entries/$id');
  }

  Future<({List<FoodItem> off, List<FoodItem> custom})> searchFoods(String q) async {
    final res = await _api.dio.get('/v1/foods/search', queryParameters: {'q': q});
    final data = res.data['data'] as Map<String, dynamic>;
    final off = (data['openFoodFacts'] as List)
        .map((e) => FoodItem.fromOffJson(e as Map<String, dynamic>))
        .toList();
    final custom = (data['custom'] as List)
        .map((e) => FoodItem.fromCustomJson(e as Map<String, dynamic>))
        .toList();
    return (off: off, custom: custom);
  }

  Future<FoodItem> barcode(String code) async {
    final res = await _api.dio.get('/v1/foods/barcode/$code');
    return FoodItem.fromOffJson(res.data['data'] as Map<String, dynamic>);
  }

  Future<List<AiMealItem>> parseMealText(String text) async {
    final res = await _api.dio.post('/v1/ai/parse-meal', data: {'text': text});
    final items = (res.data['data']['items'] as List)
        .map((e) => AiMealItem.fromJson(e as Map<String, dynamic>))
        .toList();
    return items;
  }

  Future<List<AiMealItem>> parseMealPhoto({
    required List<int> bytes,
    required String mimeType,
    String? hint,
  }) async {
    final res = await _api.dio.post('/v1/ai/parse-meal-photo', data: {
      'imageBase64': base64Encode(bytes),
      'mimeType': mimeType,
      'hint': ?hint,
    });
    return (res.data['data']['items'] as List)
        .map((e) => AiMealItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<String> coach(String message) async {
    final res = await _api.dio.post('/v1/ai/coach', data: {'message': message});
    return res.data['data']['reply'] as String;
  }

  Future<void> syncSteps({
    required String date,
    required int steps,
    required String source,
    double? activeCalories,
  }) async {
    await _api.dio.put('/v1/activity/steps', data: {
      'date': date,
      'steps': steps,
      'source': source,
      'activeCalories': ?activeCalories,
    });
  }

  Future<void> addWorkout(Map<String, dynamic> body) async {
    await _api.dio.post('/v1/activity/workouts', data: body);
  }

  Future<void> addWater({required String date, required int amountMl}) async {
    await _api.dio.post('/v1/water', data: {'date': date, 'amountMl': amountMl});
  }

  Future<void> upsertWeight({
    required String date,
    required double weightKg,
  }) async {
    await _api.dio.put('/v1/weight', data: {
      'date': date,
      'weightKg': weightKg,
      'updateProfile': true,
    });
  }

  Future<Map<String, dynamic>> insights({required String from, required String to}) async {
    final res = await _api.dio.get('/v1/insights/range', queryParameters: {
      'from': from,
      'to': to,
    });
    return res.data['data'] as Map<String, dynamic>;
  }

  String friendlyError(Object err) {
    if (err is DioException) {
      final data = err.response?.data;
      if (data is Map && data['error'] is Map) {
        return (data['error']['message'] as String?) ?? 'Request failed';
      }
      return err.message ?? 'Network error';
    }
    return err.toString();
  }
}

