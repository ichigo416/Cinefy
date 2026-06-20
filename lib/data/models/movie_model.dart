import '../../domain/entities/movie.dart';

class MovieModel extends Movie {
  const MovieModel({
    required super.id,
    required super.title,
    required super.posterUrl,
    super.bannerUrl,
    super.trailerUrl,
    required super.rating,
    required super.votesCount,
    required super.genres,
    required super.languages,
    required super.formats,
    required super.synopsis,
    required super.durationMinutes,
    required super.certification,
    required super.releaseDate,
    required super.isNowShowing,
    super.cast,
  });

  factory MovieModel.fromJson(Map<String, dynamic> json) {
    return MovieModel(
      id: json['id'] as String,
      title: json['title'] as String,
      posterUrl: json['poster_url'] as String,
      bannerUrl: json['banner_url'] as String?,
      trailerUrl: json['trailer_url'] as String?,
      rating: (json['rating'] as num).toDouble(),
      votesCount: json['votes_count'] as int,
      genres: List<String>.from(json['genres'] as List),
      languages: List<String>.from(json['languages'] as List),
      formats: List<String>.from(json['formats'] as List),
      synopsis: json['synopsis'] as String,
      durationMinutes: json['duration_minutes'] as int,
      certification: json['certification'] as String,
      releaseDate: DateTime.parse(json['release_date'] as String),
      isNowShowing: json['is_now_showing'] as bool,
      cast: (json['cast'] as List? ?? [])
          .map((c) => CastMemberModel.fromJson(c as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'poster_url': posterUrl,
      'banner_url': bannerUrl,
      'trailer_url': trailerUrl,
      'rating': rating,
      'votes_count': votesCount,
      'genres': genres,
      'languages': languages,
      'formats': formats,
      'synopsis': synopsis,
      'duration_minutes': durationMinutes,
      'certification': certification,
      'release_date': releaseDate.toIso8601String(),
      'is_now_showing': isNowShowing,
    };
  }
}

class CastMemberModel extends CastMember {
  const CastMemberModel({
    required super.id,
    required super.name,
    required super.role,
    super.character,
    super.photoUrl,
  });

  factory CastMemberModel.fromJson(Map<String, dynamic> json) {
    return CastMemberModel(
      id: json['id'] as String,
      name: json['name'] as String,
      role: json['role'] as String,
      character: json['character'] as String?,
      photoUrl: json['photo_url'] as String?,
    );
  }
} 