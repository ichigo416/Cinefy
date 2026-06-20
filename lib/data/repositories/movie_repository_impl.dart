import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/movie.dart';
import '../../domain/repositories/repositories.dart';
import '../datasources/remote/movie_remote_datasource.dart';

class MovieRepositoryImpl implements MovieRepository {
  final MovieRemoteDatasource _remote;

  MovieRepositoryImpl(this._remote);

  @override
  Future<Either<Failure, List<Movie>>> getNowShowing({String? city}) async {
    try {
      final movies = await _remote.fetchNowShowing(city: city);
      return Right(movies);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.statusCode));
    } catch (e) {
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, List<Movie>>> getComingSoon({String? city}) async {
    try {
      final movies = await _remote.fetchComingSoon(city: city);
      return Right(movies);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.statusCode));
    } catch (e) {
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, Movie>> getMovieDetails(String movieId) async {
    try {
      final movie = await _remote.fetchMovieDetails(movieId);
      return Right(movie);
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, List<Movie>>> searchMovies(String query) async {
    try {
      final movies = await _remote.searchMovies(query);
      return Right(movies);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return const Left(UnknownFailure());
    }
  }
} 