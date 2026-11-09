import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/network/repositories.dart';
import '../../shared/widgets/calora_scaffold.dart';
import '../diary/home_screen.dart';

class WaterScreen extends ConsumerWidget {
  const WaterScreen({super.key});

  Future<void> _add(WidgetRef ref, BuildContext context, int ml) async {
    await ref.read(caloraRepositoryProvider).addWater(date: todayKey(), amountMl: ml);
    ref.invalidate(dayProvider);
    if (context.mounted) context.pop();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CaloraScaffold(
      appBar: AppBar(title: const Text('Water')),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Quick add', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            for (final ml in [150, 250, 350, 500]) ...[
              FilledButton(
                onPressed: () => _add(ref, context, ml),
                child: Text('+$ml ml'),
              ),
              const SizedBox(height: 10),
            ],
          ],
        ),
      ),
    );
  }
}
