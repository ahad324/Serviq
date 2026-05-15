import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:serviq/core/theme/app_colors.dart';
import 'package:serviq/core/widgets/premium_widgets.dart';
import 'package:serviq/features/input/presentation/providers/input_provider.dart';
import 'package:serviq/features/common/domain/models/booking_model.dart' as models;

class AIUnderstandingScreen extends ConsumerStatefulWidget {
  const AIUnderstandingScreen({super.key});

  @override
  ConsumerState<AIUnderstandingScreen> createState() => _AIUnderstandingScreenState();
}

class _AIUnderstandingScreenState extends ConsumerState<AIUnderstandingScreen> {
  bool _analysisComplete = false;
  int _messageIndex = 0;
  late Timer _timer;

  final List<String> _analysisMessages = [
    'Deconstructing your service request...',
    'Analyzing context and specific requirements...',
    'Optimizing search parameters for repair...',
    'Scanning nearby high-rated providers...',
    'Verifying provider availability and skillsets...',
    'Comparing competitive pricing models...',
    'Filtering for the best value matches...',
    'Finalizing recommended provider...',
  ];

  @override
  void initState() {
    super.initState();
    _startMessageCycle();
  }

  void _startMessageCycle() {
    _timer = Timer.periodic(const Duration(milliseconds: 2000), (timer) {
      if (mounted) {
        setState(() {
          _messageIndex = (_messageIndex + 1) % _analysisMessages.length;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bookingState = ref.watch(serviceBookingProvider);

    // Auto-navigate when complete
    ref.listen(serviceBookingProvider, (previous, next) {
      if (next.hasValue && next.value != null && _analysisComplete) {
        context.go('/tracking');
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Background Glow
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
            ).animate().fadeIn(duration: 1.seconds).scale(begin: const Offset(0.5, 0.5)),
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
                      const AppLogo(size: 14),
                      const Spacer(),
                      _buildAnimatedBrain(bookingState.isLoading),
                      const SizedBox(height: 60),
                      _buildThoughtSection(bookingState),
                      const Spacer(),
                      _buildFooter(bookingState),
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

  Widget _buildAnimatedBrain(bool isLoading) {
    return Container(
      width: 160,
      height: 160,
      decoration: BoxDecoration(
        color: AppColors.surface,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.1),
            blurRadius: 40,
            spreadRadius: 10,
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (isLoading)
            SizedBox(
              width: 140,
              height: 140,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary.withValues(alpha: 0.3)),
              ),
            ).animate(onPlay: (c) => c.repeat()).rotate(duration: 3.seconds),
          
          const Icon(
            Icons.psychology_rounded,
            size: 80,
            color: AppColors.primary,
          ).animate(onPlay: (c) => c.repeat())
           .shimmer(duration: 2.seconds, color: Colors.white.withValues(alpha: 0.4)),
          
          // Pulsing Ring
          if (isLoading)
            Container(
              width: 20,
              height: 20,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
            ).animate(onPlay: (controller) => controller.repeat())
             .scale(begin: const Offset(1, 1), end: const Offset(4, 4), duration: 1500.milliseconds)
             .fadeOut(duration: 1500.milliseconds),
        ],
      ),
    ).animate().fadeIn(duration: 800.milliseconds).scale(delay: 200.milliseconds);
  }

  Widget _buildThoughtSection(AsyncValue<models.Booking?> state) {
    return Column(
      children: [
        Text(
          'AI COGNITION ENGINE',
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w900,
            color: AppColors.primary,
            letterSpacing: 2,
          ),
        ).animate().fadeIn(),
        const SizedBox(height: 20),
        
        state.when(
          data: (booking) {
            if (booking == null) return _buildCyclingMessages();
            return _buildReasoningBox(booking.decisionReasoning.selectedBecause);
          },
          loading: () => _buildCyclingMessages(),
          error: (err, _) => Text(
            'Cognition Interrupted: ${err.toString()}',
            style: GoogleFonts.inter(color: AppColors.error),
          ),
        ),
      ],
    );
  }

  Widget _buildCyclingMessages() {
    return SizedBox(
      height: 40,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: animation.drive(Tween(begin: const Offset(0, 0.3), end: Offset.zero)),
              child: child,
            ),
          );
        },
        child: Text(
          _analysisMessages[_messageIndex],
          key: ValueKey(_messageIndex),
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
            letterSpacing: -0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildReasoningBox(String reasoning) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.auto_awesome, size: 16, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                'STRATEGIC DECISION',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TypewriterText(
            text: reasoning,
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
          ),
        ],
      ),
    ).animate().fadeIn().scale(begin: const Offset(0.95, 0.95));
  }

  Widget _buildFooter(AsyncValue<models.Booking?> state) {
    return Column(
      children: [
        if (state.isLoading) ...[
          LinearProgressIndicator(
            backgroundColor: AppColors.surfaceDark,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
            borderRadius: BorderRadius.circular(10),
          ).animate().shimmer(duration: 2.seconds, color: Colors.white24),
          const SizedBox(height: 16),
        ],
        
        if (_analysisComplete)
          PremiumButton(
            text: 'Track Provider',
            icon: Icons.map_rounded,
            onPressed: () => context.go('/tracking'),
          ).animate().fadeIn().moveY(begin: 20, end: 0)
        else
          Text(
            state.isLoading ? 'Processing neural nodes...' : 'Verification complete',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: AppColors.textDisabled,
              fontWeight: FontWeight.w500,
            ),
          ),
      ],
    ).animate().fadeIn(delay: 600.milliseconds);
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
