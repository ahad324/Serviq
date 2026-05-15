import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:serviq/core/theme/app_colors.dart';
import 'package:serviq/core/widgets/premium_widgets.dart';
import 'package:serviq/features/input/presentation/providers/input_provider.dart';
import 'package:serviq/features/input/domain/models/booking_model.dart' as models;

class AIUnderstandingScreen extends ConsumerStatefulWidget {
  const AIUnderstandingScreen({super.key});

  @override
  ConsumerState<AIUnderstandingScreen> createState() => _AIUnderstandingScreenState();
}

class _AIUnderstandingScreenState extends ConsumerState<AIUnderstandingScreen> {
  bool _analysisComplete = false;
  int _currentStep = 0;
  final List<String> _steps = [
    'Analyzing your request...',
    'Matching with local experts...',
    'Estimating the best rates...',
    'Finalizing details...',
  ];

  @override
  void initState() {
    super.initState();
    _startSteps();
  }

  void _startSteps() async {
    for (int i = 0; i < _steps.length; i++) {
      await Future.delayed(const Duration(milliseconds: 1500));
      if (mounted) {
        setState(() {
          _currentStep = i;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bookingState = ref.watch(serviceBookingProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Background Gradient
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.topRight,
                  radius: 1.5,
                  colors: [
                    AppColors.primary.withOpacity(0.05),
                    AppColors.background,
                  ],
                ),
              ),
            ),
          ),
          
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildAnalysisIcon(bookingState.isLoading),
                      const SizedBox(height: 48),
                      Text(
                        bookingState.isLoading ? 'Processing Request' : 'Analysis Complete',
                        style: GoogleFonts.outfit(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ).animate().fadeIn().scale(),
                      const SizedBox(height: 16),
                      
                      // Animated Step Text
                      SizedBox(
                        height: 24,
                        child: AnimatedSwitcher(
                          duration: 500.ms,
                          transitionBuilder: (child, animation) => FadeTransition(
                            opacity: animation,
                            child: SlideTransition(
                              position: Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(animation),
                              child: child,
                            ),
                          ),
                          child: Text(
                            _steps[_currentStep % _steps.length],
                            key: ValueKey(_currentStep),
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 32),
                      _buildAnalysisText(bookingState),
                      const SizedBox(height: 60),
                      
                      if (_analysisComplete)
                        PremiumButton(
                          text: 'View Best Match',
                          icon: Icons.arrow_forward_rounded,
                          onPressed: () => context.go('/confirmation'),
                        ).animate().fadeIn().moveY(begin: 20, end: 0)
                      else if (bookingState.hasError)
                         PremiumButton(
                          text: 'Try Again',
                          icon: Icons.refresh_rounded,
                          onPressed: () => context.go('/input'),
                        ).animate().fadeIn(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisIcon(bool isLoading) {
    return Container(
      width: 140,
      height: 140,
      decoration: BoxDecoration(
        color: AppColors.surface,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.1),
            blurRadius: 30,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (isLoading)
            const PremiumLoadingIndicator(size: 140)
          else
            const Icon(
              Icons.check_rounded,
              color: AppColors.primary,
              size: 60,
            ).animate().scale(duration: 400.ms, curve: Curves.backOut),
            
          const Icon(
            Icons.psychology_rounded,
            color: AppColors.primary,
            size: 48,
          ).animate(onPlay: (c) => c.repeat())
           .shimmer(duration: 2.seconds, color: Colors.white.withOpacity(0.5)),
        ],
      ),
    );
  }

  Widget _buildAnalysisText(AsyncValue<models.Booking?> state) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.surfaceDark.withOpacity(0.5)),
      ),
      child: state.when(
        data: (booking) {
          if (booking == null) return const Text('Waiting for request...');
          return TypewriterText(
            text: booking.decisionReasoning.selectedBecause,
            style: GoogleFonts.inter(
              fontSize: 16,
              height: 1.6,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
            onComplete: () {
              setState(() {
                _analysisComplete = true;
              });
            },
          );
        },
        loading: () => Text(
          'Analyzing your request, finding the best service providers, and checking availability...',
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 16,
            height: 1.6,
            color: AppColors.textSecondary,
            fontStyle: FontStyle.italic,
          ),
        ).animate(onPlay: (c) => c.repeat()).shimmer(duration: 2.seconds),
        error: (error, stack) => Text(
          'Error: ${error.toString()}',
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 14,
            color: AppColors.error,
          ),
        ),
      ),
    );
  }
}

class TypewriterText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final Duration speed;
  final VoidCallback? onComplete;

  const TypewriterText({
    super.key,
    required this.text,
    this.style,
    this.speed = const Duration(milliseconds: 30),
    this.onComplete,
  });

  @override
  State<TypewriterText> createState() => _TypewriterTextState();
}

class _TypewriterTextState extends State<TypewriterText> {
  String _displayedText = '';
  Timer? _timer;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _startTyping();
  }

  void _startTyping() {
    if (widget.text.isEmpty) {
      widget.onComplete?.call();
      return;
    }
    
    _timer = Timer.periodic(widget.speed, (timer) {
      if (_currentIndex < widget.text.length) {
        if (mounted) {
          setState(() {
            _displayedText += widget.text[_currentIndex];
            _currentIndex++;
          });
        }
      } else {
        timer.cancel();
        widget.onComplete?.call();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _displayedText,
      style: widget.style,
      textAlign: TextAlign.center,
    );
  }
}
