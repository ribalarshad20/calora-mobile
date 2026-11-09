import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';

import '../network/repositories.dart';

class OfflineSyncQueue {
  OfflineSyncQueue(this._repo);

  final CaloraRepository _repo;
  static const boxName = 'calora_sync_queue';

  Future<void> enqueueDiaryEntry(Map<String, dynamic> body) async {
    final box = await Hive.openBox(boxName);
    final id = const Uuid().v4();
    await box.put(id, jsonEncode({
      'type': 'diary_entry',
      'body': {
        ...body,
        'idempotencyKey': body['idempotencyKey'] ?? id,
      },
    }));
  }

  Future<int> flush() async {
    final box = await Hive.openBox(boxName);
    final keys = box.keys.toList();
    var flushed = 0;
    for (final key in keys) {
      final raw = box.get(key);
      if (raw is! String) continue;
      final map = jsonDecode(raw) as Map<String, dynamic>;
      try {
        if (map['type'] == 'diary_entry') {
          await _repo.addEntry(Map<String, dynamic>.from(map['body'] as Map));
        }
        await box.delete(key);
        flushed += 1;
      } catch (_) {
        break;
      }
    }
    return flushed;
  }
}
