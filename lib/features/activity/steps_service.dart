import 'package:health/health.dart';
import 'package:pedometer/pedometer.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StepsReading {
  StepsReading({
    required this.steps,
    required this.source,
    this.activeCalories,
  });

  final int steps;
  final String source;
  final double? activeCalories;
}

class StepsService {
  StepsService._();
  static final instance = StepsService._();

  final Health _health = Health();
  int? _baseline;

  Future<StepsReading> readTodaySteps() async {
    try {
      final types = [HealthDataType.STEPS, HealthDataType.ACTIVE_ENERGY_BURNED];
      final granted = await _health.requestAuthorization(types);
      if (granted) {
        final now = DateTime.now();
        final midnight = DateTime(now.year, now.month, now.day);
        final steps = await _health.getTotalStepsInInterval(midnight, now);
        double? active;
        try {
          final energy = await _health.getHealthDataFromTypes(
            types: [HealthDataType.ACTIVE_ENERGY_BURNED],
            startTime: midnight,
            endTime: now,
          );
          active = energy.fold<double>(0, (s, e) {
            final v = e.value;
            if (v is NumericHealthValue) return s + v.numericValue.toDouble();
            return s;
          });
        } catch (_) {}
        if (steps != null) {
          return StepsReading(
            steps: steps,
            source: 'health_connect',
            activeCalories: active,
          );
        }
      }
    } catch (_) {}

    return _sensorFallback();
  }

  Future<StepsReading> _sensorFallback() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final savedDay = prefs.getString('step_baseline_day');
    _baseline = prefs.getInt('step_baseline');

    try {
      final event = await Pedometer.stepCountStream.first.timeout(
        const Duration(seconds: 3),
      );
      if (savedDay != today || _baseline == null) {
        _baseline = event.steps;
        await prefs.setString('step_baseline_day', today);
        await prefs.setInt('step_baseline', _baseline!);
      }
      final steps = (event.steps - (_baseline ?? event.steps)).clamp(0, 200000);
      return StepsReading(steps: steps, source: 'device_sensor');
    } catch (_) {
      final cached = prefs.getInt('cached_steps_$today') ?? 0;
      return StepsReading(steps: cached, source: 'device_sensor');
    }
  }
}
