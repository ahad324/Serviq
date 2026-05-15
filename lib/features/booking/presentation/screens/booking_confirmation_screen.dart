import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:serviq/core/theme/app_colors.dart';
import 'package:serviq/core/widgets/premium_widgets.dart';
import 'package:serviq/features/input/presentation/providers/input_provider.dart';

class BookingConfirmationScreen extends ConsumerWidget {
  const BookingConfirmationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingState = ref.watch(serviceBookingProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: bookingState.when(
          data: (booking) {
            if (booking == null) return const SizedBox.shrink();
            
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const AppLogo(size: 14),
                      const Spacer(),
                      _buildSuccessIcon(),
                      const SizedBox(height: 32),
                      _buildConfirmationText(booking),
                      const SizedBox(height: 48),
                      _buildBookingCard(booking),
                      const Spacer(),
                      PremiumButton(
                        text: 'Track Service Status',
                        icon: Icons.local_shipping_rounded,
                        onPressed: () => context.go('/tracking'),
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () => context.go('/'),
                        child: Text(
                          'Back to Home',
                          style: GoogleFonts.inter(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
          error: (e, st) => Center(child: Text('Error: $e')),
        ),
      ),
    );
  }

  Widget _buildSuccessIcon() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.success.withOpacity(0.1),
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.success.withOpacity(0.2), width: 2),
      ),
      child: const Icon(
        Icons.check_rounded,
        size: 80,
        color: AppColors.success,
      ),
    ).animate().scale(duration: 800.ms, curve: Curves.elasticOut);
  }

  Widget _buildConfirmationText(dynamic booking) {
    final confirmedAt = booking.lifecycle.confirmed.at;
    final confirmedTime = confirmedAt ?? DateTime.now();
    final timeStr = '${confirmedTime.hour.toString().padLeft(2, '0')}:${confirmedTime.minute.toString().padLeft(2, '0')}';
    
    return Column(
      children: [
        Text(
          'Booking Confirmed!',
          style: GoogleFonts.inter(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            color: AppColors.textPrimary,
            letterSpacing: -0.5,
          ),
        ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),
        const SizedBox(height: 12),
        Text(
          'Accepted at $timeStr',
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 15,
            color: AppColors.textSecondary,
            height: 1.5,
            fontWeight: FontWeight.w500,
          ),
        ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1),
      ],
    );
  }

  Widget _buildBookingCard(dynamic booking) {
    return PremiumCard(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.receipt_long_rounded, color: AppColors.primary, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'BOOKING ID',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primary,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  booking.id,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.1);
  }
}
