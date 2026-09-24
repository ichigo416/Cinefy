part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthRestoreSessionRequested extends AuthEvent {
  const AuthRestoreSessionRequested();
}

class AuthSendOtpEvent extends AuthEvent {
  final String phoneNumber;

  const AuthSendOtpEvent(this.phoneNumber);

  @override
  List<Object?> get props => [phoneNumber];
}

class AuthVerifyOtpEvent extends AuthEvent {
  final String verificationId;
  final String otp;

  const AuthVerifyOtpEvent({required this.verificationId, required this.otp});

  @override
  List<Object?> get props => [verificationId, otp];
}

class AuthSignInWithGoogleEvent extends AuthEvent {
  const AuthSignInWithGoogleEvent();
}

class AuthSignOutRequested extends AuthEvent {
  const AuthSignOutRequested();
}
