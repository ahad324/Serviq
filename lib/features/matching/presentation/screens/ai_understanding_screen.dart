import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:serviq/core/theme/app_colors.dart';
import 'package:serviq/core/widgets/premium_widgets.dart';
import 'package:serviq/features/input/presentation/providers/input_provider.dart';

class AIUnderstandingScreen extends ConsumerWidget {
  const AIUnderstandingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingState = ref.watch(serviceBookingProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: bookingState.when(
          data: (booking) {
            if (booking == null) return const SizedBox.shrink();
            
            // Auto-navigate to provider list after analysis
            Future.delayed(const Duration(seconds: 3), () {
              if (context.mounted) context.go('/provider-list');
            });

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const AppLogo(size: 14),
                  const Spacer(),
                  _buildAILoader(),
                  const SizedBox(height: 48),
                  _buildAnalysisText(booking),
                  const Spacer(),
                  _buildConfidenceMeter(booking.meta.confidence),
                  const SizedBox(height: 40),
                ],
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
          error: (e, st) => Center(child: Text('Error: $e')),
        ),
      ),
    );
  }

  Widget _buildAILoader() {
    return Container(
      width: 140,
      height: 140,
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.primary.withOpacity(0.1), width: 2),
      ),
      child: Center(
        child: const Icon(
          Icons.auto_awesome_rounded,
          size: 60,
          color: AppColors.primary,
        ).animate(onPlay: (controller) => controller.repeat())
         .shimmer(duration: 2.seconds, color: Colors.white.withOpacity(0.5))
         .scale(duration: 1.seconds, begin: const Offset(0.9, 0.9), end: const Offset(1.1, 1.1), curve: Curves.easeInOut)
         .then().scale(duration: 1.seconds, begin: const Offset(1.1, 1.1), end: const Offset(0.9, 0.9), curve: Curves.easeInOut),
      ),
    );
  }

  Widget _buildAnalysisText(dynamic booking) {
    return Column(
      children: [
        Text(
          'Analyzing Intent',
          style: GoogleFonts.inter(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ).animate().fadeIn().slideY(begin: 0.1),
        const SizedBox(height: 16),
        PremiumCard(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Text(
                'Detected Service',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                booking.service.toUpperCase(),
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Matching with best available providers in Wapda Town...',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ).animate().fadeIn(delay: 300.ms).scale(begin: const Offset(0.95, 0.95)),
      ],
    );
  }

  Widget _buildConfidenceMeter(double confidence) {
    return Column(
      children: [
        Text(
          'AI CONFIDENCE: ${(confidence * 100).toInt()}%',
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w900,
            color: AppColors.textDisabled,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          width: 240,
          height: 8,
          decoration: BoxDecoration(
            color: AppColors.surfaceDark.withOpacity(0.5),
            borderRadius: BorderRadius.circular(4),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: confidence,
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primaryLight, AppColors.primary],
                ),
                borderRadius: BorderRadius.circular(4),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    ).animate().fadeIn(delay: 600.ms);
  }
}
