import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/theatre.dart';
import '../../domain/repositories/theatre_repository.dart';
import '../datasources/remote/theatre_remote_datasource.dart';

class TheatreRepositoryImpl implements TheatreRepository {
  final TheatreRemoteDatasource _remote;

  TheatreRepositoryImpl(this._remote);

  @override
  Future<Either<Failure, List<Theatre>>> getTheatresForMovie({
    required String movieId,
    required String city,
    required DateTime date,
    String? language,
    String? format,
  }) async {
    try {
      final theatres = await _remote.fetchTheatresForMovie(
        movieId: movieId,
        city: city,
        date: date,
        language: language,
        format: format,
      );
      return Right(theatres);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.statusCode));
    } catch (e) {
      return const Left(UnknownFailure());
    }
  }
}