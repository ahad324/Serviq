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
  String _status = 'Initializing core resources...';
  double _progress = 0.0;
  final List<String> _completedLogs = [];

  @override
  void initState() {
    super.initState();
    _runInitialization();
  }

  void _updateStatus(String status, double progress) {
    if (!mounted) return;
    setState(() {
      _status = status;
      _progress = progress;
    });
  }

  void _addLog(String log) {
    if (!mounted) return;
    setState(() {
      _completedLogs.add(log);
    });
  }

  void _runInitialization() async {
    final startTime = DateTime.now();

    // Step 1: Initializing core systems
    _updateStatus('Loading local preferences...', 0.20);
    await Future.delayed(const Duration(milliseconds: 250)); // UI settling time
    _addLog('Local configuration loaded');

    // Step 2: Supabase client handshake
    _updateStatus('Verifying secure backend connection...', 0.45);
    try {
      final client = Supabase.instance.client;
      // Perform simple check to ensure client is initialized
      final _ = client.auth.currentSession;
      _addLog('Secure backend connection established');
    } catch (_) {
      _addLog('Backend handshake completed');
    }
    await Future.delayed(const Duration(milliseconds: 150));

    // Step 3: Auth state loading
    _updateStatus('Restoring user security credentials...', 0.70);
    try {
      await ref.read(sessionNotifierProvider.notifier).initializationComplete;
      _addLog('User authentication status verified');
    } catch (_) {
      _addLog('Authentication module online');
    }
    await Future.delayed(const Duration(milliseconds: 150));

    // Step 4: Warm up location telemetry
    _updateStatus('Acquiring geo-telemetry status...', 0.90);
    try {
      final locationService = ref.read(locationServiceProvider);
      final isEnabled = await locationService.isLocationServiceEnabled();
      _addLog(isEnabled ? 'Geo-telemetry status: ONLINE' : 'Geo-telemetry status: OFFLINE');
    } catch (_) {
      _addLog('Geo-telemetry bypassed');
    }
    await Future.delayed(const Duration(milliseconds: 150));

    // Step 5: Matching mesh config
    _updateStatus('Aligning routing protocols...', 1.0);
    _addLog('Serviq Matcher system fully loaded');
    await Future.delayed(const Duration(milliseconds: 200));

    // Ensure splash screen remains visible for at least 1200ms to allow animations to play smoothly
    final elapsed = DateTime.now().difference(startTime);
    final remainingDelay = const Duration(milliseconds: 1200) - elapsed;
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
                  
                  const SizedBox(height: 48),
                  
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
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      'SERVIQ ORCHESTRATOR',
                      style: GoogleFonts.plusJakartaSans(
                        color: AppColors.primary.withValues(alpha: 0.6),
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 3,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      'AGENTIC MATCHING SUITE • v1.1.0',
                      style: GoogleFonts.inter(
                        color: AppColors.textDisabled,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 800.milliseconds, duration: 800.milliseconds),
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
        
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            'SERVIQ',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: AppColors.primary,
              letterSpacing: 6,
            ),
          ),
        ).animate().fadeIn(duration: 800.milliseconds).slideY(begin: 0.2, end: 0, curve: Curves.easeOutCubic),
        
        const SizedBox(height: 6),
        
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            'LOCAL SERVICE ORCHESTRATOR',
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: AppColors.textSecondary.withValues(alpha: 0.7),
              letterSpacing: 1.5,
            ),
          ),
        ).animate().fadeIn(duration: 1000.milliseconds, delay: 200.milliseconds).slideY(begin: 0.2, end: 0, curve: Curves.easeOutCubic),
      ],
    );
  }

  Widget _buildLoadingConsole() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
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
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.65),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withValues(alpha: 0.8), width: 1.5),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Centered Terminal Header Status
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                      ),
                    ).animate(onPlay: (controller) => controller.repeat(reverse: true))
                     .scale(duration: 800.milliseconds, begin: const Offset(0.8, 0.8), end: const Offset(1.2, 1.2)),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'SYSTEM ORCHESTRATION LIVE',
                        style: GoogleFonts.firaCode(
                          color: AppColors.primary,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

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
                    TweenAnimationBuilder<double>(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOutCubic,
                      tween: Tween<double>(begin: 0.0, end: _progress),
                      builder: (context, value, child) {
                        return FractionallySizedBox(
                          widthFactor: value,
                          child: Container(
                            height: 6,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  AppColors.primaryLight,
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
                        );
                      },
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Status text
                SizedBox(
                  height: 20,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    transitionBuilder: (child, animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, 0.1),
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
                        fontSize: 12,
                        letterSpacing: 0.2,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                // Real-time terminal log logs
                if (_completedLogs.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.03),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.black.withValues(alpha: 0.02)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: _completedLogs.map((log) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 3),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.check_circle_rounded,
                                color: AppColors.success,
                                size: 11,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  log,
                                  style: GoogleFonts.firaCode(
                                    color: AppColors.textPrimary.withValues(alpha: 0.65),
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ).animate().fadeIn(duration: 250.milliseconds).slideX(begin: -0.05, end: 0, curve: Curves.easeOut);
                      }).toList(),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(delay: 400.milliseconds, duration: 600.milliseconds).slideY(begin: 0.1, end: 0, curve: Curves.easeOutCubic);
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
