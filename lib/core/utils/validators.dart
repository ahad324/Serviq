class AppValidators {
  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) return 'Please enter your full name';
    if (value.trim().length < 3) return 'Name is too short';
    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return 'Please enter email';
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) return 'Enter a valid email address';
    return null;
  }

  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) return 'Please enter phone number';
    // Pakistani format: 03XXXXXXXXX or +92XXXXXXXXXX
    final phoneRegex = RegExp(r'^((\+92)|(0))?3\d{9}$');
    if (!phoneRegex.hasMatch(value.trim())) return 'Invalid format (e.g. 03XXXXXXXXX)';
    return null;
  }

  static String? validatePassword(String? value, {bool isLogin = false}) {
    if (value == null || value.isEmpty) return 'Please enter password';
    if (value.length < 8) return 'Password must be at least 8 characters';
    if (isLogin) return null;
    
    if (!value.contains(RegExp(r'[A-Z]'))) return 'One uppercase letter required';
    if (!value.contains(RegExp(r'[a-z]'))) return 'One lowercase letter required';
    if (!value.contains(RegExp(r'[0-9]'))) return 'One number required';
    return null;
  }
}
