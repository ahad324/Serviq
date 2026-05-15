import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:serviq/core/theme/app_colors.dart';
import 'package:serviq/core/widgets/premium_widgets.dart';
import 'package:serviq/features/input/presentation/providers/input_provider.dart';
import 'package:serviq/features/matching/domain/models/service_response.dart';

class AIUnderstandingScreen extends ConsumerStatefulWidget {
  const AIUnderstandingScreen({super.key});

  @override
  ConsumerState<AIUnderstandingScreen> createState() => _AIUnderstandingScreenState();
}

class _AIUnderstandingScreenState extends ConsumerState<AIUnderstandingScreen> {
  double _progress = 0.0;
  String _currentAgent = 'Initializing Intent Agent...';
  String _detailText = 'Connecting to neural processing unit...';
  bool _isFinalizing = false;

  final List<Map<String, String>> _stages = [
    {'agent': 'Intent Agent', 'detail': 'Analyzing linguistic patterns and urgency markers...'},
    {'agent': 'Matching Agent', 'detail': 'Scanning 50+ service professionals in your area...'},
    {'agent': 'Decision Agent', 'detail': 'Evaluating provider performance and customer feedback...'},
    {'agent': 'Pricing Agent', 'detail': 'Calculating fair market rates and urgency multipliers...'},
    {'agent': 'Booking Agent', 'detail': 'Finalizing service availability and route optimization...'},
  ];

  @override
  void initState() {
    super.initState();
    _startSimulation();
  }

  void _startSimulation() async {
    int stageIndex = 0;
    
    // Smooth progress simulation (Big Tech approach: Perceived Performance)
    DateTime startTime = DateTime.now();
    
    while (_progress < 0.95 && !_isFinalizing) {
      await Future.delayed(const Duration(milliseconds: 150));
      if (!mounted) return;

      // Watchdog: If more than 60 seconds passed and still no response
      if (DateTime.now().difference(startTime).inSeconds > 60 && !_isFinalizing) {
        _showErrorDialog('Connection timed out after 60s. Please check your internet and try again.');
        return;
      }

      setState(() {
        // Slow down as we get closer to 95%
        double increment = 0.01 * (1.0 - _progress);
        if (increment < 0.002) increment = 0.002;
        _progress += increment;
        
        // Update stages based on progress
        int currentStage = (_progress * _stages.length).floor().clamp(0, _stages.length - 1);
        if (currentStage > stageIndex) {
          stageIndex = currentStage;
          _currentAgent = _stages[stageIndex]['agent']!;
          _detailText = _stages[stageIndex]['detail']!;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bookingState = ref.watch(serviceBookingProvider);

    // Use ref.listen for robust side-effects (navigation & error handling)
    ref.listen<AsyncValue<ServiceResponse?>>(serviceBookingProvider, (previous, next) {
      next.when(
        data: (booking) {
          if (booking != null && !_isFinalizing) {
            _isFinalizing = true;
            _finalizeAndNavigate();
          }
        },
        error: (err, stack) {
          if (!_isFinalizing) {
            _showErrorDialog(err.toString());
          }
        },
        loading: () {},
      );
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const AppLogo(size: 14),
                  const SizedBox(height: 64),
                  _buildAILoader(),
                  const SizedBox(height: 48),
                  _buildAnalysisText(),
                  const SizedBox(height: 64),
                  _buildConfidenceMeter(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _finalizeAndNavigate() async {
    setState(() {
      _currentAgent = 'Agents Synced';
      _detailText = 'Service matching complete. Redirecting...';
    });

    while (_progress < 1.0) {
      await Future.delayed(const Duration(milliseconds: 16)); // ~60fps smooth finish
      if (!mounted) return;
      setState(() {
        _progress += 0.04;
        if (_progress > 1.0) _progress = 1.0;
      });
    }

    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      context.go('/providers');
    }
  }

  void _showErrorDialog(String error) {
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(
          'Processing Error',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Our AI agents are having trouble connecting. This could be due to a slow network or high server load.\n\nError: $error',
          style: GoogleFonts.inter(),
        ),
        actions: [
          TextButton(
            onPressed: () => context.go('/home'),
            child: const Text('Back to Home'),
          ),
        ],
      ),
    );
  }

  Widget _buildAILoader() {
    return Container(
      width: 160,
      height: 160,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.05),
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.1), width: 2),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Rotating outer ring
          SizedBox(
            width: 140,
            height: 140,
            child: CircularProgressIndicator(
              value: _progress,
              strokeWidth: 4,
              backgroundColor: Colors.transparent,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
          const Icon(
            Icons.auto_awesome_rounded,
            size: 60,
            color: AppColors.primary,
          ).animate(onPlay: (controller) => controller.repeat())
           .shimmer(duration: 2.seconds, color: Colors.white.withValues(alpha: 0.5))
           .scale(duration: 1.seconds, begin: const Offset(0.9, 0.9), end: const Offset(1.1, 1.1), curve: Curves.easeInOut)
           .then().scale(duration: 1.seconds, begin: const Offset(1.1, 1.1), end: const Offset(0.9, 0.9), curve: Curves.easeInOut),
        ],
      ),
    );
  }

  Widget _buildAnalysisText() {
    return Column(
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          child: Text(
            _currentAgent,
            key: ValueKey(_currentAgent),
            style: GoogleFonts.plusJakartaSans(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
        ),
        const SizedBox(height: 16),
        PremiumCard(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Text(
                'SYSTEM STATUS',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primary,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 12),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Text(
                  _detailText,
                  key: ValueKey(_detailText),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    color: AppColors.textSecondary,
                    height: 1.6,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ).animate().fadeIn(delay: 300.milliseconds).scale(begin: const Offset(0.95, 0.95)),
      ],
    );
  }

  Widget _buildConfidenceMeter() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.bolt_rounded, size: 14, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(
              'PROCESSING: ${(_progress * 100).toInt()}%',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                color: AppColors.textDisabled,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          width: 280,
          height: 10,
          decoration: BoxDecoration(
            color: AppColors.surfaceDark.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(5),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: LinearProgressIndicator(
              value: _progress,
              backgroundColor: Colors.transparent,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
        ),
      ],
    ).animate().fadeIn(delay: 600.milliseconds);
  }
}
