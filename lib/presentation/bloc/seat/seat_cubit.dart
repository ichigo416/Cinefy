import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/seat.dart';
import '../../../domain/repositories/seat_repository.dart';
import '../../../services/booking_session_cache.dart';

abstract class SeatState extends Equatable {
  const SeatState();

  @override
  List<Object?> get props => [];
}

class SeatInitial extends SeatState {}

class SeatLoading extends SeatState {}

class SeatLoaded extends SeatState {
  final SeatLayout layout;
  final List<Seat> selectedSeats;
  final String? error;

  const SeatLoaded({
    required this.layout,
    required this.selectedSeats,
    this.error,
  });

  double get totalPrice {
    final prices = layout.pricing;
    return selectedSeats.fold<double>(
      0,
      (sum, seat) => sum + (prices[seat.category] ?? 0),
    );
  }

  @override
  List<Object?> get props => [layout, selectedSeats, error];
}

class SeatError extends SeatState {
  final String message;

  const SeatError(this.message);

  @override
  List<Object?> get props => [message];
}

class SeatCubit extends Cubit<SeatState> {
  final SeatRepository _seatRepository;

  SeatCubit(this._seatRepository) : super(SeatInitial());

  /// Loads the real seat layout for the given show from the (mock) backend
  /// and stores it in the booking session so pricing survives the flow.
  Future<void> loadLayout(String showId) async {
    emit(SeatLoading());

    final result = await _seatRepository.getSeatLayout(showId);

    result.fold(
      (failure) => emit(SeatError(failure.message)),
      (layout) {
        BookingSessionCache.instance.seatLayout = layout;
        emit(SeatLoaded(layout: layout, selectedSeats: const []));
      },
    );
  }

  void toggleSeat(Seat seat) {
    final current = state;
    if (current is! SeatLoaded) return;

    final selected = List<Seat>.from(current.selectedSeats);
    final index = selected.indexWhere((s) => s.id == seat.id);

    if (index >= 0) {
      selected.removeAt(index);
    } else if (seat.status == SeatStatus.available) {
      if (selected.length >= 6) {
        emit(
          SeatLoaded(
            layout: current.layout,
            selectedSeats: selected,
            error: 'You can select up to 6 seats.',
          ),
        );
        return;
      }
      selected.add(seat.copyWith(status: SeatStatus.selected));
    }

    emit(
      SeatLoaded(
        layout: current.layout,
        selectedSeats: selected,
      ),
    );
  }
}
