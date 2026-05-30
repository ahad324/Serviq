import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/user_model.dart';

class SessionNotifier extends Notifier<UserModel?> {
  late SharedPreferences _prefs;
  final Completer<void> _initCompleter = Completer<void>();

  Future<void> get initializationComplete => _initCompleter.future;
  
  static const String _sessionKey = 'user_session';

  @override
  UserModel? build() {
    // Initialize SharedPreferences asynchronously
    _initializeSession();
    
    final auth = Supabase.instance.client.auth;
    
    // Check for existing session on startup
    final session = auth.currentSession;
    if (session != null) {
      return _convertSupabaseUser(session.user);
    }

    // Listen to auth state changes to update state automatically
    auth.onAuthStateChange.listen((data) {
      final AuthChangeEvent event = data.event;
      final Session? session = data.session;

      if (event == AuthChangeEvent.signedIn || event == AuthChangeEvent.tokenRefreshed) {
        if (session != null) {
          final user = _convertSupabaseUser(session.user);
          state = user;
          _saveSession(user);
        }
      } else if (event == AuthChangeEvent.signedOut) {
        state = null;
        _clearSession();
      }
    });

    return null;
  }

  Future<void> _initializeSession() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      
      // Try to restore session from SharedPreferences
      final savedUserJson = _prefs.getString(_sessionKey);
      if (savedUserJson != null) {
        try {
          final user = UserModel.fromJson(jsonDecode(savedUserJson));
          state = user;
        } catch (_) {
          // Fail silently
        }
      }
    } finally {
      if (!_initCompleter.isCompleted) {
        _initCompleter.complete();
      }
    }
  }

  UserModel _convertSupabaseUser(User user) {
    final metadata = user.userMetadata ?? {};
    return UserModel(
      id: user.id,
      name: metadata['name'] ?? 'User',
      email: user.email ?? '',
      phone: metadata['phone'] ?? '',
      createdAt: DateTime.parse(user.createdAt),
      updatedAt: DateTime.now(),
    );
  }

  Future<void> _saveSession(UserModel user) async {
    try {
      final userJson = jsonEncode(user.toJson());
      await _prefs.setString(_sessionKey, userJson);
    } catch (_) {
      // Fail silently
    }
  }

  Future<void> _clearSession() async {
    try {
      await _prefs.remove(_sessionKey);
    } catch (_) {
      // Fail silently
    }
  }

  void setUser(UserModel user) {
    state = user;
    _saveSession(user);
  }

  void clearUser() {
    state = null;
    _clearSession();
  }

  bool get isAuthenticated => state != null;

  UserModel? get user => state;
}

final sessionNotifierProvider =
    NotifierProvider<SessionNotifier, UserModel?>(SessionNotifier.new);
