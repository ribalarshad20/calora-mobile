import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/models.dart';
import '../../core/network/api_client.dart';
import '../../core/network/repositories.dart';
import '../../core/theme/calora_colors.dart';

class AuthState {
  const AuthState({
    this.user,
    this.loading = false,
    this.bootstrapped = false,
    this.error,
    this.themeId = CaloraThemeId.sageMist,
  });

  final AuthUser? user;
  final bool loading;
  final bool bootstrapped;
  final String? error;
  final CaloraThemeId themeId;

  AuthState copyWith({
    AuthUser? user,
    bool? loading,
    bool? bootstrapped,
    String? error,
    CaloraThemeId? themeId,
    bool clearUser = false,
    bool clearError = false,
  }) {
    return AuthState(
      user: clearUser ? null : (user ?? this.user),
      loading: loading ?? this.loading,
      bootstrapped: bootstrapped ?? this.bootstrapped,
      error: clearError ? null : (error ?? this.error),
      themeId: themeId ?? this.themeId,
    );
  }
}

class AuthController extends Notifier<AuthState> {
  @override
  AuthState build() => const AuthState();

  CaloraRepository get _repo => ref.read(caloraRepositoryProvider);
  ApiClient get _api => ref.read(apiClientProvider);

  Future<void> bootstrap() async {
    final has = await _api.hasSession();
    if (!has) {
      state = state.copyWith(bootstrapped: true, clearUser: true);
      return;
    }
    try {
      final me = await _repo.me();
      state = state.copyWith(
        bootstrapped: true,
        user: AuthUser(
          id: me['id'] as String,
          email: me['email'] as String,
          name: me['name'] as String,
          onboardingComplete: me['onboardingComplete'] as bool? ?? false,
        ),
        themeId: CaloraThemeIdX.fromStorage(me['theme'] as String?),
      );
    } catch (_) {
      await _api.clearTokens();
      state = state.copyWith(bootstrapped: true, clearUser: true);
    }
  }

  Future<bool> login(String email, String password) async {
    state = state.copyWith(loading: true, clearError: true);
    try {
      final user = await _repo.login(email: email, password: password);
      state = state.copyWith(loading: false, user: user);
      return true;
    } catch (e) {
      state = state.copyWith(loading: false, error: _repo.friendlyError(e));
      return false;
    }
  }

  Future<bool> register(String name, String email, String password, {String? invite}) async {
    state = state.copyWith(loading: true, clearError: true);
    try {
      final user = await _repo.register(
        email: email,
        password: password,
        name: name,
        inviteCode: invite,
      );
      state = state.copyWith(loading: false, user: user);
      return true;
    } catch (e) {
      state = state.copyWith(loading: false, error: _repo.friendlyError(e));
      return false;
    }
  }

  Future<void> logout() async {
    await _repo.logout();
    state = state.copyWith(clearUser: true);
  }

  void markOnboarded() {
    final user = state.user;
    if (user == null) return;
    state = state.copyWith(
      user: AuthUser(
        id: user.id,
        email: user.email,
        name: user.name,
        onboardingComplete: true,
      ),
    );
  }

  Future<void> setTheme(CaloraThemeId id) async {
    state = state.copyWith(themeId: id);
    try {
      await _repo.setTheme(id.storageKey);
    } catch (_) {}
  }
}

final authControllerProvider = NotifierProvider<AuthController, AuthState>(AuthController.new);
