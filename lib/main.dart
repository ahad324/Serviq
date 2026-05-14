import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'features/input/presentation/screens/input_screen.dart';

void main() {
  runApp(
    const ProviderScope(
      child: ServiqApp(),
    ),
  );
}

class ServiqApp extends StatelessWidget {
  const ServiqApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Serviq',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const InputScreen(),
    );
  }
}
