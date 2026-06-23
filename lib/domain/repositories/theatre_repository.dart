import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/theatre.dart';

abstract class TheatreRepository {
  Future<Either<Failure, List<Theatre>>> getTheatresForMovie({
    required String movieId,
    required String city,
    required DateTime date,
    String? language,
    String? format,
  });
}