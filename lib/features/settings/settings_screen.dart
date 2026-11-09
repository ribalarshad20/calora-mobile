import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/config.dart';
import '../../core/network/repositories.dart';
import '../../core/theme/calora_colors.dart';
import '../../features/auth/auth_controller.dart';
import '../../shared/widgets/calora_scaffold.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final weight = TextEditingController();

  @override
  void dispose() {
    weight.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);
    return CaloraScaffold(
      appBar: AppBar(title: const Text('Settings')),
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('Themes', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: CaloraThemeId.values.map((id) {
              final selected = auth.themeId == id;
              return ChoiceChip(
                label: Text(id.label),
                selected: selected,
                onSelected: (_) => ref.read(authControllerProvider.notifier).setTheme(id),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          Text('Weight log', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: weight,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'kg'),
                ),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: () async {
                  final v = double.tryParse(weight.text);
                  if (v == null) return;
                  await ref.read(caloraRepositoryProvider).upsertWeight(
                        date: todayKey(),
                        weightKg: v,
                      );
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Weight saved')),
                    );
                  }
                },
                child: const Text('Save'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Insights'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/insights'),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('API'),
            subtitle: Text(AppConfig.apiBaseUrl),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () async {
              await ref.read(authControllerProvider.notifier).logout();
              if (context.mounted) context.go('/');
            },
            child: const Text('Sign out'),
          ),
        ],
      ),
    );
  }
}
