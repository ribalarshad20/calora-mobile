import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/models/models.dart';
import '../../core/network/repositories.dart';
import '../../core/theme/calora_colors.dart';
import '../../features/activity/steps_service.dart';
import '../../shared/widgets/calora_scaffold.dart';
import '../../shared/widgets/macro_ring.dart';

final dayProvider = FutureProvider.autoDispose<({DaySummary summary, List<DiaryEntry> entries})>((ref) async {
  final repo = ref.watch(caloraRepositoryProvider);
  final date = todayKey();
  // Best-effort step sync before day fetch
  try {
    final steps = await StepsService.instance.readTodaySteps();
    await repo.syncSteps(
      date: date,
      steps: steps.steps,
      source: steps.source,
      activeCalories: steps.activeCalories,
    );
  } catch (_) {}
  return repo.day(date);
});

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final day = ref.watch(dayProvider);
    final colors = Theme.of(context).extension<CaloraColors>()!;

    return CaloraScaffold(
      appBar: AppBar(
        title: const Text('Calora'),
        actions: [
          IconButton(
            onPressed: () => context.push('/ai'),
            icon: const Icon(Icons.auto_awesome_outlined),
            tooltip: 'AI log',
          ),
          IconButton(
            onPressed: () => context.push('/settings'),
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/add-food'),
        icon: const Icon(Icons.add),
        label: const Text('Add food'),
      ),
      child: day.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(ref.read(caloraRepositoryProvider).friendlyError(e)),
          ),
        ),
        data: (data) {
          final s = data.summary;
          final progress = s.calorieTarget == 0
              ? 0.0
              : s.consumed.calories / s.calorieTarget;
          final meals = {
            'breakfast': <DiaryEntry>[],
            'lunch': <DiaryEntry>[],
            'dinner': <DiaryEntry>[],
            'snack': <DiaryEntry>[],
          };
          for (final e in data.entries) {
            meals.putIfAbsent(e.mealType, () => []).add(e);
          }

          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(dayProvider),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
              children: [
                Center(
                  child: MacroRing(
                    progress: progress,
                    remaining: s.remaining,
                    burned: s.burnedTotal,
                    consumed: s.consumed.calories.round(),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: _StatTile(
                        label: 'Steps',
                        value: '${s.steps}',
                        hint: s.stepsSource?.replaceAll('_', ' ') ?? 'syncing',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatTile(
                        label: 'Water',
                        value: '${s.waterMl} ml',
                        hint: 'goal ${s.waterGoalMl}',
                        onTap: () => context.push('/water'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _MacroChip(label: 'P', value: s.consumed.proteinG, target: s.proteinTarget, color: colors.accent),
                    _MacroChip(label: 'C', value: s.consumed.carbsG, target: s.carbsTarget, color: colors.success),
                    _MacroChip(label: 'F', value: s.consumed.fatG, target: s.fatTarget, color: colors.danger),
                  ],
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: () => context.push('/activity'),
                    icon: const Icon(Icons.directions_walk_outlined),
                    label: const Text('Activity & workouts'),
                  ),
                ),
                const SizedBox(height: 8),
                for (final meal in meals.entries) ...[
                  Text(
                    meal.key[0].toUpperCase() + meal.key.substring(1),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  if (meal.value.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Text('Nothing logged yet', style: Theme.of(context).textTheme.bodySmall),
                    )
                  else
                    ...meal.value.map(
                      (e) => Dismissible(
                        key: ValueKey(e.id),
                        direction: DismissDirection.endToStart,
                        onDismissed: (_) async {
                          await ref.read(caloraRepositoryProvider).deleteEntry(e.id);
                          ref.invalidate(dayProvider);
                        },
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 16),
                          color: colors.danger.withValues(alpha: 0.15),
                          child: Icon(Icons.delete_outline, color: colors.danger),
                        ),
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(e.name),
                          subtitle: Text('${e.macros.calories.round()} kcal · ${e.source}'),
                          trailing: Text('${e.macros.proteinG.round()}P'),
                        ),
                      ),
                    ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.label,
    required this.value,
    required this.hint,
    this.onTap,
  });

  final String label;
  final String value;
  final String hint;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<CaloraColors>()!;
    return Material(
      color: colors.surface.withValues(alpha: 0.85),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 4),
              Text(value, style: Theme.of(context).textTheme.titleLarge),
              Text(hint, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      ),
    );
  }
}

class _MacroChip extends StatelessWidget {
  const _MacroChip({
    required this.label,
    required this.value,
    required this.target,
    required this.color,
  });

  final String label;
  final double value;
  final int target;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text('$label ${value.round()}/${target}g'),
      avatar: CircleAvatar(backgroundColor: color, radius: 6),
    );
  }
}
