import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:serviq/core/theme/app_colors.dart';
import 'package:serviq/core/widgets/premium_widgets.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String _status = 'Initializing core modules...';
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();
    _simulateLoading();
  }

  void _simulateLoading() async {
    final steps = [
      {'status': 'Initializing neural core...', 'duration': 600},
      {'status': 'Syncing with Supabase clusters...', 'duration': 800},
      {'status': 'Loading AI agent protocols...', 'duration': 900},
      {'status': 'Fetching local provider database...', 'duration': 700},
      {'status': 'Optimizing route processing...', 'duration': 500},
      {'status': 'Systems Ready', 'duration': 300},
    ];

    for (var i = 0; i < steps.length; i++) {
      if (!mounted) return;
      
      setState(() {
        _status = steps[i]['status'] as String;
      });

      // Smooth progress bar movement
      double targetProgress = (i + 1) / steps.length;
      double startProgress = _progress;
      int substeps = 20;
      for (int j = 0; j <= substeps; j++) {
        await Future.delayed(Duration(milliseconds: (steps[i]['duration'] as int) ~/ substeps));
        if (!mounted) return;
        setState(() {
          _progress = startProgress + (targetProgress - startProgress) * (j / substeps);
        });
      }
    }

    if (mounted) {
      context.go('/input');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Background Gradient Glows
          Positioned(
            top: -100,
            right: -100,
            child: _buildGlow(AppColors.primary.withValues(alpha: 0.08)),
          ).animate().fadeIn(duration: 1000.milliseconds).scale(begin: const Offset(0.5, 0.5)),
          
          Positioned(
            bottom: -50,
            left: -50,
            child: _buildGlow(AppColors.accent.withValues(alpha: 0.05)),
          ).animate().fadeIn(duration: 1200.milliseconds, delay: 400.milliseconds),
          
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const AppLogo(size: 32)
                    .animate()
                    .fadeIn(duration: 800.milliseconds)
                    .scale(begin: const Offset(0.8, 0.8), curve: Curves.elasticOut)
                    .shimmer(delay: 1200.milliseconds, duration: 1500.milliseconds, color: AppColors.primaryLight),
                const SizedBox(height: 24),
                
                // Progress Bar
                SizedBox(
                  width: 200,
                  height: 6,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: _progress,
                      backgroundColor: AppColors.surfaceDark,
                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                  ),
                ).animate().fadeIn(delay: 600.milliseconds),
                
                const SizedBox(height: 16),
                
                // Status text
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Text(
                    _status,
                    key: ValueKey(_status),
                    style: GoogleFonts.plusJakartaSans(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                      letterSpacing: 0.2,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Bottom branding
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'SERVIQ PREMIUM v1.0',
                style: GoogleFonts.inter(
                  color: AppColors.textDisabled,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2,
                ),
              ),
            ).animate().fadeIn(delay: 2000.milliseconds),
          ),
        ],
      ),
    );
  }

  Widget _buildGlow(Color color) {
    return Container(
      width: 400,
      height: 400,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color, color.withValues(alpha: 0)],
        ),
      ),
    );
  }
}
