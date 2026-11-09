import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/network/repositories.dart';
import '../../features/auth/auth_controller.dart';
import '../../shared/widgets/calora_scaffold.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  String sex = 'male';
  String goal = 'lose';
  String activity = 'moderate';
  final age = TextEditingController(text: '28');
  final height = TextEditingController(text: '175');
  final weight = TextEditingController(text: '75');
  bool loading = false;
  String? error;

  @override
  void dispose() {
    age.dispose();
    height.dispose();
    weight.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      await ref.read(caloraRepositoryProvider).upsertProfile({
        'sex': sex,
        'age': int.parse(age.text),
        'heightCm': double.parse(height.text),
        'weightKg': double.parse(weight.text),
        'goal': goal,
        'activityLevel': activity,
      });
      ref.read(authControllerProvider.notifier).markOnboarded();
      if (mounted) context.go('/home');
    } catch (e) {
      setState(() => error = ref.read(caloraRepositoryProvider).friendlyError(e));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return CaloraScaffold(
      appBar: AppBar(title: const Text('Your calm baseline')),
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            'We use Mifflin–St Jeor for BMR and activity multipliers for TDEE — targets stay honest and adjustable.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 20),
          DropdownButtonFormField(
            // ignore: deprecated_member_use
            value: sex,
            decoration: const InputDecoration(labelText: 'Sex'),
            items: const [
              DropdownMenuItem(value: 'male', child: Text('Male')),
              DropdownMenuItem(value: 'female', child: Text('Female')),
              DropdownMenuItem(value: 'other', child: Text('Other')),
            ],
            onChanged: (v) => setState(() => sex = v ?? sex),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: age,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Age'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: height,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Height (cm)'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: weight,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Weight (kg)'),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField(
            // ignore: deprecated_member_use
            value: goal,
            decoration: const InputDecoration(labelText: 'Goal'),
            items: const [
              DropdownMenuItem(value: 'lose', child: Text('Lose weight')),
              DropdownMenuItem(value: 'maintain', child: Text('Maintain')),
              DropdownMenuItem(value: 'gain', child: Text('Gain weight')),
            ],
            onChanged: (v) => setState(() => goal = v ?? goal),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField(
            // ignore: deprecated_member_use
            value: activity,
            decoration: const InputDecoration(labelText: 'Activity'),
            items: const [
              DropdownMenuItem(value: 'sedentary', child: Text('Sedentary')),
              DropdownMenuItem(value: 'light', child: Text('Light')),
              DropdownMenuItem(value: 'moderate', child: Text('Moderate')),
              DropdownMenuItem(value: 'active', child: Text('Active')),
              DropdownMenuItem(value: 'very_active', child: Text('Very active')),
            ],
            onChanged: (v) => setState(() => activity = v ?? activity),
          ),
          if (error != null) ...[
            const SizedBox(height: 12),
            Text(error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ],
          const SizedBox(height: 24),
          FilledButton(
            onPressed: loading ? null : _submit,
            child: loading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Calculate my targets'),
          ),
        ],
      ),
    );
  }
}
