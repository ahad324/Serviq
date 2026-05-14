import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/premium_widgets.dart';
import '../../../input/presentation/providers/input_provider.dart';

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
            
            // Auto-navigate to provider list after a short delay to show "Understanding"
            Future.delayed(const Duration(seconds: 3), () {
              if (context.mounted) context.go('/provider-list');
            });

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),
                  _buildAILoader(),
                  const SizedBox(height: 48),
                  _buildAnalysisText(booking),
                  const Spacer(),
                  _buildConfidenceMeter(booking.meta.confidence),
                ],
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, st) => Center(child: Text('Error: $e')),
        ),
      ),
    );
  }

  Widget _buildAILoader() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.auto_awesome_rounded,
        size: 50,
        color: AppColors.primary,
      ).animate(onPlay: (controller) => controller.repeat())
       .scale(duration: 1.seconds, begin: const Offset(0.8, 0.8), end: const Offset(1.2, 1.2), curve: Curves.easeInOut)
       .then().scale(duration: 1.seconds, begin: const Offset(1.2, 1.2), end: const Offset(0.8, 0.8), curve: Curves.easeInOut),
    );
  }

  Widget _buildAnalysisText(dynamic booking) {
    return Column(
      children: [
        Text(
          'Analyzing Intent',
          style: GoogleFonts.inter(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ).animate().fadeIn().slideY(begin: 0.1),
        const SizedBox(height: 16),
        PremiumCard(
          padding: const EdgeInsets.all(20),
          child: Text(
            'Extracted service: ${booking.service.toUpperCase()}\n\n"Checking available providers in your area for the requested time."',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ).animate().fadeIn(delay: 300.ms).scale(),
      ],
    );
  }

  Widget _buildConfidenceMeter(double confidence) {
    return Column(
      children: [
        Text(
          'AI Confidence: ${(confidence * 100).toInt()}%',
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textDisabled,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: 200,
          height: 6,
          decoration: BoxDecoration(
            color: AppColors.surfaceDark,
            borderRadius: BorderRadius.circular(3),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: confidence,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),
      ],
    ).animate().fadeIn(delay: 600.ms);
  }
}
