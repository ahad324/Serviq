import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:serviq/core/theme/app_colors.dart';
import 'package:serviq/core/widgets/premium_widgets.dart';

class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const AppLogo(size: 16),
                const Spacer(),
                _buildErrorIllustration(),
                const SizedBox(height: 48),
                _buildErrorText(),
                const SizedBox(height: 48),
                PremiumButton(
                  text: 'Back to Safety',
                  icon: Icons.home_rounded,
                  onPressed: () => context.go('/home'),
                ),
                const Spacer(),
                Text(
                  'Error 404: Location Not Found',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDisabled,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorIllustration() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 200,
          height: 200,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.05),
            shape: BoxShape.circle,
          ),
        ).animate(onPlay: (c) => c.repeat())
         .scale(duration: 2.seconds, begin: const Offset(1, 1), end: const Offset(1.2, 1.2), curve: Curves.easeInOut)
         .then()
         .scale(duration: 2.seconds, begin: const Offset(1.2, 1.2), end: const Offset(1, 1), curve: Curves.easeInOut),
        
        Container(
          width: 140,
          height: 140,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
        ),

        const Icon(
          Icons.explore_off_rounded,
          size: 80,
          color: AppColors.primary,
        ).animate(onPlay: (c) => c.repeat())
         .rotate(duration: 5.seconds, end: 1),
      ],
    );
  }

  Widget _buildErrorText() {
    return Column(
      children: [
        Text(
          'Lost in the Cloud?',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
            letterSpacing: -1,
          ),
        ).animate().fadeIn(delay: 200.milliseconds).slideY(begin: 0.2),
        const SizedBox(height: 16),
        Text(
          'It seems you\'ve ventured into uncharted territory. This page doesn\'t exist in our service network.',
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 16,
            color: AppColors.textSecondary,
            height: 1.6,
            fontWeight: FontWeight.w500,
          ),
        ).animate().fadeIn(delay: 400.milliseconds).slideY(begin: 0.2),
      ],
    );
  }
}
