import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/premium_widgets.dart';
import '../../../../core/services/location_service.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/providers/session_provider.dart';
import '../../../auth/data/models/auth_exception.dart';
import '../../../../core/utils/validators.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  bool _isEditing = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(sessionNotifierProvider);
    _nameController = TextEditingController(text: user?.name ?? '');
    _phoneController = TextEditingController(text: user?.phone ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final user = ref.read(sessionNotifierProvider);
    final repository = ref.read(authRepositoryProvider);
    final sessionNotifier = ref.read(sessionNotifierProvider.notifier);

    try {
      if (user == null) throw AppAuthException('No user logged in');

      final updatedUser = await repository.updateUser(
        userId: user.id,
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
      );

      sessionNotifier.setUser(updatedUser);
      setState(() => _isEditing = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✓ Profile updated successfully'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } on AppAuthException catch (e) {
      _showError(e.message);
    } catch (e) {
      _showError('Failed to update profile: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _updateLocation() async {
    final locationService = ref.read(locationServiceProvider);
    
    // Show a small loader while fetching location
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)),
            SizedBox(width: 12),
            Text('Updating live location...'),
          ],
        ),
        duration: Duration(seconds: 1),
      ),
    );

    final position = await locationService.getCurrentLocation();

    if (position != null) {
      final user = ref.read(sessionNotifierProvider);
      final repository = ref.read(authRepositoryProvider);
      final sessionNotifier = ref.read(sessionNotifierProvider.notifier);

      try {
        if (user == null) throw AppAuthException('No user logged in');

        final updatedUser = await repository.updateUser(
          userId: user.id,
          locationLat: position.latitude,
          locationLng: position.longitude,
        );

        sessionNotifier.setUser(updatedUser);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✓ Location updated successfully'),
              backgroundColor: AppColors.success,
              duration: Duration(seconds: 2),
            ),
          );
        }
      } catch (e) {
        _showError('Failed to update location: ${e.toString()}');
      }
    }
  }

  void _showChangePasswordDialog() {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    final dialogFormKey = GlobalKey<FormState>();
    bool isDialogLoading = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Text('Change Password', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800)),
          content: Form(
            key: dialogFormKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  PremiumTextField(
                    controller: currentPasswordController,
                    label: 'Current Password',
                    hint: '••••••••',
                    prefixIcon: Icons.lock_outline_rounded,
                    isPassword: true,
                    validator: (v) => v!.isEmpty ? 'Enter current password' : null,
                  ),
                  const SizedBox(height: 16),
                  PremiumTextField(
                    controller: newPasswordController,
                    label: 'New Password',
                    hint: '••••••••',
                    prefixIcon: Icons.security_rounded,
                    isPassword: true,
                    validator: AppValidators.validatePassword,
                  ),
                  const SizedBox(height: 16),
                  PremiumTextField(
                    controller: confirmPasswordController,
                    label: 'Confirm New Password',
                    hint: '••••••••',
                    prefixIcon: Icons.shield_outlined,
                    isPassword: true,
                    validator: (v) => v != newPasswordController.text ? 'Passwords do not match' : null,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: GoogleFonts.inter(color: AppColors.textSecondary)),
            ),
            PremiumButton(
              text: 'Update',
              isLoading: isDialogLoading,
              onPressed: () async {
                if (!dialogFormKey.currentState!.validate()) return;
                
                setDialogState(() => isDialogLoading = true);
                try {
                  final user = ref.read(sessionNotifierProvider);
                  final repository = ref.read(authRepositoryProvider);
                  
                  await repository.updatePassword(
                    userId: user!.id,
                    currentPassword: currentPasswordController.text,
                    newPassword: newPasswordController.text,
                  );
                  
                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('✓ Password updated successfully'), backgroundColor: AppColors.success),
                    );
                  }
                } on AppAuthException catch (e) {
                  _showError(e.message);
                } finally {
                  setDialogState(() => isDialogLoading = false);
                }
              },
            ),
          ],
        ),
      ),
    );
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

  void _signOut() {
    final sessionNotifier = ref.read(sessionNotifierProvider.notifier);
    sessionNotifier.clearUser();
    context.go('/auth');
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(sessionNotifierProvider);

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Please log in to view your profile')),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ScreenHeader(
                title: 'My Profile',
                subtitle: 'Manage your account and preferences',
              ),
              const SizedBox(height: 32),
              
              // Profile Card
              PremiumCard(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Center(
                      child: Stack(
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.primary.withValues(alpha: 0.2), width: 2),
                            ),
                            child: const Icon(Icons.person_rounded, size: 50, color: AppColors.primary),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                              child: const Icon(Icons.camera_alt_rounded, size: 16, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    if (_isEditing)
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            PremiumTextField(
                              controller: _nameController,
                              label: 'Full Name',
                              hint: 'John Doe',
                              prefixIcon: Icons.person_outline_rounded,
                              validator: AppValidators.validateName,
                            ),
                            const SizedBox(height: 20),
                            PremiumTextField(
                              controller: _phoneController,
                              label: 'Phone Number',
                              hint: '03XX XXXXXXX',
                              prefixIcon: Icons.phone_android_rounded,
                              keyboardType: TextInputType.phone,
                              validator: AppValidators.validatePhone,
                            ),
                            const SizedBox(height: 24),
                            Row(
                              children: [
                                Expanded(
                                  child: TextButton(
                                    onPressed: () => setState(() => _isEditing = false),
                                    child: Text('Cancel', style: GoogleFonts.inter(color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: PremiumButton(
                                    text: 'Save',
                                    onPressed: _updateProfile,
                                    isLoading: _isLoading,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      )
                    else
                      Column(
                        children: [
                          _buildInfoRow('NAME', user.name),
                          const Divider(height: 32),
                          _buildInfoRow('EMAIL', user.email),
                          const Divider(height: 32),
                          _buildInfoRow('PHONE', user.phone),
                          const Divider(height: 32),
                          _buildLocationRow(user),
                          const SizedBox(height: 24),
                          PremiumButton(
                            text: 'Edit Profile',
                            onPressed: () => setState(() => _isEditing = true),
                            icon: Icons.edit_rounded,
                            color: AppColors.primary,
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Settings/Actions
              PremiumCard(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  children: [
                    _buildSettingsTile(
                      icon: Icons.lock_reset_rounded,
                      title: 'Change Password',
                      onTap: _showChangePasswordDialog,
                    ),
                    _buildSettingsTile(
                      icon: Icons.notifications_none_rounded,
                      title: 'Notifications',
                      onTap: () {},
                    ),
                    _buildSettingsTile(
                      icon: Icons.security_rounded,
                      title: 'Privacy & Security',
                      onTap: () {},
                    ),
                    _buildSettingsTile(
                      icon: Icons.logout_rounded,
                      title: 'Sign Out',
                      onTap: _signOut,
                      isDestructive: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLocationRow(dynamic user) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'LOCATION',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textDisabled,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                user.locationLat != null 
                    ? '${user.locationLat?.toStringAsFixed(4)}, ${user.locationLng?.toStringAsFixed(4)}' 
                    : 'Not Set',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Container(
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: IconButton(
            onPressed: _updateLocation,
            icon: const Icon(Icons.my_location_rounded, color: AppColors.primary, size: 20),
            tooltip: 'Update Live Location',
            constraints: const BoxConstraints(),
            padding: const EdgeInsets.all(8),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textDisabled,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final color = isDestructive ? AppColors.error : AppColors.textPrimary;
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: color.withValues(alpha: 0.8), size: 22),
      title: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
      trailing: const Icon(Icons.chevron_right_rounded, size: 20, color: AppColors.textDisabled),
    );
  }
}
