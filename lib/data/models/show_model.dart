import '../../domain/entities/theatre.dart';

class ShowModel extends Show {
  const ShowModel({
    required super.id,
    required super.theatreId,
    required super.movieId,
    required super.startTime,
    required super.language,
    required super.format,
    required super.status,
    required super.totalSeats,
    required super.availableSeats,
    required super.basePrice,
  });

  factory ShowModel.fromJson(Map<String, dynamic> json) {
    return ShowModel(
      id: json['id'] as String,
      theatreId: json['theatre_id'] as String,
      movieId: json['movie_id'] as String,
      startTime: DateTime.parse(json['start_time'] as String),
      language: json['language'] as String,
      format: json['format'] as String,
      status: _statusFromString(json['status'] as String),
      totalSeats: json['total_seats'] as int,
      availableSeats: json['available_seats'] as int,
      basePrice: (json['base_price'] as num).toDouble(),
    );
  }

  static ShowStatus _statusFromString(String value) {
    switch (value) {
      case 'almost_full':
        return ShowStatus.almostFull;
      case 'sold_out':
        return ShowStatus.soldOut;
      case 'cancelled':
        return ShowStatus.cancelled;
      default:
        return ShowStatus.available;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'theatre_id': theatreId,
      'movie_id': movieId,
      'start_time': startTime.toIso8601String(),
      'language': language,
      'format': format,
      'status': status.name,
      'total_seats': totalSeats,
      'available_seats': availableSeats,
      'base_price': basePrice,
    };
  }
} 