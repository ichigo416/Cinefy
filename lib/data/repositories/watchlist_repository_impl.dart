import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../../domain/repositories/watchlist_repository.dart';
import '../datasources/local/watchlist_local_datasource.dart';

class WatchlistRepositoryImpl implements WatchlistRepository {
  final WatchlistLocalDatasource _local;

  WatchlistRepositoryImpl(this._local);

  @override
  Future<Either<Failure, List<String>>> getWatchlistIds() async {
    try {
      final ids = await _local.getWatchlistIds();
      return Right(ids);
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, bool>> addWatchlistId(String movieId) async {
    try {
      final added = await _local.addWatchlistId(movieId);
      return Right(added);
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, bool>> removeWatchlistId(String movieId) async {
    try {
      final removed = await _local.removeWatchlistId(movieId);
      return Right(removed);
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, bool>> isWatched(String movieId) async {
    try {
      final watched = await _local.isWatched(movieId);
      return Right(watched);
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }
}