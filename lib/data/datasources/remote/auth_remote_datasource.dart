import 'dart:math';
import '../../models/user_model.dart';
import '../../../core/errors/failures.dart';

// Mock auth datasource — simulates OTP flow without a real backend/Firebase.
// Swap with real Firebase Auth calls when ready.

class AuthRemoteDatasource {
  // In-memory "session" so getCurrentUser() works after sign-in during this run.
  UserModel? _currentUser;
  final Map<String, String> _pendingOtps = {}; // verificationId -> otp

  Future<String> sendOtp(String phoneNumber) async {
    await Future.delayed(const Duration(milliseconds: 900));

    if (phoneNumber.length != 10) {
      throw const AuthException('Enter a valid 10-digit phone number');
    }

    final verificationId = 'verif_${DateTime.now().millisecondsSinceEpoch}';
    // Mock OTP is always 123456 for easy local testing
    _pendingOtps[verificationId] = '123456';
    return verificationId;
  }

  Future<UserModel> verifyOtp({
    required String verificationId,
    required String otp,
  }) async {
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

  Future<UserModel> signInWithGoogle() async {
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

  Future<UserModel> getCurrentUser() async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (_currentUser == null) {
      throw const AuthException('No active session');
    }
    return _currentUser!;
  }

  Future<UserModel> updateProfile({
    String? name,
    String? email,
    String? photoUrl,
    String? city,
  }) async {
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

  Future<bool> signOut() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _currentUser = null;
    return true;
  }

  // Simple polling-free stream — emits once on creation.
  // Replace with Firebase's authStateChanges() stream in production.
  Stream<UserModel?> get authStateChanges async* {
    yield _currentUser;
  }
}