import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:uuid/uuid.dart';

import '../../core/network/repositories.dart';
import '../../shared/widgets/calora_scaffold.dart';
import '../diary/home_screen.dart';

class BarcodeScreen extends ConsumerStatefulWidget {
  const BarcodeScreen({super.key});

  @override
  ConsumerState<BarcodeScreen> createState() => _BarcodeScreenState();
}

class _BarcodeScreenState extends ConsumerState<BarcodeScreen> {
  bool handling = false;
  String? error;

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (handling) return;
    final barcodes = capture.barcodes;
    final code = barcodes.isEmpty ? null : barcodes.first.rawValue;
    if (code == null || code.isEmpty) return;
    setState(() {
      handling = true;
      error = null;
    });
    try {
      final item = await ref.read(caloraRepositoryProvider).barcode(code);
      await ref.read(caloraRepositoryProvider).addEntry({
        'date': todayKey(),
        'mealType': 'snack',
        'name': item.name,
        'brand': item.brand,
        'servingQty': 1,
        'servingUnit': '100g',
        'grams': item.servingGrams,
        'macros': {
          'calories': item.calories,
          'proteinG': item.proteinG,
          'carbsG': item.carbsG,
          'fatG': item.fatG,
        },
        'source': 'barcode',
        'barcode': item.barcode,
        'idempotencyKey': const Uuid().v4(),
      });
      ref.invalidate(dayProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Logged ${item.name}')),
        );
        context.pop();
      }
    } catch (e) {
      setState(() {
        error = ref.read(caloraRepositoryProvider).friendlyError(e);
        handling = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return CaloraScaffold(
      appBar: AppBar(title: const Text('Scan barcode')),
      child: Column(
        children: [
          Expanded(
            child: MobileScanner(onDetect: _onDetect),
          ),
          if (error != null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(error!),
            ),
          if (handling)
            const Padding(
              padding: EdgeInsets.all(16),
              child: LinearProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
