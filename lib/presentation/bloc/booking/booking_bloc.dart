import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/booking.dart';
import '../../../domain/repositories/booking_repository.dart';

abstract class BookingEvent extends Equatable {
  const BookingEvent();

  @override
  List<Object?> get props => [];
}

class BookingFetchEvent extends BookingEvent {
  const BookingFetchEvent();
}

abstract class BookingState extends Equatable {
  const BookingState();

  @override
  List<Object?> get props => [];
}

class BookingInitial extends BookingState {}

class BookingLoading extends BookingState {}

class BookingsLoaded extends BookingState {
  final List<Booking> bookings;

  const BookingsLoaded(this.bookings);

  @override
  List<Object?> get props => [bookings];
}

class BookingsError extends BookingState {
  final String message;

  const BookingsError(this.message);

  @override
  List<Object?> get props => [message];
}

/// State holder for the My Bookings list.
/// Fetches through the existing BookingRepository -> mock datasource chain.
class BookingBloc extends Bloc<BookingEvent, BookingState> {
  final BookingRepository _bookingRepository;

  BookingBloc(this._bookingRepository) : super(BookingInitial()) {
    on<BookingFetchEvent>(_onFetch);
  }

  Future<void> _onFetch(
    BookingFetchEvent event,
    Emitter<BookingState> emit,
  ) async {
    emit(BookingLoading());

    final result = await _bookingRepository.getMyBookings();

    result.fold(
      (failure) => emit(BookingsError(failure.message)),
      (bookings) => emit(BookingsLoaded(bookings)),
    );
  }
}
