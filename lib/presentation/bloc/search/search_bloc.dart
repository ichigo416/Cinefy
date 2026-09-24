import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/movie.dart';
import '../../../domain/repositories/movie_repository.dart';

// ---------------------------------------------------------------------------
// Events
// ---------------------------------------------------------------------------

abstract class SearchEvent extends Equatable {
  const SearchEvent();

  @override
  List<Object?> get props => [];
}

/// Fired by the UI once the input debounce elapses. The query is untrusted
/// user input — it is only ever passed to the repository, never interpolated
/// into URLs, queries or logs.
class SearchQueryChanged extends SearchEvent {
  final String query;

  const SearchQueryChanged(this.query);

  @override
  List<Object?> get props => [query];
}

class SearchCleared extends SearchEvent {
  const SearchCleared();
}

class SearchRetried extends SearchEvent {
  const SearchRetried();
}

// ---------------------------------------------------------------------------
// States
// ---------------------------------------------------------------------------

abstract class SearchState extends Equatable {
  final String query;

  const SearchState({this.query = ''});

  @override
  List<Object?> get props => [];
}

class SearchInitial extends SearchState {
  const SearchInitial();
}

class SearchLoading extends SearchState {
  const SearchLoading({required super.query});

  @override
  List<Object?> get props => [query];
}

class SearchSuccess extends SearchState {
  final List<Movie> results;

  const SearchSuccess({
    required super.query,
    required this.results,
  });

  @override
  List<Object?> get props => [query, results];
}

class SearchEmpty extends SearchState {
  const SearchEmpty({required super.query});

  @override
  List<Object?> get props => [query];
}

class SearchFailure extends SearchState {
  final String message;

  const SearchFailure({required super.query, required this.message});

  @override
  List<Object?> get props => [query, message];
}


class SearchBloc extends Bloc<SearchEvent, SearchState> {
  static const int _maxQueryLength = 100;

  final MovieRepository _movieRepository;

  /// Query last sent to the repository. Used to avoid duplicate searches
  /// for the same input and to support retry after a failure.
  String _lastQuery = '';

  SearchBloc(this._movieRepository) : super(const SearchInitial()) {
    on<SearchQueryChanged>(_onQueryChanged);
    on<SearchCleared>(_onCleared);
    on<SearchRetried>(_onRetried);
  }

  Future<void> _onQueryChanged(
    SearchQueryChanged event,
    Emitter<SearchState> emit,
  ) async {
    final query = _normalize(event.query);

    // Empty / whitespace-only input never triggers a search.
    if (query.isEmpty) {
      _onCleared(const SearchCleared(), emit);
      return;
    }

    // Same query already loading / loaded — skip the duplicate repository
    // call. A failure is retried on purpose (user re-submitted the query).
    if (query == _lastQuery && state is! SearchFailure) return;

    _lastQuery = query;
    await _runSearch(query, emit);
  }

  void _onCleared(SearchCleared event, Emitter<SearchState> emit) {
    _lastQuery = '';
    emit(const SearchInitial());
  }

  Future<void> _onRetried(
    SearchRetried event,
    Emitter<SearchState> emit,
  ) async {
    if (_lastQuery.isEmpty) return;
    await _runSearch(_lastQuery, emit);
  }

  Future<void> _runSearch(String query, Emitter<SearchState> emit) async {
    emit(SearchLoading(query: query));

    final result = await _movieRepository.searchMovies(query);

    // Bloc events are processed sequentially, so this result always belongs
    // to the latest query. Nothing stale can be emitted here.
    if (isClosed) return;

    result.fold(
      (failure) => emit(SearchFailure(query: query, message: failure.message)),
      (movies) => emit(
        movies.isEmpty
            ? SearchEmpty(query: query)
            : SearchSuccess(query: query, results: movies),
      ),
    );
  }

  /// Sanitizes untrusted input before it reaches the repository: trims
  /// whitespace and clamps pathological oversized queries.
  String _normalize(String raw) {
    final trimmed = raw.trim();
    if (trimmed.length <= _maxQueryLength) return trimmed;
    return trimmed.substring(0, _maxQueryLength);
  }
}