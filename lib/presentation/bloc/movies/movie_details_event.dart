part of 'movie_details_bloc.dart';

abstract class MovieDetailsEvent extends Equatable {
  const MovieDetailsEvent();
  @override
  List<Object?> get props => [];
}

class MovieDetailsFetchEvent extends MovieDetailsEvent {
  final String movieId;
  final Movie? initialMovie;

  const MovieDetailsFetchEvent({
    required this.movieId,
    this.initialMovie,
  });

  @override
  List<Object?> get props => [movieId];
}