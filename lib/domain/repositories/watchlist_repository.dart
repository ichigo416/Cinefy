import 'package:dartz/dartz.dart';

import '../../core/errors/failures.dart';

abstract class WatchlistRepository {
  /// Returns the IDs of movies currently saved in the user's watchlist.
  Future<Either<Failure, List<String>>> getWatchlistIds();

  /// Adds the given movie ID to the watchlist.
  Future<Either<Failure, bool>> addWatchlistId(String movieId);

  /// Removes the given movie ID from the watchlist.
  Future<Either<Failure, bool>> removeWatchlistId(String movieId);

  /// Returns `true` when the given movie ID is already saved.
  Future<Either<Failure, bool>> isWatched(String movieId);
}
