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

  @override
  Widget build(BuildContext context) {
    final bookingState = ref.watch(serviceBookingProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
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
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 24),
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
    );
  }

  Widget _buildAnalysisIcon(bool isLoading) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
        )
            .animate(onPlay: (controller) => controller.repeat())
            .scale(begin: const Offset(1, 1), end: const Offset(1.2, 1.2), duration: 2.seconds, curve: Curves.easeInOut)
            .then()
            .scale(begin: const Offset(1.2, 1.2), end: const Offset(1, 1), duration: 2.seconds, curve: Curves.easeInOut),
        
        Container(
          width: 80,
          height: 80,
          decoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary,
                blurRadius: 20,
                spreadRadius: -5,
              ),
            ],
          ),
          child: Icon(
            isLoading ? Icons.psychology_rounded : Icons.check_rounded,
            color: Colors.white,
            size: 40,
          ),
        ),
      ],
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
