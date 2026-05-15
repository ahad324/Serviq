import 'package:crypto/crypto.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import '../models/auth_exception.dart';

class AuthRepository {
  final SupabaseClient _client;

  AuthRepository(this._client);

  /// Hash password using SHA-256
  String _hashPassword(String password) {
    return sha256.convert(password.codeUnits).toString();
  }

  /// Sign up with custom user table
  Future<UserModel> signUpWithEmail({
    required String name,
    required String email,
    required String phone,
    required String password,
    double? locationLat,
    double? locationLng,
  }) async {
    try {
      // Validate input
      if (password.length < 8) {
        throw WeakPasswordException();
      }

      // Check if user already exists
      final existingUser = await _client
          .from('users')
          .select()
          .or('email.eq.$email,phone.eq.$phone')
          .maybeSingle();

      if (existingUser != null) {
        throw UserAlreadyExistsException();
      }

      // Hash password
      final passwordHash = _hashPassword(password);

      // Create user in custom table
      final response = await _client
          .from('users')
          .insert({
            'name': name,
            'email': email,
            'phone': phone,
            'password_hash': passwordHash,
            'location_lat': locationLat,
            'location_lng': locationLng,
            'is_active': true,
          })
          .select()
          .single();

      return UserModel.fromJson(response);
    } on AuthException catch (e) {
      throw AppAuthException(e.message);
    } catch (e) {
      throw AppAuthException('Sign up failed: ${e.toString()}');
    }
  }

  /// Sign in with email and password
  Future<UserModel> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      // Get user by email
      final response = await _client
          .from('users')
          .select()
          .eq('email', email)
          .eq('is_active', true)
          .maybeSingle();

      if (response == null) {
        throw InvalidCredentialsException();
      }

      // Verify password
      final passwordHash = _hashPassword(password);
      if (response['password_hash'] != passwordHash) {
        throw InvalidCredentialsException();
      }

      return UserModel.fromJson(response);
    } on AuthException catch (e) {
      throw AppAuthException(e.message);
    } catch (e) {
      throw AppAuthException('Sign in failed: ${e.toString()}');
    }
  }

  /// Get user by ID
  Future<UserModel?> getUserById(String userId) async {
    try {
      final response = await _client
          .from('users')
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (response == null) return null;
      return UserModel.fromJson(response);
    } on AuthException catch (e) {
      throw AppAuthException(e.message);
    } catch (e) {
      throw AppAuthException('Failed to fetch user: ${e.toString()}');
    }
  }

  /// Update user profile
  Future<UserModel> updateUser({
    required String userId,
    String? name,
    String? phone,
    double? locationLat,
    double? locationLng,
  }) async {
    try {
      final updateData = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (name != null) updateData['name'] = name;
      if (phone != null) updateData['phone'] = phone;
      if (locationLat != null) updateData['location_lat'] = locationLat;
      if (locationLng != null) updateData['location_lng'] = locationLng;

      final response = await _client
          .from('users')
          .update(updateData)
          .eq('id', userId)
          .select()
          .single();

      return UserModel.fromJson(response);
    } on AuthException catch (e) {
      throw AppAuthException(e.message);
    } catch (e) {
      throw AppAuthException('Failed to update user: ${e.toString()}');
    }
  }

  /// Update password for custom users table
  Future<void> updatePassword({
    required String userId,
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      // 1. Get current user's hash
      final userResponse = await _client
          .from('users')
          .select('password_hash')
          .eq('id', userId)
          .single();
      
      // 2. Verify current password
      final currentHash = _hashPassword(currentPassword);
      if (userResponse['password_hash'] != currentHash) {
        throw AppAuthException('Current password is incorrect');
      }

      // 3. Hash new password and update
      final newHash = _hashPassword(newPassword);
      await _client
          .from('users')
          .update({
            'password_hash': newHash,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', userId);

    } on AuthException catch (e) {
      throw AppAuthException(e.message);
    } catch (e) {
      throw AppAuthException('Failed to update password: ${e.toString()}');
    }
  }

  /// Sign out (just clear local state - handled in app)
  Future<void> signOut() async {
    // No server-side sign out needed for custom auth
  }
}
