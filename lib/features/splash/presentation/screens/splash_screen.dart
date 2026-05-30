import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:serviq/core/theme/app_colors.dart';
import 'package:serviq/core/widgets/premium_widgets.dart';
import 'package:serviq/features/auth/presentation/providers/session_provider.dart';
import 'package:serviq/core/services/location_service.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _runInitialization();
  }

  void _runInitialization() async {
    final startTime = DateTime.now();

    // Core Initialization Steps (Minimal delays for stability)
    try {
      // Step 1: Supabase client handshake
      Supabase.instance.client.auth.currentSession;
      await Future.delayed(const Duration(milliseconds: 50));

      // Step 2: Auth state loading
      await ref.read(sessionNotifierProvider.notifier).initializationComplete;
      await Future.delayed(const Duration(milliseconds: 50));

      // Step 3: Location telemetry
      final locationService = ref.read(locationServiceProvider);
      await locationService.isLocationServiceEnabled();
    } catch (e) {
      debugPrint('[Splash] Init error: $e');
    }

    // Ensure splash screen remains visible for a stable, professional duration (2000ms)
    // This allows the user to see the redesign and read at least one tip.
    final elapsed = DateTime.now().difference(startTime);
    final remainingDelay = const Duration(milliseconds: 2000) - elapsed;
    if (remainingDelay > Duration.zero) {
      await Future.delayed(remainingDelay);
    }

    if (mounted) {
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // 1. Ambient Background Gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.background,
                  AppColors.background.withValues(alpha: 0.98),
                  AppColors.surfaceDark.withValues(alpha: 0.1),
                  AppColors.background,
                ],
              ),
            ),
          ),
          
          // 2. Animated Ambient Glow Orbs
          Positioned(
            top: -100,
            right: -100,
            child: _buildAmbientGlow(
              color: AppColors.primary.withValues(alpha: 0.1),
              size: 500,
            ),
          ).animate().fadeIn(duration: 1200.milliseconds).scale(begin: const Offset(0.8, 0.8)),
          
          Positioned(
            bottom: -50,
            left: -50,
            child: _buildAmbientGlow(
              color: AppColors.accent.withValues(alpha: 0.05),
              size: 400,
            ),
          ).animate().fadeIn(duration: 1500.milliseconds, delay: 200.milliseconds),

          // 3. Central Brand & Loading Interface
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // App Branding Logo
                _buildBrandLogoSection(),
                
                const SizedBox(height: 60),
                
                // New Redesigned Premium Loading Component
                const PremiumLoadingIndicator(
                  size: 44,
                  showTips: true,
                ).animate().fadeIn(delay: 600.milliseconds, duration: 800.milliseconds),
              ],
            ),
          ),
          
          // 4. Elegant Minimal Footer
          Positioned(
            bottom: 48,
            left: 0,
            right: 0,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'SERVIQ SUITE',
                    style: GoogleFonts.plusJakartaSans(
                      color: AppColors.primary.withValues(alpha: 0.5),
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 4,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'INTELLIGENT SERVICE MATCHING',
                    style: GoogleFonts.inter(
                      color: AppColors.textDisabled.withValues(alpha: 0.5),
                      fontSize: 8,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 1000.milliseconds),
          ),
        ],
      ),
    );
  }

  Widget _buildBrandLogoSection() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Clean logo wrapper without background
        Container(
          padding: const EdgeInsets.all(20),
          child: const AppLogo(size: 32, showText: false),
        )
        .animate(onPlay: (controller) => controller.repeat(reverse: true))
        .scale(
          duration: 3.seconds,
          begin: const Offset(1.0, 1.0),
          end: const Offset(1.06, 1.06),
          curve: Curves.easeInOut,
        ),
        
        const SizedBox(height: 32),
        
        Text(
          'SERVIQ',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 36,
            fontWeight: FontWeight.w900,
            color: AppColors.primary,
            letterSpacing: 8,
          ),
        ).animate().fadeIn(duration: 800.milliseconds).slideY(begin: 0.2, end: 0),
      ],
    );
  }

  Widget _buildAmbientGlow({required Color color, required double size}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color, color.withValues(alpha: 0)],
        ),
      ),
    );
  }
}
