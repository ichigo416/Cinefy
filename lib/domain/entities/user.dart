import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String? name;
  final String phoneNumber;
  final String? email;
  final String? photoUrl;
  final String? city;
  final DateTime createdAt;

  const User({
    required this.id,
    this.name,
    required this.phoneNumber,
    this.email,
    this.photoUrl,
    this.city,
    required this.createdAt,
  });

  bool get isProfileComplete => name != null && name!.isNotEmpty;

  User copyWith({
    String? name,
    String? email,
    String? photoUrl,
    String? city,
  }) {
    return User(
      id: id,
      name: name ?? this.name,
      phoneNumber: phoneNumber,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      city: city ?? this.city,
      createdAt: createdAt,
    );
  }

  @override
  List<Object?> get props => [id, phoneNumber];
} 