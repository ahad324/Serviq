import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';

void main() {
  // Use PathUrlStrategy to remove the '#' from the URL in web
  usePathUrlStrategy();
  
  runApp(
    const ProviderScope(
      child: ServiqApp(),
    ),
  );
}

class ServiqApp extends ConsumerWidget {
  const ServiqApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    
    return MaterialApp.router(
      title: 'Serviq',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: router,
    );
  }
}
