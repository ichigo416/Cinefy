import '../../domain/entities/theatre.dart';
import 'show_model.dart';

class TheatreModel extends Theatre {
  const TheatreModel({
    required super.id,
    required super.name,
    required super.address,
    required super.city,
    required super.distanceKm,
    required super.rating,
    required super.amenities,
    required super.shows,
  });

  factory TheatreModel.fromJson(Map<String, dynamic> json) {
    return TheatreModel(
      id: json['id'] as String,
      name: json['name'] as String,
      address: json['address'] as String,
      city: json['city'] as String,
      distanceKm: (json['distance_km'] as num).toDouble(),
      rating: (json['rating'] as num).toDouble(),
      amenities: List<String>.from(json['amenities'] as List),
      shows: (json['shows'] as List? ?? [])
          .map((s) => ShowModel.fromJson(s as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'city': city,
      'distance_km': distanceKm,
      'rating': rating,
      'amenities': amenities,
    };
  }
} 