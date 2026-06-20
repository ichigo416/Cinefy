import '../../domain/entities/movie.dart';
import '../models/movie_model.dart';

// This datasource returns hardcoded mock data so the UI works
// without a backend. Swap fetchNowShowing/fetchComingSoon with
// real API calls when your backend is ready.

class MovieRemoteDatasource {
  Future<List<MovieModel>> fetchNowShowing({String? city}) async {
    // Simulate network latency
    await Future.delayed(const Duration(milliseconds: 800));
    return _nowShowingMovies;
  }

  Future<List<MovieModel>> fetchComingSoon({String? city}) async {
    await Future.delayed(const Duration(milliseconds: 600));
    return _comingSoonMovies;
  }

  Future<MovieModel> fetchMovieDetails(String movieId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final movie = [..._nowShowingMovies, ..._comingSoonMovies]
        .firstWhere((m) => m.id == movieId);
    return movie;
  }

  Future<List<MovieModel>> searchMovies(String query) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final q = query.toLowerCase();
    return [..._nowShowingMovies, ..._comingSoonMovies]
        .where((m) => m.title.toLowerCase().contains(q) ||
            m.genres.any((g) => g.toLowerCase().contains(q)))
        .toList();
  }
}

// ---------------------------------------------------------------------------
// Mock data
// ---------------------------------------------------------------------------

final List<MovieModel> _nowShowingMovies = [
  MovieModel(
    id: 'm1',
    title: 'Kalki 2898 AD',
    posterUrl:
        'https://upload.wikimedia.org/wikipedia/en/4/4b/Kalki_2898_AD_poster.jpg',
    bannerUrl:
        'https://upload.wikimedia.org/wikipedia/en/4/4b/Kalki_2898_AD_poster.jpg',
    rating: 8.3,
    votesCount: 142300,
    genres: ['Action', 'Sci-Fi', 'Mythology'],
    languages: ['Telugu', 'Hindi', 'Tamil', 'Kannada', 'Malayalam'],
    formats: ['2D', '3D', 'IMAX 3D', '4DX'],
    synopsis:
        'Set in the distant future, this epic sci-fi spectacle blends Hindu mythology with futuristic world-building. When ancient prophecies collide with a dystopian civilization, a reluctant hero must rise to fulfill his destiny as the final avatar.',
    durationMinutes: 181,
    certification: 'UA',
    releaseDate: DateTime(2024, 6, 27),
    isNowShowing: true,
    cast: [
      const CastMember(id: 'c1', name: 'Prabhas', role: 'Actor', character: 'Kalki'),
      const CastMember(id: 'c2', name: 'Deepika Padukone', role: 'Actress', character: 'Sumathi'),
      const CastMember(id: 'c3', name: 'Amitabh Bachchan', role: 'Actor', character: 'Ashwatthama'),
      const CastMember(id: 'c4', name: 'Nag Ashwin', role: 'Director'),
    ],
  ),
  MovieModel(
    id: 'm2',
    title: 'Stree 2',
    posterUrl:
        'https://upload.wikimedia.org/wikipedia/en/4/4e/Stree_2_film_poster.jpg',
    bannerUrl:
        'https://upload.wikimedia.org/wikipedia/en/4/4e/Stree_2_film_poster.jpg',
    rating: 8.7,
    votesCount: 215000,
    genres: ['Horror Comedy', 'Thriller'],
    languages: ['Hindi'],
    formats: ['2D'],
    synopsis:
        'Chanderi is back with a new supernatural terror. Stree returns, but this time with an army, and the men of the town must once again unite to protect their beloved village — and their dignity.',
    durationMinutes: 138,
    certification: 'UA',
    releaseDate: DateTime(2024, 8, 15),
    isNowShowing: true,
    cast: [
      const CastMember(id: 'c5', name: 'Rajkummar Rao', role: 'Actor', character: 'Vicky'),
      const CastMember(id: 'c6', name: 'Shraddha Kapoor', role: 'Actress', character: 'Stree'),
      const CastMember(id: 'c7', name: 'Amar Kaushik', role: 'Director'),
    ],
  ),
  MovieModel(
    id: 'm3',
    title: 'Pushpa 2: The Rule',
    posterUrl:
        'https://upload.wikimedia.org/wikipedia/en/4/42/Pushpa_2_The_Rule.jpg',
    bannerUrl:
        'https://upload.wikimedia.org/wikipedia/en/4/42/Pushpa_2_The_Rule.jpg',
    rating: 8.1,
    votesCount: 189000,
    genres: ['Action', 'Drama', 'Crime'],
    languages: ['Telugu', 'Hindi', 'Tamil'],
    formats: ['2D', '3D'],
    synopsis:
        'Pushpa Raj has expanded his red sandalwood empire. Now facing a brutal new adversary and the wrath of the very system he once bent, Pushpa must rule or be ruled.',
    durationMinutes: 190,
    certification: 'UA',
    releaseDate: DateTime(2024, 12, 5),
    isNowShowing: true,
    cast: [
      const CastMember(id: 'c8', name: 'Allu Arjun', role: 'Actor', character: 'Pushpa Raj'),
      const CastMember(id: 'c9', name: 'Rashmika Mandanna', role: 'Actress', character: 'Srivalli'),
      const CastMember(id: 'c10', name: 'Sukumar', role: 'Director'),
    ],
  ),
  MovieModel(
    id: 'm4',
    title: 'Bhool Bhulaiyaa 3',
    posterUrl:
        'https://upload.wikimedia.org/wikipedia/en/8/88/Bhool_Bhulaiyaa_3_poster.jpg',
    rating: 7.2,
    votesCount: 98000,
    genres: ['Horror', 'Comedy', 'Mystery'],
    languages: ['Hindi'],
    formats: ['2D'],
    synopsis:
        'Rooh Baba is back and so is Manjulika. Two forces of mischief collide in a haunted haveli, and only the most unexpected hero can save everyone — if they can figure out who the real ghost is.',
    durationMinutes: 159,
    certification: 'UA',
    releaseDate: DateTime(2024, 11, 1),
    isNowShowing: true,
    cast: [
      const CastMember(id: 'c11', name: 'Kartik Aaryan', role: 'Actor', character: 'Rooh Baba'),
      const CastMember(id: 'c12', name: 'Vidya Balan', role: 'Actress', character: 'Manjulika'),
      const CastMember(id: 'c13', name: 'Anees Bazmee', role: 'Director'),
    ],
  ),
  MovieModel(
    id: 'm5',
    title: 'Fighter',
    posterUrl:
        'https://upload.wikimedia.org/wikipedia/en/0/08/Fighter_2024_film_poster.jpg',
    rating: 7.5,
    votesCount: 77000,
    genres: ['Action', 'Drama'],
    languages: ['Hindi'],
    formats: ['2D', 'IMAX'],
    synopsis:
        'India\'s first aerial action franchise. A group of fearless Air Force officers must put everything on the line to protect the nation from its most dangerous threat yet.',
    durationMinutes: 167,
    certification: 'UA',
    releaseDate: DateTime(2024, 1, 25),
    isNowShowing: true,
    cast: [
      const CastMember(id: 'c14', name: 'Hrithik Roshan', role: 'Actor', character: 'Patty'),
      const CastMember(id: 'c15', name: 'Deepika Padukone', role: 'Actress', character: 'Minal'),
      const CastMember(id: 'c16', name: 'Siddharth Anand', role: 'Director'),
    ],
  ),
];

final List<MovieModel> _comingSoonMovies = [
  MovieModel(
    id: 'm6',
    title: 'Singham Again',
    posterUrl:
        'https://upload.wikimedia.org/wikipedia/en/e/e3/Singham_Again_poster.jpg',
    rating: 0,
    votesCount: 0,
    genres: ['Action', 'Drama'],
    languages: ['Hindi'],
    formats: ['2D', 'IMAX'],
    synopsis:
        'The universe expands. Multiple cops from the Rohit Shetty cinematic universe unite against a common enemy for the most explosive police action spectacle yet.',
    durationMinutes: 150,
    certification: 'UA',
    releaseDate: DateTime(2025, 4, 10),
    isNowShowing: false,
    cast: [
      const CastMember(id: 'c17', name: 'Ajay Devgn', role: 'Actor', character: 'Singham'),
      const CastMember(id: 'c18', name: 'Rohit Shetty', role: 'Director'),
    ],
  ),
  MovieModel(
    id: 'm7',
    title: 'Sky Force',
    posterUrl:
        'https://upload.wikimedia.org/wikipedia/en/b/b6/Sky_Force_film_poster.jpg',
    rating: 0,
    votesCount: 0,
    genres: ['Action', 'War', 'Drama'],
    languages: ['Hindi'],
    formats: ['2D', 'IMAX'],
    synopsis:
        'Based on India\'s deadliest airstrike, this film chronicles one of the most courageous missions in Indian Air Force history — a story of sacrifice, valour, and brotherhood.',
    durationMinutes: 145,
    certification: 'UA',
    releaseDate: DateTime(2025, 1, 24),
    isNowShowing: false,
    cast: [
      const CastMember(id: 'c19', name: 'Akshay Kumar', role: 'Actor'),
      const CastMember(id: 'c20', name: 'Abhishek Anil Kapur', role: 'Director'),
    ],
  ),
];