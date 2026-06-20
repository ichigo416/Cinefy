import '../../models/theatre_model.dart';
import '../../models/show_model.dart';
import '../../../domain/entities/theatre.dart';

class TheatreRemoteDatasource {
  Future<List<TheatreModel>> fetchTheatresForMovie({
    required String movieId,
    required String city,
    required DateTime date,
    String? language,
    String? format,
  }) async {
    await Future.delayed(const Duration(milliseconds: 700));

    var theatres = _mockTheatres(movieId, date);

    if (language != null) {
      theatres = theatres
          .map((t) => TheatreModel(
                id: t.id,
                name: t.name,
                address: t.address,
                city: t.city,
                distanceKm: t.distanceKm,
                rating: t.rating,
                amenities: t.amenities,
                shows: t.shows.where((s) => s.language == language).toList(),
              ))
          .where((t) => t.shows.isNotEmpty)
          .toList();
    }

    if (format != null) {
      theatres = theatres
          .map((t) => TheatreModel(
                id: t.id,
                name: t.name,
                address: t.address,
                city: t.city,
                distanceKm: t.distanceKm,
                rating: t.rating,
                amenities: t.amenities,
                shows: t.shows.where((s) => s.format == format).toList(),
              ))
          .where((t) => t.shows.isNotEmpty)
          .toList();
    }

    return theatres;
  }

  List<TheatreModel> _mockTheatres(String movieId, DateTime date) {
    final baseTimes = [
      DateTime(date.year, date.month, date.day, 10, 30),
      DateTime(date.year, date.month, date.day, 13, 45),
      DateTime(date.year, date.month, date.day, 17, 0),
      DateTime(date.year, date.month, date.day, 20, 15),
      DateTime(date.year, date.month, date.day, 23, 0),
    ];

    return [
      TheatreModel(
        id: 't1',
        name: 'PVR: Forum Mall, Koramangala',
        address: 'Hosur Road, Koramangala, Bengaluru',
        city: 'Bengaluru',
        distanceKm: 2.4,
        rating: 4.3,
        amenities: const ['M-Ticket', 'Food & Beverage', 'Parking', 'Wheelchair Access'],
        shows: List.generate(baseTimes.length, (i) {
          final availability = [120, 40, 8, 0, 95][i % 5];
          return ShowModel(
            id: 't1_show_$i',
            theatreId: 't1',
            movieId: movieId,
            startTime: baseTimes[i],
            language: i.isEven ? 'Hindi' : 'English',
            format: i == 2 ? 'IMAX 3D' : '2D',
            status: availability == 0
                ? ShowStatus.soldOut
                : (availability < 20 ? ShowStatus.almostFull : ShowStatus.available),
            totalSeats: 150,
            availableSeats: availability,
            basePrice: i == 2 ? 380 : 220,
          );
        }),
      ),
      TheatreModel(
        id: 't2',
        name: 'INOX: Garuda Mall, Magrath Road',
        address: 'Magrath Road, Ashok Nagar, Bengaluru',
        city: 'Bengaluru',
        distanceKm: 4.1,
        rating: 4.1,
        amenities: const ['M-Ticket', 'Food & Beverage', 'Parking'],
        shows: List.generate(baseTimes.length, (i) {
          final availability = [80, 60, 30, 12, 0][i % 5];
          return ShowModel(
            id: 't2_show_$i',
            theatreId: 't2',
            movieId: movieId,
            startTime: baseTimes[i],
            language: 'Hindi',
            format: '2D',
            status: availability == 0
                ? ShowStatus.soldOut
                : (availability < 20 ? ShowStatus.almostFull : ShowStatus.available),
            totalSeats: 130,
            availableSeats: availability,
            basePrice: 200,
          );
        }),
      ),
      TheatreModel(
        id: 't3',
        name: 'Cinepolis: Royal Meenakshi Mall',
        address: 'Bannerghatta Road, Bengaluru',
        city: 'Bengaluru',
        distanceKm: 7.8,
        rating: 4.5,
        amenities: const ['M-Ticket', 'Food & Beverage', 'Parking', 'Recliner Seats'],
        shows: List.generate(baseTimes.length, (i) {
          final availability = [200, 150, 60, 25, 5][i % 5];
          return ShowModel(
            id: 't3_show_$i',
            theatreId: 't3',
            movieId: movieId,
            startTime: baseTimes[i],
            language: i.isOdd ? 'Hindi' : 'Kannada',
            format: i == 4 ? '4DX' : '2D',
            status: availability == 0
                ? ShowStatus.soldOut
                : (availability < 20 ? ShowStatus.almostFull : ShowStatus.available),
            totalSeats: 220,
            availableSeats: availability,
            basePrice: i == 4 ? 450 : 240,
          );
        }),
      ),
    ];
  }
}