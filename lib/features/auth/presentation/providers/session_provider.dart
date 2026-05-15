import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/models/user_model.dart';

class SessionNotifier extends Notifier<UserModel?> {
  @override
  UserModel? build() {
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
          state = _convertSupabaseUser(session.user);
        }
      } else if (event == AuthChangeEvent.signedOut) {
        state = null;
      }
    });

    return null;
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

  void setUser(UserModel user) {
    state = user;
  }

  void clearUser() {
    state = null;
  }

  bool get isAuthenticated => state != null;

  UserModel? get user => state;
}

final sessionNotifierProvider =
    NotifierProvider<SessionNotifier, UserModel?>(SessionNotifier.new);
