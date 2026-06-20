import 'dart:math';
import '../../models/seat_model.dart';
import '../../../domain/entities/seat.dart';

class SeatRemoteDatasource {
  Future<SeatLayoutModel> fetchSeatLayout(String showId) async {
    await Future.delayed(const Duration(milliseconds: 600));
    return _generateLayout(showId);
  }

  // Generates a realistic layout: recliner row at back, premium in middle,
  // normal seats in front — with a few random seats pre-booked.
  SeatLayoutModel _generateLayout(String showId) {
    final random = Random(showId.hashCode); // deterministic per show
    final rowLabels = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H'];
    final seatsPerRow = 14;
    final rows = <SeatRow>[];

    for (var r = 0; r < rowLabels.length; r++) {
      final category = r < 3
          ? SeatCategory.normal
          : (r < 6 ? SeatCategory.premium : SeatCategory.recliner);

      final seats = List.generate(seatsPerRow, (i) {
        final seatNumber = i + 1;
        // Roughly 20% of seats are randomly pre-booked
        final isBooked = random.nextDouble() < 0.2;
        return SeatModel(
          id: '${showId}_${rowLabels[r]}$seatNumber',
          rowLabel: rowLabels[r],
          seatNumber: seatNumber,
          category: category,
          status: isBooked ? SeatStatus.booked : SeatStatus.available,
        );
      });

      rows.add(SeatRow(rowLabel: rowLabels[r], seats: seats));
    }

    return SeatLayoutModel(
      showId: showId,
      rows: rows,
      pricing: const {
        SeatCategory.normal: 180,
        SeatCategory.premium: 260,
        SeatCategory.recliner: 420,
      },
    );
  }
}