import 'package:equatable/equatable.dart';

class Movie extends Equatable {
  final String id;
  final String title;
  final String posterUrl;
  final String? bannerUrl;
  final String? trailerUrl;
  final double rating;         // 0–10
  final int votesCount;
  final List<String> genres;
  final List<String> languages;
  final List<String> formats;  // 2D, 3D, IMAX, 4DX
  final String synopsis;
  final int durationMinutes;
  final String certification;  // U, UA, A
  final DateTime releaseDate;
  final bool isNowShowing;
  final List<CastMember> cast;

  const Movie({
    required this.id,
    required this.title,
    required this.posterUrl,
    this.bannerUrl,
    this.trailerUrl,
    required this.rating,
    required this.votesCount,
    required this.genres,
    required this.languages,
    required this.formats,
    required this.synopsis,
    required this.durationMinutes,
    required this.certification,
    required this.releaseDate,
    required this.isNowShowing,
    this.cast = const [],
  });

  String get duration {
    final h = durationMinutes ~/ 60;
    final m = durationMinutes % 60;
    return h > 0 ? '${h}h ${m}m' : '${m}m';
  }

  String get formattedVotes {
    if (votesCount >= 1000) {
      return '${(votesCount / 1000).toStringAsFixed(1)}K Votes';
    }
    return '$votesCount Votes';
  }

  @override
  List<Object?> get props => [id, title, rating, isNowShowing];
}

class CastMember extends Equatable {
  final String id;
  final String name;
  final String role;       // Actor / Director / etc.
  final String? character; // Character name for actors
  final String? photoUrl;

  const CastMember({
    required this.id,
    required this.name,
    required this.role,
    this.character,
    this.photoUrl,
  });

  @override
  List<Object?> get props => [id];
} 