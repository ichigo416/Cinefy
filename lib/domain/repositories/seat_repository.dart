import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/seat.dart';

abstract class SeatRepository {
  Future<Either<Failure, SeatLayout>> getSeatLayout(String showId);
} 