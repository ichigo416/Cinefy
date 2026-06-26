import '../../domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.id,
    super.name,
    required super.phoneNumber,
    super.email,
    super.photoUrl,
    super.city,
    required super.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      name: json['name'] as String?,
      phoneNumber: json['phone_number'] as String,
      email: json['email'] as String?,
      photoUrl: json['photo_url'] as String?,
      city: json['city'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  factory UserModel.fromEntity(User user) {
    return UserModel(
      id: user.id,
      name: user.name,
      phoneNumber: user.phoneNumber,
      email: user.email,
      photoUrl: user.photoUrl,
      city: user.city,
      createdAt: user.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone_number': phoneNumber,
      'email': email,
      'photo_url': photoUrl,
      'city': city,
      'created_at': createdAt.toIso8601String(),
    };
  }
} 