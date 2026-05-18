import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:serviq/core/utils/speech_helper.dart';
import 'package:serviq/core/theme/app_colors.dart';
import 'package:serviq/core/widgets/premium_widgets.dart';
import 'package:serviq/features/input/data/repositories/service_repository.dart';
import 'package:serviq/features/input/presentation/providers/input_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:serviq/features/auth/presentation/providers/session_provider.dart';

class InputScreen extends ConsumerStatefulWidget {
  const InputScreen({super.key});

  @override
  ConsumerState<InputScreen> createState() => _InputScreenState();
}

class _InputScreenState extends ConsumerState<InputScreen> {
  final _formKey = GlobalKey<FormState>();
  final _queryController = TextEditingController();
  bool _isChecking = false;

  bool _speechEnabled = false;
  bool _isSpeechListening = false;
  String _speechWords = "";

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  Future<void> _initSpeech() async {
    try {
      final enabled = await AppSpeechHelper.instance.initialize(
        onError: (val) => debugPrint('Speech error: $val'),
        onStatus: (val) {
          if (mounted) {
            setState(() {
              _isSpeechListening = AppSpeechHelper.instance.isListening;
            });
          }
        },
      );
      if (mounted) {
        setState(() {
          _speechEnabled = enabled;
        });
      }
    } catch (e) {
      debugPrint('Speech init failed: $e');
    }
  }

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  void _handleSubmit() async {
    if (_queryController.text.trim().isEmpty) return;

    final user = ref.read(sessionNotifierProvider);
    if (user == null) return;

    setState(() => _isChecking = true);

    try {
      // PRO-CHECK: Prevent multiple active bookings to save API limits & prevent misuse
      final activeBookings = await Supabase.instance.client
          .from('Bookings')
          .select('id')
          .eq('user_id', user.id)
          .not('status', 'in', ['cancelled', 'completed'])
          .limit(1);

      if (activeBookings.isNotEmpty) {
        if (mounted) {
          _showActiveBookingAlert();
        }
        return;
      }

      // Start the submission process
      ref
          .read(serviceBookingProvider.notifier)
          .submitQuery(_queryController.text);

      // Navigate immediately to the AI Understanding screen
      if (mounted) {
        context.go('/ai-understanding');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error checking status: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isChecking = false);
    }
  }

  void _showActiveBookingAlert() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: AppColors.warning, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Active Request',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w800,
                  fontSize: 20,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        content: Text(
          'You already have an active service request in progress. Please complete or cancel it before starting a new one.',
          style: GoogleFonts.inter(
            color: AppColors.textSecondary, 
            height: 1.5,
            fontSize: 14,
          ),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Close',
                    style: GoogleFonts.inter(
                      color: AppColors.textSecondary, 
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 3,
                child: PremiumButton(
                  text: 'View Tracking',
                  onPressed: () {
                    Navigator.pop(context);
                    context.go('/tracking');
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bookingState = ref.watch(serviceBookingProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 32,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Center(child: AppLogo(size: 20)),
                      const SizedBox(height: 64),
                      const ScreenHeader(
                        title: 'What service do you\nneed today?',
                      ),
                      const SizedBox(height: 48),
                      _buildInputSection(bookingState.isLoading),
                      const SizedBox(height: 32),
                      PremiumButton(
                        text: 'Find Service Provider',
                        icon: Icons.search_rounded,
                        isLoading: bookingState.isLoading || _isChecking,
                        onPressed: _handleSubmit,
                      ),
                      const SizedBox(height: 40),
                      _buildMicButton(),
                      if (bookingState.hasError)
                        _buildError(bookingState.error),
                    ],
                  ),
                ),
              ),
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
        border: Border.all(
          color: AppColors.surfaceDark.withValues(alpha: 0.5),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
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
    ).animate().fadeIn(delay: 400.milliseconds).scale(begin: const Offset(0.98, 0.98));
  }

  void _startVoiceInput() {
    _speechWords = "";
    _isSpeechListening = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateSheet) {
            
            void onSpeechResult(String words) {
              setStateSheet(() {
                _speechWords = words;
              });
            }

            void toggleListening() async {
              if (_isSpeechListening) {
                await AppSpeechHelper.instance.stop();
                setStateSheet(() {
                  _isSpeechListening = false;
                });
              } else {
                setStateSheet(() {
                  _isSpeechListening = true;
                  _speechWords = "Listening...";
                });
                try {
                  await AppSpeechHelper.instance.listen(
                    onResult: (words) {
                      onSpeechResult(words);
                      _queryController.text = words;
                    },
                  );
                } catch (e) {
                  setStateSheet(() {
                    _speechWords = "Error starting listener: $e";
                    _isSpeechListening = false;
                  });
                }
              }
            }

            // Automatically start listening on dialog open if supported
            if (_speechEnabled && !_isSpeechListening && _speechWords.isEmpty) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                toggleListening();
              });
            }

            return Container(
              height: MediaQuery.of(context).size.height * 0.65,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary,
                    AppColors.primaryDark.withValues(alpha: 0.98),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(36),
                  topRight: Radius.circular(36),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 30,
                    offset: const Offset(0, -10),
                  )
                ]
              ),
              child: Stack(
                children: [
                  // Decorative top bar
                  Positioned(
                    top: 12,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        width: 48,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                        Text(
                          _speechEnabled ? 'Voice Assistant' : 'Voice Assistant (Simulation)',
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _speechEnabled 
                              ? (_isSpeechListening ? 'Listening to your request...' : 'Tap mic to start speaking')
                              : 'Tap a template to speak or type directly',
                          style: GoogleFonts.inter(
                            color: Colors.white.withValues(alpha: 0.6),
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 24),
                        
                        // Pulsating mic button in the center
                        Center(
                          child: GestureDetector(
                            onTap: () {
                              if (_speechEnabled) {
                                toggleListening();
                              } else {
                                setStateSheet(() {
                                  _isSpeechListening = !_isSpeechListening;
                                  if (_isSpeechListening) {
                                    _speechWords = "Simulating voice input...";
                                  } else {
                                    _speechWords = "";
                                  }
                                });
                              }
                            },
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // Pulsating circles
                                if (_isSpeechListening) ...[
                                  Container(
                                    width: 120,
                                    height: 120,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: AppColors.accent.withValues(alpha: 0.15),
                                    ),
                                  ).animate(onPlay: (controller) => controller.repeat())
                                   .scale(begin: const Offset(0.8, 0.8), end: const Offset(1.3, 1.3), duration: 1500.milliseconds, curve: Curves.easeOut)
                                   .fadeOut(duration: 1500.milliseconds),
                                  Container(
                                    width: 100,
                                    height: 100,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: AppColors.accent.withValues(alpha: 0.25),
                                    ),
                                  ).animate(onPlay: (controller) => controller.repeat())
                                   .scale(begin: const Offset(0.9, 0.9), end: const Offset(1.15, 1.15), duration: 1200.milliseconds, curve: Curves.easeOut)
                                   .fadeOut(duration: 1200.milliseconds),
                                ],
                                // Central mic button
                                Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: _isSpeechListening ? AppColors.accent : Colors.white.withValues(alpha: 0.1),
                                    border: Border.all(
                                      color: Colors.white.withValues(alpha: 0.15),
                                      width: 2,
                                    ),
                                  ),
                                  child: Icon(
                                    _isSpeechListening ? Icons.mic_rounded : Icons.mic_none_rounded,
                                    color: _isSpeechListening ? AppColors.primary : Colors.white,
                                    size: 36,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 24),

                        // Text display box
                        Container(
                          height: 110,
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.1),
                            ),
                          ),
                          child: SingleChildScrollView(
                            child: Text(
                              _speechWords.isEmpty 
                                  ? (_speechEnabled ? "Say something like: 'Need home cleaning tomorrow'" : "Select a quick template below to simulate speech:") 
                                  : _speechWords,
                              style: GoogleFonts.inter(
                                color: _speechWords.isEmpty ? Colors.white.withValues(alpha: 0.4) : Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                height: 1.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 16),

                        // Quick suggestion template chips
                        SizedBox(
                          height: 48,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            children: [
                              _buildTemplateChip(
                                "AC Service Repair",
                                "Mujhe kal AC repair service chahiye",
                                setStateSheet,
                              ),
                              _buildTemplateChip(
                                "Leaking Kitchen Tap",
                                "Kitchen ka nal leak ho raha hai, plumber chahiye",
                                setStateSheet,
                              ),
                              _buildTemplateChip(
                                "Deep Home Cleaning",
                                "Ghar ki deep cleaning ke liye professional worker chahiye",
                                setStateSheet,
                              ),
                              _buildTemplateChip(
                                "Ceiling Fan Repair",
                                "Ceiling fan theek karne ke liye electrician chahiye",
                                setStateSheet,
                              ),
                              _buildTemplateChip(
                                "Premium Car Detail",
                                "Car washing aur premium polishing ki service chahiye",
                                setStateSheet,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Done / Action Button
                        Row(
                          children: [
                            Expanded(
                              child: TextButton(
                                onPressed: () async {
                                  if (_speechEnabled && _isSpeechListening) {
                                    await AppSpeechHelper.instance.stop();
                                  }
                                  if (mounted) Navigator.pop(context);
                                },
                                child: Text(
                                  'Cancel',
                                  style: GoogleFonts.inter(
                                    color: Colors.white.withValues(alpha: 0.6),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.accent,
                                  foregroundColor: AppColors.primary,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  elevation: 0,
                                ),
                                onPressed: () async {
                                  if (_speechEnabled && _isSpeechListening) {
                                    await AppSpeechHelper.instance.stop();
                                  }
                                  if (mounted) {
                                    Navigator.pop(context);
                                    if (_queryController.text.trim().isNotEmpty) {
                                      _handleSubmit();
                                    }
                                  }
                                },
                                child: Text(
                                  'Find Service',
                                  style: GoogleFonts.inter(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  ),
                ],
              ),
            );
          },
        );
      },
    ).then((_) {
      if (_speechEnabled && _isSpeechListening) {
        AppSpeechHelper.instance.stop();
        _isSpeechListening = false;
      }
    });
  }

  Widget _buildTemplateChip(String label, String query, StateSetter setStateSheet) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ActionChip(
        backgroundColor: Colors.white,
        side: const BorderSide(color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        label: Text(
          label,
          style: GoogleFonts.inter(
            color: Colors.black,
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
        ),
        onPressed: () {
          _isSpeechListening = false;
          _speechWords = "";
          setStateSheet(() {
            _queryController.text = query;
            _speechWords = '"$query"';
          });
        },
      ),
    );
  }

  Widget _buildMicButton() {
    return GestureDetector(
      onTap: _startVoiceInput,
      behavior: HitTestBehavior.opaque,
      child: Center(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.mic_none_rounded,
                color: AppColors.primary,
                size: 28,
              ),
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
      ),
    ).animate().fadeIn(delay: 600.milliseconds);
  }

  Widget _buildError(Object? error) {
    // When using AsyncNotifier, errors are often wrapped in AsyncError
    final actualError = error is AsyncError ? error.error : error;
    
    String displayMessage = actualError.toString();
    String? hint;

    if (actualError is ServiceApiException) {
      displayMessage = actualError.message;
      hint = actualError.hint;
    } else {
      displayMessage = displayMessage.replaceFirst('Exception: ', '');
    }

    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.error.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.error_outline, color: AppColors.error, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    displayMessage,
                    style: const TextStyle(
                      color: AppColors.error,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            if (hint != null && hint.isNotEmpty) ...[
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.only(left: 28),
                child: Text(
                  hint,
                  style: const TextStyle(
                    color: AppColors.error,
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
