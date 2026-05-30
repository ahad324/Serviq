import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:serviq/core/theme/app_colors.dart';
import 'package:serviq/core/widgets/premium_widgets.dart';
import 'package:serviq/features/input/presentation/providers/input_provider.dart';
import 'package:serviq/features/matching/domain/models/service_response.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:serviq/features/auth/presentation/providers/session_provider.dart';

class PricingBreakdownScreen extends ConsumerStatefulWidget {
  const PricingBreakdownScreen({super.key});

  @override
  ConsumerState<PricingBreakdownScreen> createState() => _PricingBreakdownScreenState();
}

class _PricingBreakdownScreenState extends ConsumerState<PricingBreakdownScreen> {
  bool _isBooking = false;
  bool _isAutoAssigning = false;

  /// Strips timezone info from a Supabase timestamp and parses as a naive local DateTime.
  /// e.g. "2026-05-30T13:00:00+00:00" → DateTime(2026, 5, 30, 13, 0, 0)
  DateTime? _parseDbTime(String? timeStr) {
    if (timeStr == null) return null;
    // Remove timezone suffix (+05:00, +00:00, Z, etc.) so we compare wall-clock times
    final naive = timeStr
        .replaceAll(RegExp(r'[+-]\d{2}:\d{2}$'), '')
        .replaceAll('Z', '')
        .trim();
    return DateTime.tryParse(naive);
  }

  DateTime findEarliestAvailableSlot(DateTime startTime, List<DateTime> bookedTimes) {
    final sortedBookings = List<DateTime>.from(bookedTimes)..sort();
    DateTime candidate = startTime;

    if (candidate.isBefore(DateTime.now())) {
      candidate = DateTime.now();
    }

    // Round to nearest 15 minutes
    final minutes = candidate.minute;
    final roundedMinutes = ((minutes / 15).round() * 15);
    if (roundedMinutes == 60) {
      candidate = DateTime(candidate.year, candidate.month, candidate.day, candidate.hour + 1, 0);
    } else {
      candidate = DateTime(candidate.year, candidate.month, candidate.day, candidate.hour, roundedMinutes);
    }

    bool hasConflict = true;
    while (hasConflict) {
      hasConflict = false;
      for (final bookingTime in sortedBookings) {
        final diff = bookingTime.toUtc().difference(candidate.toUtc()).inMinutes.abs();
        if (diff < 60) {
          candidate = bookingTime.add(const Duration(minutes: 60));
          hasConflict = true;
          break;
        }
      }
    }
    return candidate;
  }

  String _formatSlotTime(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final candidateDate = DateTime(dt.year, dt.month, dt.day);

    final timeStr = DateFormat('h:mm a').format(dt);

    if (candidateDate == today) {
      return 'Today at $timeStr';
    } else if (candidateDate == tomorrow) {
      return 'Tomorrow at $timeStr';
    } else {
      return '${DateFormat('EEE, MMM d').format(dt)} at $timeStr';
    }
  }

  Future<void> _handleBooking(ServiceProvider provider, ServiceResponse response) async {
    setState(() => _isBooking = true);

    try {
      final user = ref.read(sessionNotifierProvider);
      final supabase = Supabase.instance.client;

      final proposedTime = parseFlexibleTime(response.intent.preferredTime) ??
          DateTime.now().add(const Duration(hours: 1));
      final proposedTimeStr = proposedTime.toIso8601String();


      // Fetch all conflicting bookings (confirmed, en_route, arrived, in_progress)
      final existingBookings = await supabase
          .from('Bookings')
          .select('scheduled_time, status')
          .eq('provider_id', provider.id)
          .inFilter('status', ['confirmed', 'en_route', 'arrived', 'in_progress']);

      bool hasConflict = false;
      for (final booking in existingBookings) {
        final dbTimeStr = booking['scheduled_time'] as String?;
        if (dbTimeStr != null) {
          final dbTime = _parseDbTime(dbTimeStr);
          if (dbTime != null) {
            final diff = dbTime.difference(proposedTime).inMinutes.abs();
            if (diff < 60) {
              hasConflict = true;
              break;
            }
          }
        }
      }

      if (hasConflict) {
        setState(() => _isBooking = false);
        if (mounted) {
          _showConflictDialog(provider, response, proposedTime);
        }
        return;
      }

      // Proceed with booking if no conflict
      final grandTotal = provider.pricing.finalPrice.toInt();
      final insertedBooking = await supabase.from('Bookings').insert({
        'user_id': user?.id,
        'status': 'confirmed',
        'service_type': response.intent.service,
        'provider_name': provider.name,
        'total_price': grandTotal,
        'scheduled_time': proposedTimeStr,
        'urgency': response.intent.urgency,
        'address': provider.address,
        'provider_id': provider.id,
        'created_at': DateTime.now().toIso8601String(),
      }).select().single();

      final bookingId = insertedBooking['id'] as String;

      if (mounted) {
        context.go('/booking-confirmation', extra: bookingId);
      }
    } catch (e) {
      debugPrint('[ConflictCheck] ERROR: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Booking failed: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isBooking = false);
    }
  }

  void _showConflictDialog(
    ServiceProvider provider,
    ServiceResponse response,
    DateTime proposedTime,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) {
        return AlertDialog(
          backgroundColor: AppColors.background,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: AppColors.accent, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Booking Conflict',
                  style: GoogleFonts.plusJakartaSans(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${provider.name} is already booked at your requested time:',
                style: GoogleFonts.inter(
                  color: AppColors.textPrimary,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
                ),
                child: Text(
                  _formatSlotTime(proposedTime),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.firaCode(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Would you like to auto-assign another available provider, or exit?',
                style: GoogleFonts.inter(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          actionsPadding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
          actionsAlignment: MainAxisAlignment.spaceBetween,
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogCtx);
              },
              child: Text(
                'Exit',
                style: GoogleFonts.inter(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onPressed: () {
                Navigator.pop(dialogCtx); // Close the conflict dialog
                _handleAutoAssign(context, provider, response, proposedTime);
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.bolt_rounded, color: AppColors.accent, size: 18),
                  const SizedBox(width: 6),
                  Text(
                    'Auto Assign',
                    style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _handleAutoAssign(
    BuildContext ctx,
    ServiceProvider originalProvider,
    ServiceResponse response,
    DateTime proposedTime,
  ) async {
    // Show loading via state
    if (mounted) setState(() => _isAutoAssigning = true);

    try {
      final supabase = Supabase.instance.client;

      // Retrieve all conflicting bookings for THIS specific provider
      final existingBookings = await supabase
          .from('Bookings')
          .select('scheduled_time, status')
          .eq('provider_id', originalProvider.id)
          .inFilter('status', ['confirmed', 'en_route', 'arrived', 'in_progress']);

      // Hide loading
      if (mounted) setState(() => _isAutoAssigning = false);

      final List<DateTime> bookedTimes = [];
      for (final b in existingBookings) {
        final timeStr = b['scheduled_time'] as String?;
        if (timeStr != null) {
          final time = _parseDbTime(timeStr);
          if (time != null) bookedTimes.add(time);
        }
      }

      // Find the earliest available slot for THIS provider starting from proposedTime
      final nextAvailableSlot = findEarliestAvailableSlot(proposedTime, bookedTimes);


      if (mounted) {
        // Auto-assign to the same provider at the next available slot
        _confirmAutoAssignedBooking(context, originalProvider, response, nextAvailableSlot);
      }
    } catch (e) {
      debugPrint('[AutoAssign] ERROR: $e');
      if (mounted) setState(() => _isAutoAssigning = false);
      if (mounted) {
        ScaffoldMessenger.of(ctx).showSnackBar(
          SnackBar(content: Text('Auto-assign failed: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  Future<void> _confirmAutoAssignedBooking(
    BuildContext ctx,
    ServiceProvider provider,
    ServiceResponse response,
    DateTime scheduledTime,
  ) async {
    final scaffoldMessenger = ScaffoldMessenger.of(ctx);
    final router = GoRouter.of(ctx);

    setState(() => _isBooking = true);
    try {
      final user = ref.read(sessionNotifierProvider);
      final supabase = Supabase.instance.client;
      final grandTotal = provider.pricing.finalPrice.toInt();

      final insertedBooking = await supabase.from('Bookings').insert({
        'user_id': user?.id,
        'status': 'confirmed',
        'service_type': response.intent.service,
        'provider_name': provider.name,
        'total_price': grandTotal,
        'scheduled_time': scheduledTime.toIso8601String(),
        'urgency': response.intent.urgency,
        'address': provider.address,
        'provider_id': provider.id,
        'created_at': DateTime.now().toIso8601String(),
      }).select().single();

      final bookingId = insertedBooking['id'] as String;

      if (mounted) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text('Auto-assigned to ${provider.name}'),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 3),
          ),
        );
        router.go('/booking-confirmation', extra: bookingId);
      }
    } catch (e) {
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('Failed to book alternative provider: $e'), backgroundColor: AppColors.error),
      );
    } finally {
      if (mounted) setState(() => _isBooking = false);
    }
  }

  void _showAlternativesOptionsModal(
    BuildContext context,
    List<Map<String, dynamic>> options,
    ServiceResponse response,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.background,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetCtx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          expand: false,
          builder: (scrollCtx, scrollController) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.textDisabled.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Alternative Slots',
                    style: GoogleFonts.plusJakartaSans(
                      color: AppColors.primary,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'No provider is available at your requested time. Select one of these quickest slots instead:',
                    style: GoogleFonts.inter(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      itemCount: options.length,
                      itemBuilder: (listCtx, index) {
                        final option = options[index];
                        final ServiceProvider prov = option['provider'];
                        final DateTime slot = option['slot'];
                        
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: InkWell(
                            onTap: () {
                              Navigator.pop(sheetCtx); // Close sheet
                              _confirmAutoAssignedBooking(context, prov, response, slot);
                            },
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: AppColors.surfaceDark.withValues(alpha: 0.5),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withValues(alpha: 0.05),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.person_rounded,
                                      color: AppColors.primary,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          prov.name,
                                          style: GoogleFonts.inter(
                                            color: AppColors.textPrimary,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          _formatSlotTime(slot),
                                          style: GoogleFonts.firaCode(
                                            color: AppColors.primary,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 11,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.star_rounded,
                                              color: AppColors.accent,
                                              size: 14,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              '${prov.rating} (${prov.reviews} reviews)',
                                              style: GoogleFonts.inter(
                                                color: AppColors.textSecondary,
                                                fontSize: 11,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        'PKR ${prov.pricing.finalPrice.toInt()}',
                                        style: GoogleFonts.inter(
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.w900,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      const Icon(
                                        Icons.arrow_forward_ios_rounded,
                                        color: AppColors.textDisabled,
                                        size: 12,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final response = ref.watch(serviceBookingProvider).value;
    final provider = ref.watch(selectedProviderProvider);

    if (provider == null || response == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
        body: const Center(child: Text('No provider selected')),
      );
    }

    final pricing = provider.pricing;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        toolbarHeight: 80, // Increased height for logo spacing
        title: const Padding(
          padding: EdgeInsets.only(top: 20),
          child: AppLogo(size: 14),
        ),
        leading: Padding(
          padding: const EdgeInsets.only(top: 20),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary, size: 20),
            onPressed: () => context.pop(),
          ),
        ),
      ),
      body: Stack(
        children: [
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProviderHeader(provider),
                    const SizedBox(height: 16),
                    ProviderContactButtons(
                      phone: provider.phone,
                      whatsappTextLink: provider.whatsappTextLink,
                      mapsUrl: provider.mapsUrl,
                      website: provider.website,
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'BILL SUMMARY',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textDisabled,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    PremiumCard(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          _buildPriceRow('Base Service Fee', pricing.basePrice, 'PKR'),
                          if (pricing.urgencyCost > 0)
                            _buildPriceRow('${response.intent.urgency.toUpperCase()} Urgency Fee', pricing.urgencyCost, 'PKR'),
                          _buildPriceRow('Distance Travel Fee', pricing.distanceCost, 'PKR'),
                          const SizedBox(height: 16),
                          const Divider(color: AppColors.surfaceDark),
                          const SizedBox(height: 16),
                          _buildPriceRow(
                            'Grand Total',
                            pricing.finalPrice,
                            'PKR',
                            isTotal: true,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            pricing.explanation,
                            style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary, fontStyle: FontStyle.italic),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 64),
                    PremiumButton(
                      text: 'Confirm & Book Now',
                      icon: Icons.check_circle_rounded,
                      isLoading: _isBooking,
                      onPressed: () => _handleBooking(provider, response),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
          // Auto-assign loading overlay — rendered in widget tree, no route push
          if (_isAutoAssigning)
            Container(
              color: Colors.black54,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(color: AppColors.primary),
                      const SizedBox(height: 16),
                      Text(
                        'Orchestrating auto-assignment...',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProviderHeader(ServiceProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.surfaceDark.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.person_rounded, color: AppColors.primary, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  provider.name,
                  style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      provider.serviceType.toUpperCase(),
                      style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                    ),
                    if (provider.distanceAway != null) ...[
                      Text(
                        ' • ',
                        style: GoogleFonts.inter(fontSize: 12, color: AppColors.textDisabled),
                      ),
                      Text(
                        provider.distanceAway!,
                        style: GoogleFonts.inter(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, double amount, String currency, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: isTotal ? 16 : 14,
                fontWeight: isTotal ? FontWeight.w900 : FontWeight.w500,
                color: isTotal ? AppColors.textPrimary : AppColors.textSecondary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 16),
          Text(
            '$currency ${amount.toInt()}',
            style: GoogleFonts.inter(
              fontSize: isTotal ? 20 : 14,
              fontWeight: isTotal ? FontWeight.w900 : FontWeight.bold,
              color: isTotal ? AppColors.primary : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
