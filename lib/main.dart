import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app/router.dart';
import 'core/network/repositories.dart';
import 'core/offline/sync_queue.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/auth_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  runApp(const ProviderScope(child: CaloraApp()));
}

class CaloraApp extends ConsumerStatefulWidget {
  const CaloraApp({super.key});

  @override
  ConsumerState<CaloraApp> createState() => _CaloraAppState();
}

class _CaloraAppState extends ConsumerState<CaloraApp> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      await ref.read(authControllerProvider.notifier).bootstrap();
      Connectivity().onConnectivityChanged.listen((results) async {
        final online = results.any((r) => r != ConnectivityResult.none);
        if (!online) return;
        final queue = OfflineSyncQueue(ref.read(caloraRepositoryProvider));
        await queue.flush();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);
    final router = ref.watch(routerProvider);

    if (!auth.bootstrapped) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: buildCaloraTheme(auth.themeId),
        home: const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return MaterialApp.router(
      title: 'Calora',
      debugShowCheckedModeBanner: false,
      theme: buildCaloraTheme(auth.themeId),
      routerConfig: router,
    );
  }
}
