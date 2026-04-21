import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'providers/session_provider.dart';
import 'screens/scanner_screen.dart';
import 'screens/menu_screen.dart';
import 'screens/cart_screen.dart';
import 'screens/orders_screen.dart';
import 'screens/chef_dashboard_screen.dart';

void main() {
  runApp(const ProviderScope(child: SmartRestaurantApp()));
}

final routerProvider = Provider<GoRouter>((ref) {
  final sessionState = ref.watch(sessionProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      if (sessionState.isLoading) return '/';
      
      final hasSession = sessionState.sessionCode != null;
      final isGoingToRoot = state.matchedLocation == '/';
      final isScanner = state.matchedLocation == '/scanner';

      if (!hasSession && !isGoingToRoot && !isScanner) {
        return '/scanner';
      }
      
      if (hasSession && (isGoingToRoot || isScanner)) {
        return '/menu';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const Scaffold(body: Center(child: CircularProgressIndicator())),
      ),
      GoRoute(
        path: '/scanner',
        builder: (context, state) => const ScannerScreen(),
      ),
      GoRoute(
        path: '/menu',
        builder: (context, state) => const MenuScreen(),
      ),
      GoRoute(
        path: '/cart',
        builder: (context, state) => const CartScreen(),
      ),
      GoRoute(
        path: '/orders',
        builder: (context, state) => const OrdersScreen(),
      ),
      GoRoute(
        path: '/chef',
        builder: (context, state) => const ChefDashboardScreen(),
      ),
    ],
  );
});

class SmartRestaurantApp extends ConsumerWidget {
  const SmartRestaurantApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Smart Restaurant',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        useMaterial3: true,
      ),
      routerConfig: router,
    );
  }
}
