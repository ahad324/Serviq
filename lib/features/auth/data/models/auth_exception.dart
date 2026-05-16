class AppAuthException implements Exception {
  final String message;

  AppAuthException(this.message);

  @override
  String toString() => message;
}

class UserAlreadyExistsException extends AppAuthException {
  UserAlreadyExistsException()
    : super('User already exists with this email or phone');
}

class InvalidCredentialsException extends AppAuthException {
  InvalidCredentialsException() : super('Invalid email or password');
}

class UserNotFoundException extends AppAuthException {
  UserNotFoundException() : super('User not found');
}

class WeakPasswordException extends AppAuthException {
  WeakPasswordException() : super('Password must be at least 8 characters');
}
