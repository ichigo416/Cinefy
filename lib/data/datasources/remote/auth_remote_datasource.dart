import 'dart:math';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../core/errors/failures.dart';
import '../../../services/api_service.dart';
import '../../models/user_model.dart';

class AuthRemoteDatasource {
  static const _tokenKey = 'cinefy_access_token';
  static const _secureStorage = FlutterSecureStorage();

  final ApiService _api;
  final bool mockEnabled;

  UserModel? _currentUser;
  final Map<String, String> _pendingOtps = {};

  AuthRemoteDatasource([ApiService? api, this.mockEnabled = true])
    : _api = api ?? ApiService();

  Future<String> sendOtp(String phoneNumber) async {
    if (mockEnabled) {
      await Future.delayed(const Duration(milliseconds: 900));
      if (phoneNumber.length != 10) {
        throw const AuthException('Enter a valid 10-digit phone number');
      }
      final verificationId = 'verif_${DateTime.now().millisecondsSinceEpoch}';
      _pendingOtps[verificationId] = '123456';
      return verificationId;
    }

    final response = await _api.post(
      '/auth/send-otp',
      data: {'phone_number': phoneNumber},
    );

    final verificationId = response.data['verification_id'] as String;
    return verificationId;
  }

  Future<UserModel> verifyOtp({
    required String verificationId,
    required String otp,
  }) async {
    if (mockEnabled) {
      await Future.delayed(const Duration(milliseconds: 900));
      final expectedOtp = _pendingOtps[verificationId];
      if (expectedOtp == null) {
        throw const AuthException('OTP expired. Please request a new one.');
      }
      if (expectedOtp != otp) {
        throw const AuthException('Incorrect OTP. Please try again.');
      }
      _pendingOtps.remove(verificationId);
      final user = UserModel(
        id: 'user_${Random().nextInt(100000)}',
        phoneNumber: '9876543210',
        createdAt: DateTime.now(),
      );
      _currentUser = user;
      return user;
    }

    final response = await _api.post(
      '/auth/verify-otp',
      data: {'verification_id': verificationId, 'otp': otp},
    );
    await _setTokenFromResponse(response.data);
    final user = UserModel.fromJson(
      response.data['user'] as Map<String, dynamic>,
    );
    _currentUser = user;
    return user;
  }

  Future<UserModel> signInWithGoogle() async {
    if (mockEnabled) {
      await Future.delayed(const Duration(milliseconds: 1200));
      final user = UserModel(
        id: 'google_${Random().nextInt(100000)}',
        name: 'Ichigo Kurosaki',
        phoneNumber: '9123456780',
        email: 'ichigo@example.com',
        createdAt: DateTime.now(),
      );
      _currentUser = user;
      return user;
    }

    final response = await _api.post('/auth/google-signin');
    await _setTokenFromResponse(response.data);
    final user = UserModel.fromJson(
      response.data['user'] as Map<String, dynamic>,
    );
    _currentUser = user;
    return user;
  }

  Future<UserModel> getCurrentUser() async {
    if (mockEnabled) {
      await Future.delayed(const Duration(milliseconds: 300));
      if (_currentUser == null) {
        throw const AuthException('No active session');
      }
      return _currentUser!;
    }

    if (!_api.hasAuthToken) {
      final token = await _secureStorage.read(key: _tokenKey);
      if (token == null || token.isEmpty) {
        throw const AuthException('No active session');
      }
      _api.setAuthToken(token);
    }

    try {
      final response = await _api.get('/auth/me');
      final user = UserModel.fromJson(
        response.data['user'] as Map<String, dynamic>,
      );
      _currentUser = user;
      return user;
    } on AuthException {
      await _secureStorage.delete(key: _tokenKey);
      _api.clearAuthToken();
      rethrow;
    }
  }

  Future<UserModel?> restoreSession() async {
    if (mockEnabled) return _currentUser;

    final token = await _secureStorage.read(key: _tokenKey);
    if (token == null || token.isEmpty) return null;

    _api.setAuthToken(token);
    try {
      return await getCurrentUser();
    } on AuthException {
      await _secureStorage.delete(key: _tokenKey);
      _api.clearAuthToken();
      return null;
    }
  }

  Future<UserModel> updateProfile({
    String? name,
    String? email,
    String? photoUrl,
    String? city,
  }) async {
    if (mockEnabled) {
      await Future.delayed(const Duration(milliseconds: 600));
      if (_currentUser == null) {
        throw const AuthException('No active session');
      }
      _currentUser = UserModel.fromEntity(
        _currentUser!.copyWith(
          name: name,
          email: email,
          photoUrl: photoUrl,
          city: city,
        ),
      );
      return _currentUser!;
    }

    final response = await _api.put(
      '/auth/profile',
      data: {'name': name, 'email': email, 'photo_url': photoUrl, 'city': city}
        ..removeWhere((key, value) => value == null),
    );
    final user = UserModel.fromJson(
      response.data['user'] as Map<String, dynamic>,
    );
    _currentUser = user;
    return user;
  }

  Future<bool> signOut() async {
    if (mockEnabled) {
      await Future.delayed(const Duration(milliseconds: 300));
      _currentUser = null;
      return true;
    }

    try {
      await _api.post('/auth/logout');
    } finally {
      _currentUser = null;
      _api.clearAuthToken();
      await _secureStorage.delete(key: _tokenKey);
    }
    return true;
  }

  Future<void> _setTokenFromResponse(dynamic data) async {
    if (data is! Map<String, dynamic>) return;
    final payload = data['data'] is Map<String, dynamic>
        ? data['data'] as Map<String, dynamic>
        : data;
    final token = payload['access_token'] ?? payload['token'];
    if (token is String && token.isNotEmpty) {
      _api.setAuthToken(token);
      await _secureStorage.write(key: _tokenKey, value: token);
    }
  }

  Stream<UserModel?> get authStateChanges async* {
    yield _currentUser;
  }
}
