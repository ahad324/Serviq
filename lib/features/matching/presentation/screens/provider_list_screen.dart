import 'dart:io';

import 'package:flutter_svg/flutter_svg.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
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

  /// Returns true when the device can make phone calls (mobile only).
  bool get _isMobile {
    if (kIsWeb) return false;
    return Platform.isAndroid || Platform.isIOS;
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
                              'BEST',
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

          // ── Price row ───────────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Estimated Total',
                    style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 2),
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
              // ── Contact action buttons ──────────────────────────
              Row(
                children: [
                  // Call button — only on mobile devices
                  if (_isMobile && provider.phone.isNotEmpty) ...[
                    _ContactButton(
                      icon: const Icon(
                        Icons.phone_rounded,
                        size: 16,
                        color: AppColors.primary,
                      ),
                      label: 'Call',
                      color: AppColors.primary,
                      backgroundColor: AppColors.primary.withValues(alpha: 0.09),
                      onTap: () => _launchUrl('tel:${provider.phone.replaceAll(' ', '')}'),
                    ),
                    const SizedBox(width: 10),
                  ],
                  // WhatsApp button — shown on all platforms
                  if (provider.whatsappTextLink != null && provider.whatsappTextLink!.isNotEmpty)
                    _ContactButton(
                      icon: SvgPicture.string(
                        _kWhatsAppSvg,
                        width: 16,
                        height: 16,
                        colorFilter: const ColorFilter.mode(
                          Color(0xFF25D366),
                          BlendMode.srcIn,
                        ),
                      ),
                      label: 'WhatsApp',
                      color: const Color(0xFF25D366),
                      backgroundColor: const Color(0xFF25D366).withValues(alpha: 0.10),
                      onTap: () => _launchUrl(provider.whatsappTextLink!),
                    ),
                ],
              ),
            ],
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

  // WhatsApp brand SVG path (official icon)
  static const String _kWhatsAppSvg = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
  <path d="M17.472 14.382c-.297-.149-1.758-.867-2.03-.967-.273-.099-.471-.148-.67.15-.197.297-.767.966-.94 1.164-.173.199-.347.223-.644.075-.297-.15-1.255-.463-2.39-1.475-.883-.788-1.48-1.761-1.653-2.059-.173-.297-.018-.458.13-.606.134-.133.298-.347.446-.52.149-.174.198-.298.298-.497.099-.198.05-.371-.025-.52-.075-.149-.669-1.612-.916-2.207-.242-.579-.487-.5-.669-.51-.173-.008-.371-.01-.57-.01-.198 0-.52.074-.792.372-.272.297-1.04 1.016-1.04 2.479 0 1.462 1.065 2.875 1.213 3.074.149.198 2.096 3.2 5.077 4.487.709.306 1.262.489 1.694.625.712.227 1.36.195 1.871.118.571-.085 1.758-.719 2.006-1.413.248-.694.248-1.289.173-1.413-.074-.124-.272-.198-.57-.347m-5.421 7.403h-.004a9.87 9.87 0 01-5.031-1.378l-.361-.214-3.741.982.998-3.648-.235-.374a9.86 9.86 0 01-1.51-5.26c.001-5.45 4.436-9.884 9.888-9.884 2.64 0 5.122 1.03 6.988 2.898a9.825 9.825 0 012.893 6.994c-.003 5.45-4.437 9.884-9.885 9.884m8.413-18.297A11.815 11.815 0 0012.05 0C5.495 0 .16 5.335.157 11.892c0 2.096.547 4.142 1.588 5.945L.057 24l6.305-1.654a11.882 11.882 0 005.683 1.448h.005c6.554 0 11.89-5.335 11.893-11.893a11.821 11.821 0 00-3.48-8.413z"/>
</svg>
''';

  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      }
    } catch (_) {}
  }
}

/// A compact icon + label contact action button.
class _ContactButton extends StatefulWidget {
  final Widget icon;
  final String label;
  final Color color;
  final Color backgroundColor;
  final VoidCallback onTap;

  const _ContactButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.backgroundColor,
    required this.onTap,
  });

  @override
  State<_ContactButton> createState() => _ContactButtonState();
}

class _ContactButtonState extends State<_ContactButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.93 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            color: widget.backgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: widget.color.withValues(alpha: 0.25),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              widget.icon,
              const SizedBox(width: 6),
              Text(
                widget.label,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: widget.color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
