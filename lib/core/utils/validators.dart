class Validators {
  Validators._();

  static String? required(
    String? value, {
    String fieldName = 'This field',
  }) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }

    final phone = value.trim();

    if (!RegExp(r'^[0-9]{10}$').hasMatch(phone)) {
      return 'Enter a valid 10-digit phone number';
    }

    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }

    if (!RegExp(
      r'^[\w\-.]+@([\w-]+\.)+[\w-]{2,4}$',
    ).hasMatch(value.trim())) {
      return 'Enter a valid email address';
    }

    return null;
  }

  static String? otp(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'OTP is required';
    }

    if (!RegExp(r'^[0-9]{6}$').hasMatch(value.trim())) {
      return 'Enter a valid 6-digit OTP';
    }

    return null;
  }

  static String? name(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Name is required';
    }

    if (value.trim().length < 2) {
      return 'Name must contain at least 2 characters';
    }

    return null;
  }
} 