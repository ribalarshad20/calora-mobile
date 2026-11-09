import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import '../../core/models/models.dart';
import '../../core/network/repositories.dart';
import '../../shared/widgets/calora_scaffold.dart';
import '../diary/home_screen.dart';

class AiLogScreen extends ConsumerStatefulWidget {
  const AiLogScreen({super.key});

  @override
  ConsumerState<AiLogScreen> createState() => _AiLogScreenState();
}

class _AiLogScreenState extends ConsumerState<AiLogScreen> {
  final text = TextEditingController();
  final coach = TextEditingController();
  List<AiMealItem> items = [];
  String? coachReply;
  bool loading = false;
  String? error;
  String mealType = 'lunch';

  @override
  void dispose() {
    text.dispose();
    coach.dispose();
    super.dispose();
  }

  Future<void> _parseText() async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      items = await ref.read(caloraRepositoryProvider).parseMealText(text.text.trim());
      setState(() {});
    } catch (e) {
      setState(() => error = ref.read(caloraRepositoryProvider).friendlyError(e));
    } finally {
      setState(() => loading = false);
    }
  }

  Future<void> _parsePhoto() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.camera, imageQuality: 75);
    if (file == null) return;
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final bytes = await File(file.path).readAsBytes();
      items = await ref.read(caloraRepositoryProvider).parseMealPhoto(
            bytes: bytes,
            mimeType: 'image/jpeg',
            hint: text.text.trim().isEmpty ? null : text.text.trim(),
          );
      setState(() {});
    } catch (e) {
      setState(() => error = ref.read(caloraRepositoryProvider).friendlyError(e));
    } finally {
      setState(() => loading = false);
    }
  }

  Future<void> _confirm() async {
    final repo = ref.read(caloraRepositoryProvider);
    for (final item in items) {
      await repo.addEntry({
        'date': todayKey(),
        'mealType': mealType,
        'name': item.name,
        'servingQty': 1,
        'servingUnit': item.grams != null ? 'g' : 'serving',
        'grams': item.grams,
        'macros': {
          'calories': item.calories,
          'proteinG': item.proteinG,
          'carbsG': item.carbsG,
          'fatG': item.fatG,
        },
        'source': 'ai_text',
        'idempotencyKey': const Uuid().v4(),
        'notes': item.confidence == null
            ? ''
            : 'AI confidence ${(item.confidence! * 100).round()}%',
      });
    }
    ref.invalidate(dayProvider);
    if (mounted) context.pop();
  }

  Future<void> _askCoach() async {
    setState(() => loading = true);
    try {
      coachReply = await ref.read(caloraRepositoryProvider).coach(coach.text.trim());
      setState(() {});
    } catch (e) {
      setState(() => error = ref.read(caloraRepositoryProvider).friendlyError(e));
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return CaloraScaffold(
      appBar: AppBar(title: const Text('AI calorie help')),
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Describe a meal in plain language, or snap a photo. Confirm before saving — accuracy first.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField(
            // ignore: deprecated_member_use
            value: mealType,
            items: const [
              DropdownMenuItem(value: 'breakfast', child: Text('Breakfast')),
              DropdownMenuItem(value: 'lunch', child: Text('Lunch')),
              DropdownMenuItem(value: 'dinner', child: Text('Dinner')),
              DropdownMenuItem(value: 'snack', child: Text('Snack')),
            ],
            onChanged: (v) => setState(() => mealType = v ?? mealType),
            decoration: const InputDecoration(labelText: 'Meal'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: text,
            minLines: 3,
            maxLines: 5,
            decoration: const InputDecoration(
              labelText: 'e.g. 2 eggs, toast with butter, black coffee',
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: FilledButton(
                  onPressed: loading ? null : _parseText,
                  child: const Text('Parse text'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: loading ? null : _parsePhoto,
                  child: const Text('Photo'),
                ),
              ),
            ],
          ),
          if (error != null) ...[
            const SizedBox(height: 12),
            Text(error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ],
          if (loading) const Padding(
            padding: EdgeInsets.all(16),
            child: LinearProgressIndicator(),
          ),
          ...items.map(
            (i) => CheckboxListTile(
              value: true,
              onChanged: (_) {},
              title: Text(i.name),
              subtitle: Text(
                '${i.calories.round()} kcal · P${i.proteinG.round()} C${i.carbsG.round()} F${i.fatG.round()}'
                '${i.confidence != null ? ' · ${(i.confidence! * 100).round()}%' : ''}',
              ),
            ),
          ),
          if (items.isNotEmpty)
            FilledButton(onPressed: _confirm, child: const Text('Confirm & save')),
          const SizedBox(height: 28),
          Text('Coach', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          TextField(
            controller: coach,
            decoration: const InputDecoration(labelText: 'Ask Calora anything gentle'),
          ),
          const SizedBox(height: 8),
          OutlinedButton(onPressed: loading ? null : _askCoach, child: const Text('Ask')),
          if (coachReply != null) ...[
            const SizedBox(height: 12),
            Text(coachReply!),
          ],
        ],
      ),
    );
  }
}
