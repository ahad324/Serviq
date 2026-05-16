import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:serviq/features/input/presentation/screens/input_screen.dart';
import 'package:serviq/features/matching/presentation/screens/ai_understanding_screen.dart';
import 'package:serviq/features/matching/presentation/screens/provider_list_screen.dart';
import 'package:serviq/features/booking/presentation/screens/pricing_breakdown_screen.dart';
import 'package:serviq/features/booking/presentation/screens/booking_confirmation_screen.dart';
import 'package:serviq/features/tracking/presentation/screens/tracking_screen.dart';
import 'package:serviq/features/auth/presentation/screens/auth_screen.dart';
import 'package:serviq/features/common/presentation/screens/profile_screen.dart';
import 'package:serviq/features/booking/presentation/screens/booking_history_screen.dart';
import 'package:serviq/features/auth/presentation/providers/session_provider.dart';
import 'package:serviq/features/splash/presentation/screens/splash_screen.dart';
import 'package:serviq/core/widgets/bottom_nav_bar.dart';
import 'package:serviq/core/widgets/not_found_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  final user = ref.watch(sessionNotifierProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    redirect: (context, state) {
      final isLoggedIn = user != null;
      final isAuthRoute = state.matchedLocation == '/auth';

      if (!isLoggedIn && !isAuthRoute && state.matchedLocation != '/') return '/auth';
      if (isLoggedIn && isAuthRoute) return '/home';
      if (state.matchedLocation == '/') return null; // Let the splash screen show
      return null;
    },
    errorBuilder: (context, state) => const NotFoundScreen(),
    routes: [
      GoRoute(
        path: '/',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/auth',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const AuthScreen(),
      ),
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return Scaffold(
            body: child,
            bottomNavigationBar: BottomNavBar(currentRoute: state.matchedLocation),
          );
        },
        routes: [
          GoRoute(path: '/home', builder: (context, state) => const InputScreen()),
          GoRoute(
            path: '/tracking',
            builder: (context, state) {
              final bookingId = state.extra as String?;
              return TrackingScreen(bookingId: bookingId);
            },
          ),
          GoRoute(path: '/profile', builder: (context, state) => const ProfileScreen()),
          GoRoute(path: '/booking-history', builder: (context, state) => const BookingHistoryScreen()),
        ],
      ),
      // Other routes that shouldn't have bottom nav
      GoRoute(
        path: '/ai-understanding',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const AIUnderstandingScreen(),
      ),
      GoRoute(
        path: '/providers',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const ProviderListScreen(),
      ),
      GoRoute(
        path: '/pricing-breakdown',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const PricingBreakdownScreen(),
      ),
      GoRoute(
        path: '/booking-confirmation',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const BookingConfirmationScreen(),
      ),
    ],
  );
});
