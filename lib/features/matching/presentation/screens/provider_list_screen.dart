import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:serviq/core/theme/app_colors.dart';
import 'package:serviq/core/widgets/premium_widgets.dart';
import 'package:serviq/features/input/presentation/providers/input_provider.dart';
import 'package:serviq/features/matching/domain/models/service_response.dart';

class ProviderListScreen extends ConsumerWidget {
  const ProviderListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingState = ref.watch(serviceBookingProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        toolbarHeight: 80,
        title: const Padding(
          padding: EdgeInsets.only(top: 20),
          child: AppLogo(size: 14),
        ),
        leading: Padding(
          padding: const EdgeInsets.only(top: 20),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary, size: 20),
            onPressed: () => context.canPop() ? context.pop() : context.go('/home'),
          ),
        ),
      ),
      body: bookingState.when(
        data: (response) {
          if (response == null || response.providers.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.search_off_rounded, size: 64, color: AppColors.textDisabled),
                  const SizedBox(height: 16),
                  Text(
                    'No providers found nearby.',
                    style: GoogleFonts.inter(fontSize: 16, color: AppColors.textSecondary),
                  ),
                ],
              ),
            );
          }

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                itemCount: response.providers.length,
                separatorBuilder: (context, index) => const SizedBox(height: 20),
                itemBuilder: (context, index) {
                  final provider = response.providers[index];
                  final bestProvider = response.providers.reduce((a, b) {
                    if (a.rating != b.rating) return a.rating > b.rating ? a : b;
                    return a.pricing.finalPrice < b.pricing.finalPrice ? a : b;
                  });
                  final isRecommended = provider.id == bestProvider.id;

                  return _buildProviderCard(context, ref, provider, isRecommended);
                },
              ),
            ),
          );
        },
        loading: () => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const PremiumLoadingIndicator(),
              const SizedBox(height: 24),
              Text(
                'Searching for experts...',
                style: GoogleFonts.inter(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildProviderCard(
    BuildContext context,
    WidgetRef ref,
    ServiceProvider provider,
    bool isRecommended,
  ) {
    return PremiumCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header row ──────────────────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(Icons.person_rounded, color: AppColors.primary, size: 30),
              ),
              const SizedBox(width: 14),
              // Name + rating
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            provider.name,
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isRecommended) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.accent.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'RECOMMENDED',
                              style: GoogleFonts.inter(
                                fontSize: 9,
                                fontWeight: FontWeight.w900,
                                color: AppColors.accent,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        const Icon(Icons.star_rounded, size: 15, color: AppColors.accent),
                        const SizedBox(width: 3),
                        Text(
                          '${provider.rating}',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          ' (${provider.reviews})',
                          style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 3,
                          height: 3,
                          decoration: const BoxDecoration(
                            color: AppColors.textDisabled,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.near_me_rounded, size: 13, color: AppColors.textSecondary),
                        const SizedBox(width: 3),
                        Text(
                          provider.distanceAway ?? 'N/A',
                          style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // ── Factor chips ────────────────────────────────────────────
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: provider.factorsUsed.map((factor) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                factor.toUpperCase(),
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                  letterSpacing: 0.4,
                ),
              ),
            )).toList(),
          ),

          const SizedBox(height: 14),

          // ── Divider ─────────────────────────────────────────────────
          Container(
            height: 1,
            color: AppColors.surfaceDark,
          ),

          const SizedBox(height: 14),

          // ── Price ───────────────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Estimated Total',
                style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondary),
              ),
              Text(
                'PKR ${provider.pricing.finalPrice.toInt()}',
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // ── Contact buttons (full width, no overflow) ────────────────
          ProviderContactButtons(
            phone: provider.phone,
            whatsappTextLink: provider.whatsappTextLink,
          ),

          const SizedBox(height: 16),

          // ── CTA ─────────────────────────────────────────────────────
          PremiumButton(
            text: 'Select Professional',
            onPressed: () {
              ref.read(selectedProviderProvider.notifier).setProvider(provider);
              context.push('/pricing-breakdown');
            },
          ),
        ],
      ),
    );
  }
}
