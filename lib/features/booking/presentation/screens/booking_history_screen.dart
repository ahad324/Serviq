import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:serviq/core/theme/app_colors.dart';
import 'package:serviq/core/widgets/premium_widgets.dart';
import 'package:serviq/features/auth/presentation/providers/session_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BookingHistoryScreen extends ConsumerWidget {
  const BookingHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(sessionNotifierProvider);
    final supabase = Supabase.instance.client;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(24.0),
              child: ScreenHeader(
                title: 'Booking History',
                subtitle: 'Your recent and past service requests',
              ),
            ),
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: supabase
                    .from('Bookings')
                    .select()
                    .eq('user_id', user?.id ?? '')
                    .order('created_at', ascending: false),
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
                          Icon(Icons.history_rounded, size: 64, color: AppColors.textDisabled.withOpacity(0.5)),
                          const SizedBox(height: 16),
                          Text(
                            'No bookings found',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    itemCount: bookings.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final booking = bookings[index];
                      return _BookingCard(booking: booking);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  final Map<String, dynamic> booking;

  const _BookingCard({required this.booking});

  @override
  Widget build(BuildContext context) {
    final status = booking['status'] as String;
    final date = DateTime.parse(booking['created_at'].toString());
    
    return PremiumCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                booking['service_type']?.toString().toUpperCase() ?? 'SERVICE',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primary,
                  letterSpacing: 1.2,
                ),
              ),
              _StatusChip(status: status),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            booking['address'] ?? 'Location not specified',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.calendar_today_rounded, size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 6),
              Text(
                '${date.day}/${date.month}/${date.year}',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: 16),
              const Icon(Icons.access_time_rounded, size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 6),
              Text(
                '${date.hour}:${date.minute.toString().padLeft(2, '0')}',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status) {
      case 'completed':
        color = AppColors.success;
        break;
      case 'confirmed':
        color = AppColors.info;
        break;
      case 'en_route':
      case 'arrived':
      case 'in_progress':
        color = AppColors.warning;
        break;
      default:
        color = AppColors.textDisabled;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Text(
        status.replaceAll('_', ' ').toUpperCase(),
        style: GoogleFonts.inter(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: color,
        ),
      ),
    );
  }
}
