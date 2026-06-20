import 'package:equatable/equatable.dart';

class Theatre extends Equatable {
  final String id;
  final String name;
  final String address;
  final String city;
  final double distanceKm;
  final double rating;
  final List<String> amenities; // Parking, Food Court, M-Ticket, etc.
  final List<Show> shows;

  const Theatre({
    required this.id,
    required this.name,
    required this.address,
    required this.city,
    required this.distanceKm,
    required this.rating,
    required this.amenities,
    required this.shows,
  });

  @override
  List<Object?> get props => [id];
}

class Show extends Equatable {
  final String id;
  final String theatreId;
  final String movieId;
  final DateTime startTime;
  final String language;
  final String format;         // 2D, 3D, IMAX
  final ShowStatus status;
  final int totalSeats;
  final int availableSeats;
  final double basePrice;

  const Show({
    required this.id,
    required this.theatreId,
    required this.movieId,
    required this.startTime,
    required this.language,
    required this.format,
    required this.status,
    required this.totalSeats,
    required this.availableSeats,
    required this.basePrice,
  });

  bool get hasGoodAvailability => availableSeats > (totalSeats * 0.3);
  bool get isAlmostFull =>
      availableSeats > 0 && availableSeats <= (totalSeats * 0.2);
  bool get isSoldOut => availableSeats == 0;

  String get formattedTime {
    final h = startTime.hour;
    final m = startTime.minute.toString().padLeft(2, '0');
    final period = h >= 12 ? 'PM' : 'AM';
    final hour = h > 12 ? h - 12 : (h == 0 ? 12 : h);
    return '$hour:$m $period';
  }

  @override
  List<Object?> get props => [id];
}

enum ShowStatus { available, almostFull, soldOut, cancelled } 