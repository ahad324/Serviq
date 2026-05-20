import 'dart:ui';
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
  String _status = 'Establishing secure handshake...';
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();
    _simulateLoading();
  }

  void _simulateLoading() async {
    final steps = [
      {'status': 'Establishing secure handshake...', 'duration': 600},
      {'status': 'Syncing distributed database...', 'duration': 750},
      {'status': 'Deploying cognitive agent mesh...', 'duration': 850},
      {'status': 'Resolving spatial telemetry...', 'duration': 750},
      {'status': 'Configuring execution framework...', 'duration': 600},
      {'status': 'Ready', 'duration': 350},
    ];

    for (var i = 0; i < steps.length; i++) {
      if (!mounted) return;
      
      setState(() {
        _status = steps[i]['status'] as String;
      });

      double targetProgress = (i + 1) / steps.length;
      double startProgress = _progress;
      int substeps = 25;
      for (int j = 0; j <= substeps; j++) {
        await Future.delayed(Duration(milliseconds: (steps[i]['duration'] as int) ~/ substeps));
        if (!mounted) return;
        setState(() {
          _progress = startProgress + (targetProgress - startProgress) * (j / substeps);
        });
      }
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
          // 1. Radial/Linear Gradient Mesh Background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.background,
                  AppColors.background.withValues(alpha: 0.95),
                  AppColors.surfaceDark.withValues(alpha: 0.3),
                  AppColors.background,
                ],
              ),
            ),
          ),
          
          // 2. Animated Ambient Glow Orbs
          Positioned(
            top: -150,
            right: -150,
            child: _buildAmbientGlow(
              color: AppColors.primary.withValues(alpha: 0.12),
              size: 450,
            ),
          ).animate().fadeIn(duration: 1200.milliseconds).scale(begin: const Offset(0.7, 0.7)),
          
          Positioned(
            bottom: -100,
            left: -100,
            child: _buildAmbientGlow(
              color: AppColors.accent.withValues(alpha: 0.08),
              size: 400,
            ),
          ).animate().fadeIn(duration: 1500.milliseconds, delay: 300.milliseconds),

          Positioned(
            top: MediaQuery.of(context).size.height * 0.3,
            left: MediaQuery.of(context).size.width * 0.1,
            child: _buildAmbientGlow(
              color: AppColors.primaryLight.withValues(alpha: 0.06),
              size: 300,
            ),
          ).animate().fadeIn(duration: 1800.milliseconds, delay: 500.milliseconds),

          // 3. Central Brand & Progress Interface
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 340),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // App Branding Logo
                  _buildBrandLogoSection(),
                  
                  const SizedBox(height: 64),
                  
                  // Glassmorphic Loading Console Card
                  _buildLoadingConsole(),
                ],
              ),
            ),
          ),
          
          // 4. Premium Footer
          Positioned(
            bottom: 48,
            left: 0,
            right: 0,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'SERVIQ ORCHESTRATOR',
                    style: GoogleFonts.plusJakartaSans(
                      color: AppColors.primary.withValues(alpha: 0.6),
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'AGENTIC MATCHING SUITE • v1.1.0',
                    style: GoogleFonts.inter(
                      color: AppColors.textDisabled,
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 1500.milliseconds, duration: 800.milliseconds),
          ),
        ],
      ),
    );
  }

  Widget _buildBrandLogoSection() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Pulsing outer shadow wrapper
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.15),
                blurRadius: 40,
                spreadRadius: 5,
              ),
            ],
          ),
          child: const AppLogo(size: 38, showText: false),
        )
        .animate(onPlay: (controller) => controller.repeat(reverse: true))
        .scale(
          duration: 3.seconds,
          begin: const Offset(1.0, 1.0),
          end: const Offset(1.04, 1.04),
          curve: Curves.easeInOut,
        ),
        
        const SizedBox(height: 24),
        
        Text(
          'SERVIQ',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 32,
            fontWeight: FontWeight.w900,
            color: AppColors.primary,
            letterSpacing: 6,
          ),
        ).animate().fadeIn(duration: 800.milliseconds).slideY(begin: 0.2, end: 0, curve: Curves.easeOutCubic),
        
        const SizedBox(height: 6),
        
        Text(
          'LOCAL SERVICE ORCHESTRATOR',
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: AppColors.textSecondary.withValues(alpha: 0.7),
            letterSpacing: 1.5,
          ),
        ).animate().fadeIn(duration: 1000.milliseconds, delay: 200.milliseconds).slideY(begin: 0.2, end: 0, curve: Curves.easeOutCubic),
      ],
    );
  }

  Widget _buildLoadingConsole() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.8), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.04),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Premium Progress Bar Track & Glow Head
              Stack(
                children: [
                  Container(
                    width: double.infinity,
                    height: 6,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceDark.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  FractionallySizedBox(
                    widthFactor: _progress,
                    child: Container(
                      height: 6,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primary.withValues(alpha: 0.6),
                            AppColors.primary,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            blurRadius: 6,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 18),
              
              // Status text
              SizedBox(
                height: 20,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  transitionBuilder: (child, animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.15),
                          end: Offset.zero,
                        ).animate(animation),
                        child: child,
                      ),
                    );
                  },
                  child: Text(
                    _status,
                    key: ValueKey(_status),
                    textAlign: TextAlign.center,
                    style: GoogleFonts.plusJakartaSans(
                      color: AppColors.textPrimary.withValues(alpha: 0.8),
                      fontSize: 13,
                      letterSpacing: 0.2,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(delay: 800.milliseconds, duration: 600.milliseconds).slideY(begin: 0.15, end: 0, curve: Curves.easeOutCubic);
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
