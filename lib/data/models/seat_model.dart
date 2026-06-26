import '../../domain/entities/seat.dart';

SeatCategory _seatCategoryFromString(String value) {
  switch (value) {
    case 'premium':
      return SeatCategory.premium;
    case 'recliner':
      return SeatCategory.recliner;
    default:
      return SeatCategory.normal;
  }
}

class SeatModel extends Seat {
  const SeatModel({
    required super.id,
    required super.rowLabel,
    required super.seatNumber,
    required super.category,
    required super.status,
  });

  factory SeatModel.fromJson(Map<String, dynamic> json) {
    return SeatModel(
      id: json['id'] as String,
      rowLabel: json['row_label'] as String,
      seatNumber: json['seat_number'] as int,
      category: _seatCategoryFromString(json['category'] as String),
      status: _statusFromString(json['status'] as String),
    );
  }

  static SeatStatus _statusFromString(String value) {
    switch (value) {
      case 'booked':
        return SeatStatus.booked;
      case 'selected':
        return SeatStatus.selected;
      case 'blocked':
        return SeatStatus.blocked;
      default:
        return SeatStatus.available;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'row_label': rowLabel,
      'seat_number': seatNumber,
      'category': category.name,
      'status': status.name,
    };
  }
}

class SeatLayoutModel extends SeatLayout {
  const SeatLayoutModel({
    required super.showId,
    required super.rows,
    required super.pricing,
  });

  factory SeatLayoutModel.fromJson(Map<String, dynamic> json) {
    final rowsJson = json['rows'] as List;
    final pricingJson = json['pricing'] as Map<String, dynamic>;

    return SeatLayoutModel(
      showId: json['show_id'] as String,
      rows: rowsJson.map((r) {
        final rowMap = r as Map<String, dynamic>;
        return SeatRow(
          rowLabel: rowMap['row_label'] as String,
          seats: (rowMap['seats'] as List)
              .map((s) => SeatModel.fromJson(s as Map<String, dynamic>))
              .toList(),
        );
      }).toList(),
      pricing: pricingJson.map(
        (key, value) => MapEntry(
          _seatCategoryFromString(key),
          (value as num).toDouble(),
        ),
      ),
    );
  }
}