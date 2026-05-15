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
      {'status': 'Initializing core modules...', 'duration': 800},
      {'status': 'Connecting to AI engine...', 'duration': 1000},
      {'status': 'Finalizing services...', 'duration': 700},
      {'status': 'Ready', 'duration': 300},
    ];

    for (var i = 0; i < steps.length; i++) {
      if (!mounted) return;
      setState(() {
        _status = steps[i]['status'] as String;
        _progress = (i + 1) / steps.length;
      });
      await Future.delayed(Duration(milliseconds: steps[i]['duration'] as int));
    }

    if (mounted) {
      context.go('/');
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
            child: _buildGlow(AppColors.primary.withOpacity(0.08)),
          ).animate().fadeIn(duration: 1000.ms).scale(begin: const Offset(0.5, 0.5)),
          
          Positioned(
            bottom: -50,
            left: -50,
            child: _buildGlow(AppColors.accent.withOpacity(0.05)),
          ).animate().fadeIn(duration: 1200.ms, delay: 400.ms),
          
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const AppLogo(size: 32)
                    .animate()
                    .fadeIn(duration: 800.ms)
                    .scale(begin: const Offset(0.8, 0.8), curve: Curves.elasticOut)
                    .shimmer(delay: 1200.ms, duration: 1500.ms, color: AppColors.primaryLight),
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
                ).animate().fadeIn(delay: 600.ms),
                
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
            ).animate().fadeIn(delay: 2000.ms),
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
          colors: [color, color.withOpacity(0)],
        ),
      ),
    );
  }
}
