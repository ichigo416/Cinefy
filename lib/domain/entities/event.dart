import 'package:equatable/equatable.dart';

class Event extends Equatable {
  final String id;
  final String title;
  final String posterUrl;
  final String? bannerUrl;
  final String category;       // Music, Comedy, Workshop, Theatre, etc.
  final String description;
  final String venueName;
  final String venueAddress;
  final String city;
  final DateTime startTime;
  final DateTime? endTime;
  final List<TicketTier> ticketTiers;
  final double rating;
  final bool isFeatured;

  const Event({
    required this.id,
    required this.title,
    required this.posterUrl,
    this.bannerUrl,
    required this.category,
    required this.description,
    required this.venueName,
    required this.venueAddress,
    required this.city,
    required this.startTime,
    this.endTime,
    required this.ticketTiers,
    this.rating = 0,
    this.isFeatured = false,
  });

  double get startingPrice => ticketTiers.isEmpty
      ? 0
      : ticketTiers.map((t) => t.price).reduce((a, b) => a < b ? a : b);

  bool get isSoldOut => ticketTiers.every((t) => t.availableCount == 0);

  @override
  List<Object?> get props => [id];
}

class TicketTier extends Equatable {
  final String id;
  final String name; // e.g. "General", "VIP", "Standing"
  final double price;
  final int totalCount;
  final int availableCount;

  const TicketTier({
    required this.id,
    required this.name,
    required this.price,
    required this.totalCount,
    required this.availableCount,
  });

  bool get isSoldOut => availableCount == 0;

  @override
  List<Object?> get props => [id];
}