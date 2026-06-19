import 'package:equatable/equatable.dart';

// ---------------------------------------------------------------------------
// Failures  (domain layer — what blocs/cubits receive)
// ---------------------------------------------------------------------------

abstract class Failure extends Equatable {
  final String message;
  const Failure(this.message);

  @override
  List<Object> get props => [message];
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'No internet connection']);
}

class ServerFailure extends Failure {
  final int? statusCode;
  const ServerFailure([super.message = 'Server error', this.statusCode]);

  @override
  List<Object> get props => [message, statusCode ?? 0];
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Cache error']);
}

class AuthFailure extends Failure {
  const AuthFailure([super.message = 'Authentication failed']);
}

class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = 'Not found']);
}

class UnknownFailure extends Failure {
  const UnknownFailure([super.message = 'Something went wrong']);
}

// ---------------------------------------------------------------------------
// Exceptions  (data layer — thrown by datasources, caught by repositories)
// ---------------------------------------------------------------------------

class NetworkException implements Exception {
  final String message;
  const NetworkException([this.message = 'No internet connection']);
}

class ServerException implements Exception {
  final String message;
  final int? statusCode;
  const ServerException([this.message = 'Server error', this.statusCode]);
}

class CacheException implements Exception {
  final String message;
  const CacheException([this.message = 'Cache error']);
}

class AuthException implements Exception {
  final String message;
  const AuthException([this.message = 'Authentication failed']);
}

class NotFoundException implements Exception {
  final String message;
  const NotFoundException([this.message = 'Not found']);
}