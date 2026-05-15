import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:serviq/core/theme/app_colors.dart';
import 'package:serviq/core/widgets/premium_widgets.dart';
import 'package:serviq/features/tracking/presentation/providers/tracking_provider.dart';
import 'package:serviq/features/tracking/presentation/providers/tracking_state.dart';

class TrackingScreen extends ConsumerWidget {
  const TrackingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tracking = ref.watch(trackingProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildStatusCard(tracking),
                        const SizedBox(height: 32),
                        _buildTimeline(tracking),
                        const SizedBox(height: 32),
                        _buildProviderCard(tracking),
                      ],
                    ),
                  ),
                ),
                _buildActionButtons(tracking),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return const Padding(
      padding: EdgeInsets.all(24),
      child: Row(
        children: [
          AppLogo(size: 10),
          Spacer(),
          StatusBadge(text: 'LIVE TRACKING'),
        ],
      ),
    );
  }

  Widget _buildStatusCard(TrackingState tracking) {
    String statusText = '';
    String subText = '';
    
    switch (tracking.status) {
      case TrackingStatus.confirmed:
        statusText = 'Booking Confirmed';
        subText = 'We are assigning your professional';
        break;
      case TrackingStatus.enRoute:
        statusText = 'Professional En Route';
        subText = 'Arriving in approx. 15 mins';
        break;
      case TrackingStatus.arrived:
        statusText = 'Professional Arrived';
        subText = 'Checking in at your location';
        break;
      case TrackingStatus.working:
        statusText = 'Service in Progress';
        subText = 'Estimating 30 mins to finish';
        break;
      case TrackingStatus.completed:
        statusText = 'Service Completed';
        subText = 'Hope you enjoyed the service!';
        break;
    }

    return PremiumCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      statusText,
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subText,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              if (tracking.status != TrackingStatus.completed)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primary,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 24),
          _buildProgressBar(tracking.progress),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.1);
  }

  Widget _buildProgressBar(double progress) {
    return Stack(
      children: [
        Container(
          height: 8,
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.surfaceDark,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          height: 8,
          width: progress * 500, // Roughly proportional
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primary, AppColors.secondary],
            ),
            borderRadius: BorderRadius.circular(4),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTimeline(TrackingState tracking) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'SERVICE JOURNEY',
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w900,
            color: AppColors.textDisabled,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 20),
        _buildTimelineItem('Booking Confirmed', 'Done', isDone: true),
        _buildTimelineItem(
          'Professional En Route', 
          'In Transit', 
          isDone: tracking.status.index >= TrackingStatus.enRoute.index,
          isActive: tracking.status == TrackingStatus.enRoute,
        ),
        _buildTimelineItem(
          'Service Started', 
          'Working', 
          isDone: tracking.status.index >= TrackingStatus.working.index,
          isActive: tracking.status == TrackingStatus.working,
        ),
        _buildTimelineItem(
          'Completion', 
          'Success', 
          isDone: tracking.status == TrackingStatus.completed,
          isActive: tracking.status == TrackingStatus.completed,
          isLast: true,
        ),
      ],
    );
  }

  Widget _buildTimelineItem(String title, String status, {required bool isDone, bool isActive = false, bool isLast = false}) {
    return IntrinsicHeight(
      child: Row(
        children: [
          Column(
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: isDone ? AppColors.primary : (isActive ? AppColors.primary.withOpacity(0.3) : AppColors.surfaceDark),
                  shape: BoxShape.circle,
                  border: isActive ? Border.all(color: AppColors.primary, width: 2) : null,
                ),
                child: isDone ? const Icon(Icons.check, size: 10, color: Colors.white) : null,
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: isDone ? AppColors.primary : AppColors.surfaceDark,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: isDone || isActive ? FontWeight.w700 : FontWeight.w500,
                    color: isDone || isActive ? AppColors.textPrimary : AppColors.textDisabled,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  status,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: isDone || isActive ? AppColors.primary : AppColors.textDisabled,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProviderCard(TrackingState tracking) {
    return PremiumCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundImage: NetworkImage(tracking.providerImage),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tracking.providerName,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'Expert Technician',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.phone_in_talk_rounded, color: AppColors.primary),
            style: IconButton.styleFrom(
              backgroundColor: AppColors.primary.withOpacity(0.1),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.chat_bubble_rounded, color: AppColors.secondary),
            style: IconButton.styleFrom(
              backgroundColor: AppColors.secondary.withOpacity(0.1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(TrackingState tracking) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Expanded(
            child: PremiumButton(
              text: tracking.status == TrackingStatus.completed ? 'Service Finished' : 'Cancel Booking',
              onPressed: () {},
              color: tracking.status == TrackingStatus.completed ? AppColors.success : AppColors.error,
              icon: tracking.status == TrackingStatus.completed ? Icons.check : Icons.close,
            ),
          ),
        ],
      ),
    );
  }
}
