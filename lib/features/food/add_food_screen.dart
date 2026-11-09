import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../core/models/models.dart';
import '../../core/network/repositories.dart';
import '../../shared/widgets/calora_scaffold.dart';
import '../diary/home_screen.dart';

class AddFoodScreen extends ConsumerStatefulWidget {
  const AddFoodScreen({super.key});

  @override
  ConsumerState<AddFoodScreen> createState() => _AddFoodScreenState();
}

class _AddFoodScreenState extends ConsumerState<AddFoodScreen> {
  final query = TextEditingController();
  String mealType = 'lunch';
  bool loading = false;
  String? error;
  List<FoodItem> off = [];
  List<FoodItem> custom = [];

  @override
  void dispose() {
    query.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final res = await ref.read(caloraRepositoryProvider).searchFoods(query.text.trim());
      setState(() {
        off = res.off;
        custom = res.custom;
      });
    } catch (e) {
      setState(() => error = ref.read(caloraRepositoryProvider).friendlyError(e));
    } finally {
      setState(() => loading = false);
    }
  }

  Future<void> _log(FoodItem item, {String source = 'manual'}) async {
    final qtyController = TextEditingController(text: '1');
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(item.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('${item.calories.round()} kcal / serving'),
            const SizedBox(height: 12),
            TextField(
              controller: qtyController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Servings'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Log')),
        ],
      ),
    );
    if (ok != true) return;
    final qty = double.tryParse(qtyController.text) ?? 1;
    await ref.read(caloraRepositoryProvider).addEntry({
      'date': todayKey(),
      'mealType': mealType,
      'name': item.name,
      'brand': item.brand,
      'servingQty': qty,
      'servingUnit': 'serving',
      'grams': item.servingGrams,
      'macros': {
        'calories': item.calories * qty,
        'proteinG': item.proteinG * qty,
        'carbsG': item.carbsG * qty,
        'fatG': item.fatG * qty,
      },
      'source': source,
      'barcode': item.barcode,
      'idempotencyKey': const Uuid().v4(),
    });
    ref.invalidate(dayProvider);
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return CaloraScaffold(
      appBar: AppBar(
        title: const Text('Add food'),
        actions: [
          IconButton(
            onPressed: () => context.push('/barcode'),
            icon: const Icon(Icons.qr_code_scanner),
          ),
        ],
      ),
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          DropdownButtonFormField(
            // ignore: deprecated_member_use
            value: mealType,
            decoration: const InputDecoration(labelText: 'Meal'),
            items: const [
              DropdownMenuItem(value: 'breakfast', child: Text('Breakfast')),
              DropdownMenuItem(value: 'lunch', child: Text('Lunch')),
              DropdownMenuItem(value: 'dinner', child: Text('Dinner')),
              DropdownMenuItem(value: 'snack', child: Text('Snack')),
            ],
            onChanged: (v) => setState(() => mealType = v ?? mealType),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: query,
                  decoration: const InputDecoration(labelText: 'Search foods'),
                  onSubmitted: (_) => _search(),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filled(onPressed: loading ? null : _search, icon: const Icon(Icons.search)),
            ],
          ),
          if (error != null) ...[
            const SizedBox(height: 12),
            Text(error!),
          ],
          if (loading) const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: CircularProgressIndicator()),
          ),
          if (custom.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text('Your foods', style: Theme.of(context).textTheme.titleMedium),
            ...custom.map((f) => ListTile(
                  title: Text(f.name),
                  subtitle: Text('${f.calories.round()} kcal'),
                  onTap: () => _log(f, source: 'custom'),
                )),
          ],
          if (off.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text('Open Food Facts', style: Theme.of(context).textTheme.titleMedium),
            ...off.map((f) => ListTile(
                  title: Text(f.name),
                  subtitle: Text('${f.brand} · ${f.calories.round()} kcal/100g'),
                  onTap: () => _log(f, source: 'barcode'),
                )),
          ],
        ],
      ),
    );
  }
}
