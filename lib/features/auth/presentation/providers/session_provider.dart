import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/user_model.dart';

class SessionNotifier extends Notifier<UserModel?> {
  @override
  UserModel? build() => null;

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
