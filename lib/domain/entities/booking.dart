import 'package:equatable/equatable.dart';
import 'seat.dart';

class Booking extends Equatable {
  final String id;
  final String movieId;
  final String movieTitle;
  final String moviePosterUrl;
  final String theatreName;
  final String theatreAddress;
  final DateTime showTime;
  final String language;
  final String format;
  final List<Seat> selectedSeats;
  final List<FoodItem> foodItems;
  final double baseAmount;
  final double convenienceFee;
  final double taxes;
  final double totalAmount;
  final String? promoCode;
  final double discountAmount;
  final BookingStatus status;
  final String? transactionId;
  final DateTime bookedAt;
  final String qrData; // encoded string for QR generation

  const Booking({
    required this.id,
    required this.movieId,
    required this.movieTitle,
    required this.moviePosterUrl,
    required this.theatreName,
    required this.theatreAddress,
    required this.showTime,
    required this.language,
    required this.format,
    required this.selectedSeats,
    this.foodItems = const [],
    required this.baseAmount,
    required this.convenienceFee,
    required this.taxes,
    required this.totalAmount,
    this.promoCode,
    this.discountAmount = 0,
    required this.status,
    this.transactionId,
    required this.bookedAt,
    required this.qrData,
  });

  String get seatLabels =>
      selectedSeats.map((s) => s.label).join(', ');

  String get seatCount => '${selectedSeats.length} Ticket${selectedSeats.length > 1 ? 's' : ''}';

  bool get isUpcoming =>
      showTime.isAfter(DateTime.now()) && status == BookingStatus.confirmed;

  @override
  List<Object?> get props => [id, status];
}

class FoodItem extends Equatable {
  final String id;
  final String name;
  final String? imageUrl;
  final double price;
  final bool isVeg;
  int quantity;

  FoodItem({
    required this.id,
    required this.name,
    this.imageUrl,
    required this.price,
    required this.isVeg,
    this.quantity = 1,
  });

  double get totalPrice => price * quantity;

  @override
  List<Object?> get props => [id, quantity];
}

enum BookingStatus { pending, confirmed, cancelled, failed, refunded } 