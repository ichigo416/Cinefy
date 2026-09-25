import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/theatre.dart';
import '../../../domain/repositories/theatre_repository.dart';

abstract class TheatreEvent extends Equatable {
  const TheatreEvent();

  @override
  List<Object?> get props => [];
}

class TheatreFetchEvent extends TheatreEvent {
  final String movieId;
  final String city;
  final DateTime date;

  const TheatreFetchEvent({
    required this.movieId,
    required this.city,
    required this.date,
  });

  @override
  List<Object?> get props => [movieId, city, date];
}

class TheatreDateChangedEvent extends TheatreEvent {
  final DateTime date;

  const TheatreDateChangedEvent(this.date);

  @override
  List<Object?> get props => [date];
}

class TheatreFilterChangedEvent extends TheatreEvent {
  final String? language;
  final String? format;

  const TheatreFilterChangedEvent({this.language, this.format});

  @override
  List<Object?> get props => [language, format];
}

abstract class TheatreState extends Equatable {
  const TheatreState();

  @override
  List<Object?> get props => [];
}

class TheatreInitial extends TheatreState {}

class TheatreLoading extends TheatreState {}

class TheatreLoaded extends TheatreState {
  final List<Theatre> theatres;

  const TheatreLoaded(this.theatres);

  @override
  List<Object?> get props => [theatres];
}

class TheatreError extends TheatreState {
  final String message;

  const TheatreError(this.message);

  @override
  List<Object?> get props => [message];
}

class TheatreBloc extends Bloc<TheatreEvent, TheatreState> {
  final TheatreRepository _theatreRepository;

  // Last known query context, preserved for date/filter refetches
  String _movieId = '';
  String _city = 'Bengaluru';
  DateTime _date = DateTime.now();
  String? _language;
  String? _format;

  TheatreBloc(this._theatreRepository) : super(TheatreInitial()) {
    on<TheatreFetchEvent>(_onFetch);
    on<TheatreDateChangedEvent>(_onDateChanged);
    on<TheatreFilterChangedEvent>(_onFilterChanged);
  }

  Future<void> _onFetch(
    TheatreFetchEvent event,
    Emitter<TheatreState> emit,
  ) async {
    _movieId = event.movieId;
    _city = event.city;
    _date = event.date;
    await _fetch(emit);
  }

  Future<void> _onDateChanged(
    TheatreDateChangedEvent event,
    Emitter<TheatreState> emit,
  ) async {
    _date = event.date;
    await _fetch(emit);
  }

  Future<void> _onFilterChanged(
    TheatreFilterChangedEvent event,
    Emitter<TheatreState> emit,
  ) async {
    // Reset when both filters are null (Reset button in the filter sheet)
    if (event.language == null && event.format == null) {
      _language = null;
      _format = null;
    } else {
      _language = event.language ?? _language;
      _format = event.format ?? _format;
    }
    await _fetch(emit);
  }

  Future<void> _fetch(Emitter<TheatreState> emit) async {
    emit(TheatreLoading());

    final result = await _theatreRepository.getTheatresForMovie(
      movieId: _movieId,
      city: _city,
      date: _date,
      language: _language,
      format: _format,
    );

    result.fold(
      (failure) => emit(TheatreError(failure.message)),
      (theatres) => emit(TheatreLoaded(theatres)),
    );
  }
}
