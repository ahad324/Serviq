import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/premium_widgets.dart';
import '../../../../core/services/location_service.dart';
import '../providers/auth_provider.dart';
import '../providers/session_provider.dart';
import '../../data/models/auth_exception.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLogin = true;
  bool _isLoading = false;
  double? _locationLat;
  double? _locationLng;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _requestLocationPermission() async {
    final locationService = ref.read(locationServiceProvider);
    final position = await locationService.getCurrentLocation();
    if (position != null) {
      setState(() {
        _locationLat = position.latitude;
        _locationLng = position.longitude;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✓ Location permission granted'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final repository = ref.read(authRepositoryProvider);
    final sessionNotifier = ref.read(sessionNotifierProvider.notifier);

    try {
      if (_isLogin) {
        final user = await repository.signInWithEmail(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        sessionNotifier.setUser(user);
        if (mounted) {
          context.go('/input');
        }
      } else {
        // Request location for signup
        await _requestLocationPermission();

        final user = await repository.signUpWithEmail(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          phone: _phoneController.text.trim(),
          password: _passwordController.text.trim(),
          locationLat: _locationLat,
          locationLng: _locationLng,
        );
        sessionNotifier.setUser(user);
        if (mounted) {
          context.go('/input');
        }
      }
    } on WeakPasswordException catch (e) {
      _showError(e.message);
    } on UserAlreadyExistsException catch (e) {
      _showError(e.message);
    } on InvalidCredentialsException catch (e) {
      _showError(e.message);
    } on AppAuthException catch (e) {
      _showError(e.message);
    } catch (e) {
      _showError('An error occurred: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const SizedBox(height: 40),
              // Logo and Branding
              const Center(
                child: AppLogo(size: 15, showText: true),
              ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.2, end: 0),
              
              const SizedBox(height: 32),
              
              // Header Text
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _isLogin ? 'Welcome Back' : 'Create Account',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _isLogin
                        ? 'Log in to continue your service journey'
                        : 'Join Serviq for premium home services',
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                ],
              ).animate().fadeIn(delay: 200.ms, duration: 600.ms).slideX(begin: -0.1, end: 0),

              const SizedBox(height: 32),

              // Form
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    if (!_isLogin) ...[
                      PremiumTextField(
                        controller: _nameController,
                        label: 'Full Name',
                        hint: 'John Doe',
                        prefixIcon: Icons.person_outline_rounded,
                        keyboardType: TextInputType.name,
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Please enter your name';
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      PremiumTextField(
                        controller: _phoneController,
                        label: 'Phone Number',
                        hint: '03XX XXXXXXX',
                        prefixIcon: Icons.phone_android_rounded,
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Please enter phone number';
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                    ],
                    PremiumTextField(
                      controller: _emailController,
                      label: 'Email Address',
                      hint: 'your@email.com',
                      prefixIcon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Please enter email';
                        if (!value.contains('@')) return 'Invalid email';
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    PremiumTextField(
                      controller: _passwordController,
                      label: 'Password',
                      hint: '••••••••',
                      prefixIcon: Icons.lock_outline_rounded,
                      isPassword: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Please enter password';
                        if (value.length < 8) return 'Min 8 characters';
                        return null;
                      },
                    ),
                    if (!_isLogin) ...[
                      const SizedBox(height: 20),
                      PremiumTextField(
                        controller: _confirmPasswordController,
                        label: 'Confirm Password',
                        hint: '••••••••',
                        prefixIcon: Icons.shield_outlined,
                        isPassword: true,
                        validator: (value) {
                          if (value != _passwordController.text) return 'Passwords do not match';
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      // Location Button
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: _requestLocationPermission,
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                            decoration: BoxDecoration(
                              color: _locationLat != null 
                                  ? AppColors.success.withValues(alpha: 0.1)
                                  : AppColors.primary.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: _locationLat != null 
                                    ? AppColors.success.withValues(alpha: 0.3)
                                    : AppColors.primary.withValues(alpha: 0.1),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  _locationLat != null ? Icons.location_on : Icons.location_searching_rounded,
                                  color: _locationLat != null ? AppColors.success : AppColors.primary,
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  _locationLat != null ? 'Location Captured' : 'Tap to enable location',
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: _locationLat != null ? AppColors.success : AppColors.primary,
                                  ),
                                ),
                                const Spacer(),
                                if (_locationLat != null)
                                  const Icon(Icons.check_circle, color: AppColors.success, size: 20),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 40),
                    PremiumButton(
                      text: _isLogin ? 'Sign In' : 'Create Account',
                      onPressed: _submit,
                      isLoading: _isLoading,
                      icon: _isLogin ? Icons.login_rounded : Icons.person_add_rounded,
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1, end: 0),

              const SizedBox(height: 32),

              // Footer
              Center(
                child: TextButton(
                  onPressed: () => setState(() => _isLogin = !_isLogin),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: RichText(
                    text: TextSpan(
                      style: GoogleFonts.inter(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                      children: [
                        TextSpan(text: _isLogin ? "Don't have an account? " : "Already have an account? "),
                        TextSpan(
                          text: _isLogin ? "Sign Up" : "Sign In",
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
