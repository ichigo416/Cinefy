import 'dart:math';

import '../../../core/errors/failures.dart';
import '../../../domain/entities/booking.dart';
import '../../../domain/entities/seat.dart';
import '../../../services/api_service.dart';
import '../../models/booking_model.dart';

class BookingRemoteDatasource {
  final ApiService _api;
  final bool mockEnabled;
  final List<BookingModel> _bookings = [];

  BookingRemoteDatasource([ApiService? api, this.mockEnabled = true])
    : _api = api ?? ApiService();

  Future<BookingModel> createBooking({
    required String showId,
    required List<Seat> seats,
    required String movieId,
    required String movieTitle,
    required String moviePosterUrl,
    required String theatreName,
    required String theatreAddress,
    required DateTime showTime,
    required String language,
    required String format,
    required List<FoodItemModel> foodItems,
    required Map<SeatCategory, double> pricing,
    String? promoCode,
  }) async {
    if (mockEnabled) {
      await Future.delayed(const Duration(milliseconds: 1100));
      if (seats.isEmpty) {
        throw const ServerException('Select at least one seat to proceed');
      }

      final baseAmount = seats.fold<double>(
        0,
        (sum, seat) => sum + (pricing[seat.category] ?? 0),
      );

      final foodAmount = foodItems.fold<double>(
        0,
        (sum, foodItem) => sum + foodItem.totalPrice,
      );

      final subtotal = baseAmount + foodAmount;
      final convenienceFee = (seats.length * 30).toDouble();
      final taxes = (subtotal + convenienceFee) * 0.18;

      double discount = 0;
      if (promoCode != null && promoCode.toUpperCase() == 'FIRST50') {
        discount = min(50, subtotal * 0.1);
      }

      final total = subtotal + convenienceFee + taxes - discount;
      final bookingId = 'CIN${Random().nextInt(900000) + 100000}';
      final booking = BookingModel(
        id: bookingId,
        movieId: movieId,
        movieTitle: movieTitle,
        moviePosterUrl: moviePosterUrl,
        theatreName: theatreName,
        theatreAddress: theatreAddress,
        showTime: showTime,
        language: language,
        format: format,
        selectedSeats: seats,
        foodItems: foodItems,
        baseAmount: baseAmount,
        convenienceFee: convenienceFee,
        taxes: taxes,
        totalAmount: total,
        promoCode: promoCode,
        discountAmount: discount,
        status: BookingStatus.confirmed,
        transactionId: 'TXN${Random().nextInt(900000) + 100000}',
        bookedAt: DateTime.now(),
        qrData: bookingId,
      );
      _bookings.add(booking);
      return booking;
    }

    final response = await _api.post(
      '/bookings',
      data: {
        'show_id': showId,
        'movie_id': movieId,
        'movie_title': movieTitle,
        'movie_poster_url': moviePosterUrl,
        'theatre_name': theatreName,
        'theatre_address': theatreAddress,
        'show_time': showTime.toIso8601String(),
        'language': language,
        'format': format,
        'selected_seats': seats.map(_seatToJson).toList(),
        'food_items': foodItems.map((item) => item.toJson()).toList(),
        'promo_code': promoCode,
      },
    );

    return BookingModel.fromJson(
      response.data['booking'] as Map<String, dynamic>,
    );
  }

  Future<List<BookingModel>> fetchMyBookings() async {
    if (mockEnabled) {
      await Future.delayed(const Duration(milliseconds: 600));
      return _bookings.reversed.toList();
    }

    final response = await _api.get('/bookings/me');
    final items = response.data['bookings'] as List;
    return items
        .map((json) => BookingModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<BookingModel> fetchBookingDetails(String bookingId) async {
    if (mockEnabled) {
      await Future.delayed(const Duration(milliseconds: 400));
      final booking = _bookings.firstWhere(
        (b) => b.id == bookingId,
        orElse: () => throw const NotFoundException('Booking not found'),
      );
      return booking;
    }

    final response = await _api.get('/bookings/$bookingId');
    return BookingModel.fromJson(
      response.data['booking'] as Map<String, dynamic>,
    );
  }

  Future<bool> cancelBooking(String bookingId) async {
    if (mockEnabled) {
      await Future.delayed(const Duration(milliseconds: 700));
      final index = _bookings.indexWhere((b) => b.id == bookingId);
      if (index == -1) {
        throw const NotFoundException('Booking not found');
      }
      final old = _bookings[index];
      _bookings[index] = BookingModel(
        id: old.id,
        movieId: old.movieId,
        movieTitle: old.movieTitle,
        moviePosterUrl: old.moviePosterUrl,
        theatreName: old.theatreName,
        theatreAddress: old.theatreAddress,
        showTime: old.showTime,
        language: old.language,
        format: old.format,
        selectedSeats: old.selectedSeats,
        foodItems: old.foodItems,
        baseAmount: old.baseAmount,
        convenienceFee: old.convenienceFee,
        taxes: old.taxes,
        totalAmount: old.totalAmount,
        promoCode: old.promoCode,
        discountAmount: old.discountAmount,
        status: BookingStatus.cancelled,
        transactionId: old.transactionId,
        bookedAt: old.bookedAt,
        qrData: old.qrData,
      );
      return true;
    }

    final response = await _api.post('/bookings/$bookingId/cancel');
    return response.data['success'] as bool? ?? true;
  }

  Map<String, dynamic> _seatToJson(Seat seat) {
    return {
      'id': seat.id,
      'row_label': seat.rowLabel,
      'seat_number': seat.seatNumber,
      'category': seat.category.name,
      'status': seat.status.name,
    };
  }
}
