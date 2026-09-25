import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/repositories/watchlist_repository.dart';
import 'watchlist_state.dart';

class WatchlistCubit extends Cubit<WatchlistState> {
  final WatchlistRepository _repository;

  WatchlistCubit(this._repository) : super(WatchlistInitial());

  Future<void> load() async {
    emit(WatchlistLoading());

    final result = await _repository.getWatchlistIds();
    result.fold(
      (failure) => emit(WatchlistError(failure.message)),
      (ids) => emit(WatchlistLoaded(ids)),
    );
  }

  Future<void> toggle(String movieId) async {
    final current = state;
    final currentlySaved =
        current is WatchlistLoaded && current.ids.contains(movieId);

    final result = currentlySaved
        ? await _repository.removeWatchlistId(movieId)
        : await _repository.addWatchlistId(movieId);

    await result.fold(
      (failure) async {
        emit(WatchlistError(failure.message));
      },
      (success) async {
        await load();
      },
    );
  }
}
