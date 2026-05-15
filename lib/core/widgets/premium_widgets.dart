import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';

class PremiumCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double? borderRadius;
  final Color? color;
  final Border? border;

  const PremiumCard({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius,
    this.color,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: color ?? AppColors.surface,
        borderRadius: BorderRadius.circular(borderRadius ?? 20),
        border: border ?? Border.all(color: AppColors.surfaceDark.withOpacity(0.5), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.05, end: 0);
  }
}

class PremiumButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  final IconData? icon;
  final Color? color;
  final Color? textColor;

  const PremiumButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.color,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: 200.ms,
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color ?? AppColors.primary,
          foregroundColor: textColor ?? Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
        child: isLoading
            ? const SizedBox(
                height: 24,
                width: 24,
                child: PremiumLoadingIndicator(color: Colors.white, size: 24),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 20),
                    const SizedBox(width: 8),
                  ],
                  Text(text, style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                ],
              ),
      ),
    ).animate().scale(duration: 200.ms, curve: Curves.easeOut);
  }
}

class AppLogo extends StatelessWidget {
  final double size;
  final Color? color;
  final bool showText;

  const AppLogo({
    super.key, 
    this.size = 24, 
    this.color,
    this.showText = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size * 1.5,
          height: size * 1.5,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primary, AppColors.primaryLight],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(size * 0.4),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(
            Icons.flash_on_rounded, 
            color: AppColors.accent, 
            size: size * 0.9,
          ),
        ),
        if (showText) ...[
          const SizedBox(width: 12),
          Text(
            'SERVIQ',
            style: GoogleFonts.plusJakartaSans(
              fontSize: size,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.5,
              color: color ?? AppColors.textPrimary,
            ),
          ),
        ],
      ],
    );
  }
}

class ScreenHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;

  const ScreenHeader({
    super.key, 
    required this.title, 
    this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const AppLogo(size: 14),
            if (trailing != null) trailing!,
          ],
        ),
        const SizedBox(height: 24),
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            height: 1.2,
            color: AppColors.textPrimary,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 12),
          Text(
            subtitle!,
            style: GoogleFonts.inter(
              fontSize: 16,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ],
    ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.05);
  }
}

class PremiumLoadingIndicator extends StatelessWidget {
  final Color? color;
  final double size;

  const PremiumLoadingIndicator({super.key, this.color, this.size = 40});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            strokeWidth: 2,
            color: color ?? AppColors.primary,
          ),
          Container(
            width: size * 0.4,
            height: size * 0.4,
            decoration: BoxDecoration(
              color: (color ?? AppColors.primary).withOpacity(0.2),
              shape: BoxShape.circle,
            ),
          ).animate(onPlay: (controller) => controller.repeat())
           .scale(begin: const Offset(0.5, 0.5), end: const Offset(1.2, 1.2), duration: 1000.ms, curve: Curves.easeInOut)
           .fadeOut(duration: 1000.ms),
        ],
      ),
    );
  }
}


class StatusBadge extends StatelessWidget {
  final String text;
  final Color? color;

  const StatusBadge({
    super.key, 
    required this.text,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final baseColor = color ?? AppColors.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: baseColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: baseColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: baseColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: baseColor.withOpacity(0.5),
                  blurRadius: 4,
                  spreadRadius: 1,
                ),
              ],
            ),
          ).animate(onPlay: (controller) => controller.repeat())
           .fadeIn(duration: 600.ms)
           .then()
           .fadeOut(duration: 600.ms),
          const SizedBox(width: 8),
          Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: baseColor,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
