import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:serviq/core/theme/app_colors.dart';
import 'package:serviq/core/widgets/premium_widgets.dart';
import 'package:serviq/features/input/presentation/providers/input_provider.dart';

class InputScreen extends ConsumerStatefulWidget {
  const InputScreen({super.key});

  @override
  ConsumerState<InputScreen> createState() => _InputScreenState();
}

class _InputScreenState extends ConsumerState<InputScreen> {
  final _formKey = GlobalKey<FormState>();
  final _queryController = TextEditingController();

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  void _handleSubmit() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        await ref.read(serviceBookingProvider.notifier).submitQuery(_queryController.text);
        
        // After await, we check the current state of the provider.
        // AsyncValue.hasValue and !hasError indicates success.
        final state = ref.read(serviceBookingProvider);
        if (state.hasValue && !state.hasError && mounted) {
          context.go('/ai-understanding');
        }
      } catch (e) {
        // Error is already handled by the AsyncNotifier and exposed via the provider state.
        // The UI will show the error via _buildError.
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bookingState = ref.watch(serviceBookingProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ScreenHeader(
                  title: 'What service do you\nneed today?',
                ),
                const SizedBox(height: 60),
                _buildInputSection(bookingState.isLoading),
                const SizedBox(height: 40),
                PremiumButton(
                  text: 'Find Service Provider',
                  icon: Icons.search_rounded,
                  isLoading: bookingState.isLoading,
                  onPressed: _handleSubmit,
                ),
                const SizedBox(height: 32),
                _buildMicButton(),
                if (bookingState.hasError) _buildError(bookingState.error.toString()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputSection(bool isLoading) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.surfaceDark.withOpacity(0.5), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: TextFormField(
        controller: _queryController,
        maxLines: 4,
        enabled: !isLoading,
        style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          hintText: 'e.g. "Mujhe kal AC repair chahiye"',
          hintStyle: GoogleFonts.inter(color: AppColors.textDisabled),
          fillColor: Colors.transparent,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
        validator: (value) =>
            value?.isEmpty ?? true ? 'Please describe your request' : null,
      ),
    ).animate().fadeIn(delay: 400.ms).scale(begin: const Offset(0.98, 0.98));
  }

  Widget _buildMicButton() {
    return Center(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.mic_none_rounded, color: AppColors.primary, size: 28),
          ),
          const SizedBox(height: 12),
          Text(
            'Tap to speak',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 600.ms);
  }

  Widget _buildError(String error) {
    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.error.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.error_outline, color: AppColors.error, size: 16),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                error,
                style: const TextStyle(color: AppColors.error, fontSize: 12, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
