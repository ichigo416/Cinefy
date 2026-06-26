import '../../domain/entities/event.dart';

class EventModel extends Event {
  const EventModel({
    required super.id,
    required super.title,
    required super.posterUrl,
    super.bannerUrl,
    required super.category,
    required super.description,
    required super.venueName,
    required super.venueAddress,
    required super.city,
    required super.startTime,
    super.endTime,
    required super.ticketTiers,
    super.rating,
    super.isFeatured,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['id'] as String,
      title: json['title'] as String,
      posterUrl: json['poster_url'] as String,
      bannerUrl: json['banner_url'] as String?,
      category: json['category'] as String,
      description: json['description'] as String,
      venueName: json['venue_name'] as String,
      venueAddress: json['venue_address'] as String,
      city: json['city'] as String,
      startTime: DateTime.parse(json['start_time'] as String),
      endTime: json['end_time'] != null
          ? DateTime.parse(json['end_time'] as String)
          : null,
      ticketTiers: (json['ticket_tiers'] as List)
          .map((t) => TicketTierModel.fromJson(t as Map<String, dynamic>))
          .toList(),
      rating: (json['rating'] as num? ?? 0).toDouble(),
      isFeatured: json['is_featured'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'poster_url': posterUrl,
      'banner_url': bannerUrl,
      'category': category,
      'description': description,
      'venue_name': venueName,
      'venue_address': venueAddress,
      'city': city,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime?.toIso8601String(),
      'rating': rating,
      'is_featured': isFeatured,
    };
  }
}

class TicketTierModel extends TicketTier {
  const TicketTierModel({
    required super.id,
    required super.name,
    required super.price,
    required super.totalCount,
    required super.availableCount,
  });

  factory TicketTierModel.fromJson(Map<String, dynamic> json) {
    return TicketTierModel(
      id: json['id'] as String,
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      totalCount: json['total_count'] as int,
      availableCount: json['available_count'] as int,
    );
  }
}