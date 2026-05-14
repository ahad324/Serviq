import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:serviq/features/input/presentation/screens/input_screen.dart';
import 'package:serviq/features/matching/presentation/screens/ai_understanding_screen.dart';
import 'package:serviq/features/matching/presentation/screens/provider_list_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
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
    ],
  );
});
