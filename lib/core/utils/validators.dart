import '../constants/app_constants.dart';

class AppValidators {
  AppValidators._();

  static String? email(String? value) {
    if (value == null || value.isEmpty) return 'Email is required';
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) return 'Enter a valid email address';
    return null;
  }

  static String? aluEmail(String? value) {
    final base = email(value);
    if (base != null) return base;
    final isAlu = AppConstants.aluDomains.any((d) => value!.endsWith(d));
    if (!isAlu) return 'Use your ALU email (@alustudent.com or @alueducation.com)';
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 8) return 'Password must be at least 8 characters';
    if (!RegExp(r'[A-Z]').hasMatch(value)) return 'Include at least one uppercase letter';
    if (!RegExp(r'[0-9]').hasMatch(value)) return 'Include at least one number';
    return null;
  }

  static String? confirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) return 'Please confirm your password';
    if (value != password) return 'Passwords do not match';
    return null;
  }

  static String? required(String? value, {String fieldName = 'This field'}) {
    if (value == null || value.trim().isEmpty) return '$fieldName is required';
    return null;
  }

  static String? minLength(String? value, int min, {String fieldName = 'This field'}) {
    if (value == null || value.isEmpty) return '$fieldName is required';
    if (value.length < min) return '$fieldName must be at least $min characters';
    return null;
  }

  static String? url(String? value) {
    if (value == null || value.isEmpty) return null;
    final urlRegex = RegExp(
      r'^(https?:\/\/)?([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w \.-]*)*\/?$',
    );
    if (!urlRegex.hasMatch(value)) return 'Enter a valid URL';
    return null;
  }

  static String? phone(String? value) {
    if (value == null || value.isEmpty) return null;
    if (!RegExp(r'^\+?[\d\s\-]{7,15}$').hasMatch(value)) {
      return 'Enter a valid phone number';
    }
    return null;
  }
}
