import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../domain/entities/movie.dart';
import '../../../domain/repositories/movie_repository.dart';

part 'movie_details_event.dart';
part 'movie_details_state.dart';

class MovieDetailsBloc extends Bloc<MovieDetailsEvent, MovieDetailsState> {
  final MovieRepository _movieRepository;

  MovieDetailsBloc(this._movieRepository) : super(MovieDetailsInitial()) {
    on<MovieDetailsFetchEvent>(_onFetch);
  }

  Future<void> _onFetch(
    MovieDetailsFetchEvent event,
    Emitter<MovieDetailsState> emit,
  ) async {
    // If the movie was already passed via navigation (extra), show it
    // immediately while we refresh details in the background — avoids
    // a loading flicker when coming from the home screen's movie card.
    if (event.initialMovie != null) {
      emit(MovieDetailsLoaded(event.initialMovie!));
    } else {
      emit(MovieDetailsLoading());
    }

    final result = await _movieRepository.getMovieDetails(event.movieId);

    result.fold(
      (failure) {
        // Only surface the error if we have nothing to show at all
        if (event.initialMovie == null) {
          emit(MovieDetailsError(failure.message));
        }
      },
      (movie) => emit(MovieDetailsLoaded(movie)),
    );
  }
}