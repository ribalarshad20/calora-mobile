import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/network/repositories.dart';
import '../../core/theme/calora_colors.dart';
import '../../shared/widgets/calora_scaffold.dart';

final insightsProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final to = DateTime.now();
  final from = to.subtract(const Duration(days: 13));
  final fmt = DateFormat('yyyy-MM-dd');
  return ref.read(caloraRepositoryProvider).insights(
        from: fmt.format(from),
        to: fmt.format(to),
      );
});

class InsightsScreen extends ConsumerWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(insightsProvider);
    final colors = Theme.of(context).extension<CaloraColors>()!;

    return CaloraScaffold(
      appBar: AppBar(title: const Text('Insights')),
      child: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(ref.read(caloraRepositoryProvider).friendlyError(e))),
        data: (data) {
          final series = (data['series'] as List).cast<Map>();
          final spots = <FlSpot>[];
          for (var i = 0; i < series.length; i++) {
            spots.add(FlSpot(i.toDouble(), (series[i]['calories'] as num).toDouble()));
          }
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _InsightChip(label: 'Streak', value: '${data['streakDays']}d'),
                  _InsightChip(label: 'Adherence', value: '${data['adherencePct']}%'),
                  _InsightChip(label: 'Avg kcal', value: '${data['avgCalories']}'),
                  _InsightChip(label: 'Avg steps', value: '${data['avgSteps']}'),
                ],
              ),
              const SizedBox(height: 24),
              Text('Calories · 14 days', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              SizedBox(
                height: 220,
                child: LineChart(
                  LineChartData(
                    gridData: const FlGridData(show: false),
                    titlesData: const FlTitlesData(show: false),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: spots,
                        isCurved: true,
                        color: colors.accent,
                        barWidth: 3,
                        dotData: const FlDotData(show: false),
                        belowBarData: BarAreaData(
                          show: true,
                          color: colors.accent.withValues(alpha: 0.15),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text('Weight', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              ...(data['weight'] as List).cast<Map>().map(
                    (w) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text('${w['weightKg']} kg'),
                      subtitle: Text('${w['date']}'),
                    ),
                  ),
              if ((data['weight'] as List).isEmpty)
                Text('Log weight from Settings to see the trend.', style: Theme.of(context).textTheme.bodySmall),
            ],
          );
        },
      ),
    );
  }
}

class _InsightChip extends StatelessWidget {
  const _InsightChip({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<CaloraColors>()!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: colors.surface.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          Text(value, style: Theme.of(context).textTheme.titleLarge),
        ],
      ),
    );
  }
}
