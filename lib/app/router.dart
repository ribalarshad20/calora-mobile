import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/activity/activity_screen.dart';
import '../features/ai_log/ai_log_screen.dart';
import '../features/auth/auth_controller.dart';
import '../features/auth/auth_screens.dart';
import '../features/diary/home_screen.dart';
import '../features/food/add_food_screen.dart';
import '../features/food/barcode_screen.dart';
import '../features/insights/insights_screen.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/water/water_screen.dart';
import 'shell.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final auth = ref.watch(authControllerProvider);

  return GoRouter(
    initialLocation: '/',
    refreshListenable: _AuthListenable(ref),
    redirect: (context, state) {
      if (!auth.bootstrapped) return null;
      final loggedIn = auth.user != null;
      final loc = state.matchedLocation;
      final isAuthRoute = loc == '/' || loc == '/login' || loc == '/register';

      if (!loggedIn && !isAuthRoute) return '/';
      if (loggedIn && isAuthRoute) {
        return auth.user!.onboardingComplete ? '/home' : '/onboarding';
      }
      if (loggedIn && !auth.user!.onboardingComplete && loc != '/onboarding') {
        return '/onboarding';
      }
      return null;
    },
    routes: [
      GoRoute(path: '/', builder: (context, state) => const WelcomeScreen()),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/register', builder: (context, state) => const RegisterScreen()),
      GoRoute(path: '/onboarding', builder: (context, state) => const OnboardingScreen()),
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
          GoRoute(path: '/insights', builder: (context, state) => const InsightsScreen()),
          GoRoute(path: '/settings', builder: (context, state) => const SettingsScreen()),
        ],
      ),
      GoRoute(path: '/add-food', builder: (context, state) => const AddFoodScreen()),
      GoRoute(path: '/barcode', builder: (context, state) => const BarcodeScreen()),
      GoRoute(path: '/ai', builder: (context, state) => const AiLogScreen()),
      GoRoute(path: '/activity', builder: (context, state) => const ActivityScreen()),
      GoRoute(path: '/water', builder: (context, state) => const WaterScreen()),
    ],
  );
});

class _AuthListenable extends ChangeNotifier {
  _AuthListenable(this.ref) {
    ref.listen(authControllerProvider, (previous, next) => notifyListeners());
  }
  final Ref ref;
}
