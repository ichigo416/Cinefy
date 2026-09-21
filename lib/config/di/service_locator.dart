import '../../config/env/app_config.dart';
import '../../data/datasources/local/watchlist_local_datasource.dart';
import '../../data/datasources/remote/auth_remote_datasource.dart';
import '../../data/datasources/remote/booking_remote_datasource.dart';
import '../../data/datasources/remote/movie_remote_datasource.dart';
import '../../data/datasources/remote/seat_remote_datasource.dart';
import '../../data/datasources/remote/theatre_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/booking_repository_impl.dart';
import '../../data/repositories/movie_repository_impl.dart';
import '../../data/repositories/seat_repository_impl.dart';
import '../../data/repositories/theatre_repository_impl.dart';
import '../../data/repositories/watchlist_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/booking_repository.dart';
import '../../domain/repositories/movie_repository.dart';
import '../../domain/repositories/seat_repository.dart';
import '../../domain/repositories/theatre_repository.dart';
import '../../domain/repositories/watchlist_repository.dart';
import '../../presentation/bloc/home/home_bloc.dart';
import '../../presentation/bloc/booking/booking_bloc.dart';
import '../../presentation/bloc/auth/auth_bloc.dart';
import '../../presentation/bloc/movies/movie_details_bloc.dart';
import '../../presentation/bloc/search/search_bloc.dart';
import '../../presentation/bloc/seat/seat_cubit.dart';
import '../../presentation/bloc/theatre/theatre_bloc.dart';
import '../../presentation/cubits/watchlist/watchlist_cubit.dart';
import '../../services/api_service.dart';

class _ServiceLocator {
  final Map<Type, Object> _instances = {};

  T call<T extends Object>() {
    final instance = _instances[T];
    if (instance == null) {
      throw StateError('No service registered for $T');
    }
    return instance as T;
  }

  void registerSingleton<T extends Object>(T instance) {
    _instances[T] = instance;
  }
}

final sl = _ServiceLocator();

void setupServiceLocator() {
  if (!AppConfig.enableMockData && AppConfig.apiBaseUrl.isEmpty) {
    throw StateError(
      'CINEFY_API_BASE_URL must be set when CINEFY_MOCK_DATA is false',
    );
  }
  if (AppConfig.environment == 'production' &&
      !AppConfig.apiBaseUrl.startsWith('https://')) {
    throw StateError('Production API URL must use HTTPS');
  }

  sl.registerSingleton<ApiService>(
    ApiService(
      baseUrl: AppConfig.apiBaseUrl,
      enableLogging: AppConfig.enableLogging,
    ),
  );

  // ─── Datasources ───────────────────────────────────────────────────────────
  sl.registerSingleton<AuthRemoteDatasource>(
    AuthRemoteDatasource(sl<ApiService>(), AppConfig.enableMockData),
  );
  sl.registerSingleton<MovieRemoteDatasource>(
    MovieRemoteDatasource(sl<ApiService>(), AppConfig.enableMockData),
  );
  sl.registerSingleton<TheatreRemoteDatasource>(
    TheatreRemoteDatasource(sl<ApiService>(), AppConfig.enableMockData),
  );
  sl.registerSingleton<SeatRemoteDatasource>(
    SeatRemoteDatasource(sl<ApiService>(), AppConfig.enableMockData),
  );
  sl.registerSingleton<BookingRemoteDatasource>(
    BookingRemoteDatasource(sl<ApiService>(), AppConfig.enableMockData),
  );
  sl.registerSingleton<WatchlistLocalDatasource>(WatchlistLocalDatasource());

  // ─── Repositories ──────────────────────────────────────────────────────────
  sl.registerSingleton<AuthRepository>(
    AuthRepositoryImpl(sl<AuthRemoteDatasource>()),
  );
  sl.registerSingleton<MovieRepository>(
    MovieRepositoryImpl(sl<MovieRemoteDatasource>()),
  );
  sl.registerSingleton<TheatreRepository>(
    TheatreRepositoryImpl(sl<TheatreRemoteDatasource>()),
  );
  sl.registerSingleton<SeatRepository>(
    SeatRepositoryImpl(sl<SeatRemoteDatasource>()),
  );
  sl.registerSingleton<BookingRepository>(
    BookingRepositoryImpl(sl<BookingRemoteDatasource>()),
  );
  sl.registerSingleton<WatchlistRepository>(
    WatchlistRepositoryImpl(sl<WatchlistLocalDatasource>()),
  );

  // ─── Blocs / Cubits ────────────────────────────────────────────────────────
  sl.registerSingleton<AuthBloc>(AuthBloc(sl<AuthRepository>()));
  sl.registerSingleton<HomeBloc>(HomeBloc(sl<MovieRepository>()));
  sl.registerSingleton<SearchBloc>(SearchBloc(sl<MovieRepository>()));
  sl.registerSingleton<MovieDetailsBloc>(
    MovieDetailsBloc(sl<MovieRepository>()),
  );
  sl.registerSingleton<TheatreBloc>(TheatreBloc(sl<TheatreRepository>()));
  sl.registerSingleton<SeatCubit>(SeatCubit(sl<SeatRepository>()));
  sl.registerSingleton<BookingBloc>(BookingBloc(sl<BookingRepository>()));
  sl.registerSingleton<WatchlistCubit>(
    WatchlistCubit(sl<WatchlistRepository>()),
  );
}
