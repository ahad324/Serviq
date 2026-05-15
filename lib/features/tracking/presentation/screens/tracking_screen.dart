import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:serviq/core/theme/app_colors.dart';
import 'package:serviq/core/widgets/premium_widgets.dart';
import 'package:serviq/features/auth/presentation/providers/session_provider.dart';

class TrackingScreen extends ConsumerStatefulWidget {
  const TrackingScreen({super.key});

  @override
  ConsumerState<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends ConsumerState<TrackingScreen> {
  bool _isUpdating = false;

  Future<void> _updateStatus(String bookingId, String nextStatus) async {
    setState(() => _isUpdating = true);
    final supabase = Supabase.instance.client;

    try {
      await supabase
          .from('Bookings')
          .update({'status': nextStatus})
          .eq('id', bookingId);

      await supabase.from('booking_logs').insert({
        'booking_id': bookingId,
        'status': nextStatus,
        'timestamp': DateTime.now().toIso8601String(),
      });

      // In a real app, we'd use a stream or refresh the provider
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('✓ Status updated to ${nextStatus.replaceAll('_', ' ')}')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating status: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isUpdating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(sessionNotifierProvider);
    final supabase = Supabase.instance.client;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: StreamBuilder<List<Map<String, dynamic>>>(
          stream: supabase
              .from('Bookings')
              .stream(primaryKey: ['id'])
              .eq('user_id', user?.id ?? '')
              .order('created_at', ascending: false)
              .limit(1),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const PremiumLoadingIndicator();
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            
            final bookings = snapshot.data ?? [];
            if (bookings.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.location_searching_rounded, size: 64, color: AppColors.textDisabled.withValues(alpha: 0.5)),
                    const SizedBox(height: 20),
                    Text(
                      'No active bookings to track',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Book a service to see live updates',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              );
            }

            final booking = bookings.first;
            final String currentStatus = booking['status'];
            final String bookingId = booking['id'];

            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 24),
                  _buildStatusCard(currentStatus),
                  const SizedBox(height: 32),
                  _buildTimeline(currentStatus),
                  const SizedBox(height: 32),
                  _buildActionButtons(bookingId, currentStatus),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        const AppLogo(size: 10),
        const Spacer(),
        const StatusBadge(text: 'LIVE TRACKING'),
      ],
    );
  }

  Widget _buildStatusCard(String status) {
    String statusTitle = '';
    String subText = '';
    double progress = 0.2;

    switch (status) {
      case 'confirmed':
        statusTitle = 'Booking Confirmed';
        subText = 'A professional is being assigned';
        progress = 0.2;
        break;
      case 'en_route':
        statusTitle = 'Professional En Route';
        subText = 'Arriving in approx. 15 mins';
        progress = 0.4;
        break;
      case 'arrived':
        statusTitle = 'Professional Arrived';
        subText = 'Ready to start the service';
        progress = 0.6;
        break;
      case 'in_progress':
        statusTitle = 'Service In Progress';
        subText = 'Your service is being handled';
        progress = 0.8;
        break;
      case 'completed':
        statusTitle = 'Service Completed';
        subText = 'Hope you had a great experience!';
        progress = 1.0;
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
                      statusTitle,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 22,
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
                      ),
                    ),
                  ],
                ),
              ),
              if (status != 'completed')
                const PremiumLoadingIndicator(size: 24),
            ],
          ),
          const SizedBox(height: 24),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: AppColors.primary.withValues(alpha: 0.1),
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
            borderRadius: BorderRadius.circular(4),
            minHeight: 8,
          ),
        ],
      ),
    );
  }

  Widget _buildTimeline(String currentStatus) {
    final steps = ['confirmed', 'en_route', 'arrived', 'in_progress', 'completed'];
    final currentIndex = steps.indexOf(currentStatus);

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
        const SizedBox(height: 24),
        ...List.generate(steps.length, (index) {
          final step = steps[index];
          final isDone = index < currentIndex;
          final isActive = index == currentIndex;
          final isLast = index == steps.length - 1;

          return _buildTimelineItem(
            step.replaceAll('_', ' ').toUpperCase(),
            isDone: isDone,
            isActive: isActive,
            isLast: isLast,
          );
        }),
      ],
    );
  }

  Widget _buildTimelineItem(String title, {required bool isDone, bool isActive = false, bool isLast = false}) {
    return IntrinsicHeight(
      child: Row(
        children: [
          Column(
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: isDone ? AppColors.primary : (isActive ? AppColors.primary.withValues(alpha: 0.2) : Colors.white),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isDone || isActive ? AppColors.primary : AppColors.textDisabled.withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
                child: isDone ? const Icon(Icons.check, size: 12, color: Colors.white) : (isActive ? Center(child: Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle))) : null),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    color: isDone ? AppColors.primary : AppColors.textDisabled.withValues(alpha: 0.1),
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
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: isDone || isActive ? FontWeight.w800 : FontWeight.w600,
                    color: isDone || isActive ? AppColors.textPrimary : AppColors.textDisabled,
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

  Widget _buildActionButtons(String bookingId, String currentStatus) {
    final steps = ['confirmed', 'en_route', 'arrived', 'in_progress', 'completed'];
    final currentIndex = steps.indexOf(currentStatus);
    
    if (currentIndex == steps.length - 1) {
      return PremiumButton(
        text: 'Rate Service',
        onPressed: () {},
        icon: Icons.star_rounded,
      );
    }

    final nextStatus = steps[currentIndex + 1];
    final buttonText = 'Mark as ${nextStatus.replaceAll('_', ' ')}';

    return Column(
      children: [
        PremiumButton(
          text: buttonText,
          onPressed: () => _updateStatus(bookingId, nextStatus),
          isLoading: _isUpdating,
          icon: Icons.double_arrow_rounded,
        ),
        const SizedBox(height: 12),
        if (currentIndex < 2) // Only allow cancellation before arrival
          TextButton(
            onPressed: () {},
            child: Text(
              'Cancel Booking',
              style: GoogleFonts.inter(color: AppColors.error, fontWeight: FontWeight.w600),
            ),
          ),
      ],
    );
  }
}
