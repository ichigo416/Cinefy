import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/movie.dart';

abstract class MovieRepository {
  Future<Either<Failure, List<Movie>>> getNowShowing({String? city});
  Future<Either<Failure, List<Movie>>> getComingSoon({String? city});
  Future<Either<Failure, Movie>> getMovieDetails(String movieId);
  Future<Either<Failure, List<Movie>>> searchMovies(String query);
} 