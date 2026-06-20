import 'package:equatable/equatable.dart';

class SeatLayout extends Equatable {
  final String showId;
  final List<SeatRow> rows;
  final Map<SeatCategory, double> pricing;

  const SeatLayout({
    required this.showId,
    required this.rows,
    required this.pricing,
  });

  List<Seat> get allSeats => rows.expand((r) => r.seats).toList();
  int get totalSeats => allSeats.length;
  int get availableSeats =>
      allSeats.where((s) => s.status == SeatStatus.available).length;

  @override
  List<Object?> get props => [showId];
}

class SeatRow extends Equatable {
  final String rowLabel; // A, B, C...
  final List<Seat> seats;

  const SeatRow({required this.rowLabel, required this.seats});

  @override
  List<Object?> get props => [rowLabel];
}

class Seat extends Equatable {
  final String id;
  final String rowLabel;
  final int seatNumber;
  final SeatCategory category;
  final SeatStatus status;

  const Seat({
    required this.id,
    required this.rowLabel,
    required this.seatNumber,
    required this.category,
    required this.status,
  });

  String get label => '$rowLabel$seatNumber';

  bool get isSelectable => status == SeatStatus.available;

  Seat copyWith({SeatStatus? status}) {
    return Seat(
      id: id,
      rowLabel: rowLabel,
      seatNumber: seatNumber,
      category: category,
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props => [id, status];
}

enum SeatCategory { normal, premium, recliner }

enum SeatStatus { available, booked, selected, blocked } 