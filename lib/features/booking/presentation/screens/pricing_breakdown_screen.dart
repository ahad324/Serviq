import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
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

  Future<void> _handleBooking(ServiceProvider provider, ServiceResponse response) async {
    setState(() => _isBooking = true);
    
    try {
      final user = ref.read(sessionNotifierProvider);
      final supabase = Supabase.instance.client;
      
      // Calculate final price
      final basePrice = 1500.0;
      final urgencyFee = basePrice * (response.intent.urgencyMultiplier - 1.0);
      final serviceFee = 250.0;
      final grandTotal = basePrice + urgencyFee + serviceFee;

      // Insert into Supabase so TrackingScreen works
      await supabase.from('Bookings').insert({
        'user_id': user?.id,
        'status': 'confirmed',
        'service_type': response.intent.service,
        'provider_name': provider.name,
        'total_price': grandTotal,
        'created_at': DateTime.now().toIso8601String(),
      });

      if (mounted) {
        context.go('/booking-confirmation');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Booking failed: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isBooking = false);
    }
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

    final basePrice = 1500.0;
    final urgencyFee = basePrice * (response.intent.urgencyMultiplier - 1.0);
    final serviceFee = 250.0;
    final grandTotal = basePrice + urgencyFee + serviceFee;
    final platformFeePercent = ((serviceFee / basePrice) * 100).toInt();

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
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProviderHeader(provider),
                const SizedBox(height: 40),
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
                      _buildPriceRow('Base Service Fee', basePrice, 'PKR'),
                      if (urgencyFee > 0)
                        _buildPriceRow('${response.intent.urgency.toUpperCase()} Urgency Fee', urgencyFee, 'PKR'),
                      _buildPriceRow('Platform Service Fee ($platformFeePercent%)', serviceFee, 'PKR'),
                      const SizedBox(height: 16),
                      const Divider(color: AppColors.surfaceDark),
                      const SizedBox(height: 16),
                      _buildPriceRow(
                        'Grand Total',
                        grandTotal,
                        'PKR',
                        isTotal: true,
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
