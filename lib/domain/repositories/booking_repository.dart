import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/booking.dart';

abstract class BookingRepository {
  Future<Either<Failure, Booking>> createBooking({
    required String showId,
    required List<String> seatIds,
    required List<FoodItem> foodItems,
    String? promoCode,
  });

  Future<Either<Failure, List<Booking>>> getMyBookings();

  Future<Either<Failure, Booking>> getBookingDetails(String bookingId);

  Future<Either<Failure, bool>> cancelBooking(String bookingId);
} 