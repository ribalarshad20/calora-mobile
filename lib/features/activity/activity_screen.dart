import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/network/repositories.dart';
import '../../shared/widgets/calora_scaffold.dart';
import '../diary/home_screen.dart';
import 'steps_service.dart';

class ActivityScreen extends ConsumerStatefulWidget {
  const ActivityScreen({super.key});

  @override
  ConsumerState<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends ConsumerState<ActivityScreen> {
  String type = 'walking';
  final duration = TextEditingController(text: '30');
  final label = TextEditingController();
  String? status;
  bool loading = false;

  @override
  void dispose() {
    duration.dispose();
    label.dispose();
    super.dispose();
  }

  Future<void> _syncSteps() async {
    setState(() => loading = true);
    try {
      final reading = await StepsService.instance.readTodaySteps();
      await ref.read(caloraRepositoryProvider).syncSteps(
            date: todayKey(),
            steps: reading.steps,
            source: reading.source,
            activeCalories: reading.activeCalories,
          );
      ref.invalidate(dayProvider);
      setState(() => status = '${reading.steps} steps from ${reading.source}');
    } catch (e) {
      setState(() => status = ref.read(caloraRepositoryProvider).friendlyError(e));
    } finally {
      setState(() => loading = false);
    }
  }

  Future<void> _addWorkout() async {
    setState(() => loading = true);
    try {
      await ref.read(caloraRepositoryProvider).addWorkout({
        'date': todayKey(),
        'type': type,
        'label': label.text.trim(),
        'durationMin': double.parse(duration.text),
      });
      ref.invalidate(dayProvider);
      if (mounted) context.pop();
    } catch (e) {
      setState(() => status = ref.read(caloraRepositoryProvider).friendlyError(e));
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return CaloraScaffold(
      appBar: AppBar(title: const Text('Activity')),
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Steps prefer Health Connect when available, with device sensor fallback. Source is always shown on Today.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: loading ? null : _syncSteps,
            child: const Text('Sync steps now'),
          ),
          if (status != null) ...[
            const SizedBox(height: 8),
            Text(status!),
          ],
          const SizedBox(height: 28),
          Text('Log workout', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          DropdownButtonFormField(
            // ignore: deprecated_member_use
            value: type,
            decoration: const InputDecoration(labelText: 'Type'),
            items: const [
              DropdownMenuItem(value: 'walking', child: Text('Walking')),
              DropdownMenuItem(value: 'running', child: Text('Running')),
              DropdownMenuItem(value: 'cycling', child: Text('Cycling')),
              DropdownMenuItem(value: 'swimming', child: Text('Swimming')),
              DropdownMenuItem(value: 'weightlifting', child: Text('Weightlifting')),
              DropdownMenuItem(value: 'yoga', child: Text('Yoga')),
              DropdownMenuItem(value: 'hiit', child: Text('HIIT')),
              DropdownMenuItem(value: 'other', child: Text('Other')),
            ],
            onChanged: (v) => setState(() => type = v ?? type),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: duration,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Duration (min)'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: label,
            decoration: const InputDecoration(labelText: 'Label (optional)'),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: loading ? null : _addWorkout,
            child: const Text('Save workout'),
          ),
        ],
      ),
    );
  }
}
