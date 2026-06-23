import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/user.dart';

abstract class AuthRepository {
  /// Sends an OTP to the given 10-digit phone number.
  /// Returns a verificationId used to confirm the OTP later.
  Future<Either<Failure, String>> sendOtp(String phoneNumber);

  /// Verifies the OTP against the given verificationId and signs the user in.
  Future<Either<Failure, User>> verifyOtp({
    required String verificationId,
    required String otp,
  });

  Future<Either<Failure, User>> signInWithGoogle();

  Future<Either<Failure, User>> getCurrentUser();

  Future<Either<Failure, User>> updateProfile({
    String? name,
    String? email,
    String? photoUrl,
    String? city,
  });

  Future<Either<Failure, bool>> signOut();

  Stream<User?> get authStateChanges;
} 