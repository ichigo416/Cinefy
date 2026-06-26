import '../../domain/entities/booking.dart';
import '../../domain/entities/seat.dart';
import 'seat_model.dart';

class BookingModel extends Booking {
  const BookingModel({
    required super.id,
    required super.movieId,
    required super.movieTitle,
    required super.moviePosterUrl,
    required super.theatreName,
    required super.theatreAddress,
    required super.showTime,
    required super.language,
    required super.format,
    required super.selectedSeats,
    super.foodItems,
    required super.baseAmount,
    required super.convenienceFee,
    required super.taxes,
    required super.totalAmount,
    super.promoCode,
    super.discountAmount,
    required super.status,
    super.transactionId,
    required super.bookedAt,
    required super.qrData,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['id'] as String,
      movieId: json['movie_id'] as String,
      movieTitle: json['movie_title'] as String,
      moviePosterUrl: json['movie_poster_url'] as String,
      theatreName: json['theatre_name'] as String,
      theatreAddress: json['theatre_address'] as String,
      showTime: DateTime.parse(json['show_time'] as String),
      language: json['language'] as String,
      format: json['format'] as String,
      selectedSeats: (json['selected_seats'] as List)
          .map((s) => SeatModel.fromJson(s as Map<String, dynamic>))
          .toList(),
      foodItems: (json['food_items'] as List? ?? [])
          .map((f) => FoodItemModel.fromJson(f as Map<String, dynamic>))
          .toList(),
      baseAmount: (json['base_amount'] as num).toDouble(),
      convenienceFee: (json['convenience_fee'] as num).toDouble(),
      taxes: (json['taxes'] as num).toDouble(),
      totalAmount: (json['total_amount'] as num).toDouble(),
      promoCode: json['promo_code'] as String?,
      discountAmount: (json['discount_amount'] as num? ?? 0).toDouble(),
      status: _statusFromString(json['status'] as String),
      transactionId: json['transaction_id'] as String?,
      bookedAt: DateTime.parse(json['booked_at'] as String),
      qrData: json['qr_data'] as String,
    );
  }

  static BookingStatus _statusFromString(String value) {
    switch (value) {
      case 'confirmed':
        return BookingStatus.confirmed;
      case 'cancelled':
        return BookingStatus.cancelled;
      case 'failed':
        return BookingStatus.failed;
      case 'refunded':
        return BookingStatus.refunded;
      default:
        return BookingStatus.pending;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'movie_id': movieId,
      'movie_title': movieTitle,
      'movie_poster_url': moviePosterUrl,
      'theatre_name': theatreName,
      'theatre_address': theatreAddress,
      'show_time': showTime.toIso8601String(),
      'language': language,
      'format': format,
      'selected_seats':
          selectedSeats.map((s) => (s as SeatModel).toJson()).toList(),
      'base_amount': baseAmount,
      'convenience_fee': convenienceFee,
      'taxes': taxes,
      'total_amount': totalAmount,
      'promo_code': promoCode,
      'discount_amount': discountAmount,
      'status': status.name,
      'transaction_id': transactionId,
      'booked_at': bookedAt.toIso8601String(),
      'qr_data': qrData,
    };
  }
}

class FoodItemModel extends FoodItem {
  FoodItemModel({
    required super.id,
    required super.name,
    super.imageUrl,
    required super.price,
    required super.isVeg,
    super.quantity,
  });

  factory FoodItemModel.fromJson(Map<String, dynamic> json) {
    return FoodItemModel(
      id: json['id'] as String,
      name: json['name'] as String,
      imageUrl: json['image_url'] as String?,
      price: (json['price'] as num).toDouble(),
      isVeg: json['is_veg'] as bool,
      quantity: json['quantity'] as int? ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image_url': imageUrl,
      'price': price,
      'is_veg': isVeg,
      'quantity': quantity,
    };
  }
}