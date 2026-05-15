import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:serviq/features/input/presentation/screens/input_screen.dart';
import 'package:serviq/features/matching/presentation/screens/ai_understanding_screen.dart';
import 'package:serviq/features/matching/presentation/screens/provider_list_screen.dart';
import 'package:serviq/features/booking/presentation/screens/pricing_breakdown_screen.dart';
import 'package:serviq/features/booking/presentation/screens/booking_confirmation_screen.dart';
import 'package:serviq/features/booking/presentation/screens/tracking_screen.dart';

import 'package:serviq/features/splash/presentation/screens/splash_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/',
        builder: (context, state) => const InputScreen(),
      ),
      GoRoute(
        path: '/ai-understanding',
        builder: (context, state) => const AIUnderstandingScreen(),
      ),
      GoRoute(
        path: '/provider-list',
        builder: (context, state) => const ProviderListScreen(),
      ),
      GoRoute(
        path: '/pricing-breakdown',
        builder: (context, state) => const PricingBreakdownScreen(),
      ),
      GoRoute(
        path: '/booking-confirmation',
        builder: (context, state) => const BookingConfirmationScreen(),
      ),
      GoRoute(
        path: '/tracking',
        builder: (context, state) => const TrackingScreen(),
      ),
    ],
  );
});
