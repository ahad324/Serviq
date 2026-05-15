import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:serviq/core/theme/app_colors.dart';
import 'package:serviq/core/widgets/premium_widgets.dart';
import 'package:serviq/core/widgets/bottom_nav_bar.dart';
import 'package:serviq/features/input/presentation/providers/input_provider.dart';

class TrackingScreen extends ConsumerStatefulWidget {
  const TrackingScreen({super.key});

  @override
  ConsumerState<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends ConsumerState<TrackingScreen> {
  late Map<String, bool> _stepStatus;
  late Map<String, DateTime?> _stepTimes;

  @override
  void initState() {
    super.initState();
    _initializeSteps();
  }

  void _initializeSteps() {
    _stepStatus = {
      'confirmed': true,
      'en_route': true,
      'arrived': false,
      'in_progress': false,
      'completed': false,
    };
    _stepTimes = {
      'confirmed': DateTime.now(),
      'en_route': DateTime.now().add(const Duration(minutes: 3)),
      'arrived': null,
      'in_progress': null,
      'completed': null,
    };
  }

  void _markStepDone(String step) {
    setState(() {
      _stepStatus[step] = true;
      _stepTimes[step] = DateTime.now();
    });

    // Show confirmation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('✓ $step marked as done'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  String _getNextIncompleteStep() {
    final order = [
      'confirmed',
      'en_route',
      'arrived',
      'in_progress',
      'completed',
    ];
    for (String step in order) {
      if (!(_stepStatus[step] ?? false)) {
        return step;
      }
    }
    return 'completed';
  }

  @override
  Widget build(BuildContext context) {
    final bookingState = ref.watch(serviceBookingProvider);
    final nextStep = _getNextIncompleteStep();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const AppLogo(size: 18),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.textPrimary,
            size: 20,
          ),
          onPressed: () => context.pop(),
        ),
      ),
      body: bookingState.when(
        data: (booking) {
          if (booking == null) return const SizedBox.shrink();

          final lifecycle = booking.lifecycle;
          final confirmedAt = lifecycle.confirmed.at ?? DateTime.now();
          final etaTime =
              lifecycle.arrival.eta ??
              confirmedAt.add(const Duration(minutes: 15));
          final etaStr =
              '${etaTime.hour.toString().padLeft(2, '0')}:${etaTime.minute.toString().padLeft(2, '0')} Today';

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 600),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 20,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildStatusBanner(
                              lifecycle.enRoute.message ??
                                  'Provider is en-route',
                              nextStep,
                            ),
                            const SizedBox(height: 40),
                            Text(
                              'SERVICE TIMELINE',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w900,
                                color: AppColors.textDisabled,
                                letterSpacing: 1.5,
                              ),
                            ),
                            const SizedBox(height: 24),
                            _buildTimeline(lifecycle, nextStep),
                            const SizedBox(height: 40),
                            PremiumCard(
                              padding: const EdgeInsets.all(20),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(
                                      Icons.access_time_filled_rounded,
                                      color: AppColors.primary,
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Estimated Arrival',
                                        style: GoogleFonts.inter(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                      Text(
                                        etaStr,
                                        style: GoogleFonts.inter(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w900,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 40),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              BottomNavBar(currentRoute: '/tracking'),
            ],
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildStatusBanner(String message, String nextStep) {
    final stepLabels = {
      'confirmed': 'Booking Confirmed',
      'en_route': 'En Route',
      'arrived': 'Arrived',
      'in_progress': 'In Progress',
      'completed': 'Completed',
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.sensors, color: Colors.white70, size: 16),
              const SizedBox(width: 8),
              Text(
                'LIVE TRACKING',
                style: GoogleFonts.inter(
                  color: Colors.white70,
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w900,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Next: ${stepLabels[nextStep] ?? 'Complete'}',
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: -0.1);
  }

  Widget _buildTimeline(dynamic lifecycle, String nextStep) {
    return Column(
      children: [
        _buildTimelineItem(
          'Booking Confirmed',
          _stepStatus['confirmed'] ?? false,
          isFirst: true,
          isNext: nextStep == 'confirmed',
          onMarkDone: () => _markStepDone('confirmed'),
          time: _stepTimes['confirmed'],
        ),
        _buildTimelineItem(
          'Ali Repairs is En Route',
          _stepStatus['en_route'] ?? false,
          isNext: nextStep == 'en_route',
          onMarkDone: () => _markStepDone('en_route'),
          time: _stepTimes['en_route'],
        ),
        _buildTimelineItem(
          'Arrival at Location',
          _stepStatus['arrived'] ?? false,
          isNext: nextStep == 'arrived',
          onMarkDone: () => _markStepDone('arrived'),
          time: _stepTimes['arrived'],
        ),
        _buildTimelineItem(
          'Service In Progress',
          _stepStatus['in_progress'] ?? false,
          isNext: nextStep == 'in_progress',
          onMarkDone: () => _markStepDone('in_progress'),
          time: _stepTimes['in_progress'],
        ),
        _buildTimelineItem(
          'Service Completed',
          _stepStatus['completed'] ?? false,
          isLast: true,
          isNext: nextStep == 'completed',
          onMarkDone: () => _markStepDone('completed'),
          time: _stepTimes['completed'],
        ),
      ],
    );
  }

  Widget _buildTimelineItem(
    String label,
    bool isCompleted, {
    bool isFirst = false,
    bool isLast = false,
    bool isNext = false,
    VoidCallback? onMarkDone,
    DateTime? time,
  }) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? AppColors.primary
                        : (isNext ? AppColors.accent : AppColors.background),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isCompleted
                          ? AppColors.primary
                          : (isNext ? AppColors.accent : AppColors.surfaceDark),
                      width: 2,
                    ),
                  ),
                  child: isCompleted
                      ? const Icon(Icons.check, size: 14, color: Colors.white)
                      : (isNext
                            ? const Icon(
                                Icons.play_arrow,
                                size: 12,
                                color: AppColors.accent,
                              )
                            : null),
                ),
                if (!isLast)
                  Container(
                    width: 2,
                    height: 48,
                    decoration: BoxDecoration(
                      color: isCompleted
                          ? AppColors.primary
                          : AppColors.surfaceDark,
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: isCompleted
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: isCompleted
                            ? AppColors.textPrimary
                            : AppColors.textDisabled,
                      ),
                    ),
                    if (time != null)
                      Text(
                        DateFormat('hh:mm a').format(time),
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    if (isNext && !isCompleted && onMarkDone != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: ElevatedButton.icon(
                          onPressed: onMarkDone,
                          icon: const Icon(
                            Icons.check_circle_outline,
                            size: 18,
                          ),
                          label: const Text('Mark as Done'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            textStyle: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    ).animate().fadeIn(delay: 200.ms);
  }
}
