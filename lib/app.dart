import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'config/di/service_locator.dart';
import 'config/routes/app_router.dart';
import 'core/theme/app_theme.dart';
import 'presentation/bloc/booking/booking_bloc.dart';
import 'presentation/bloc/auth/auth_bloc.dart';
import 'presentation/bloc/home/home_bloc.dart';
import 'presentation/bloc/movies/movie_details_bloc.dart';
import 'presentation/bloc/search/search_bloc.dart';
import 'presentation/bloc/seat/seat_cubit.dart';
import 'presentation/bloc/theatre/theatre_bloc.dart';
import 'presentation/cubits/watchlist/watchlist_cubit.dart';

class CinefyApp extends StatelessWidget {
  const CinefyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<AuthBloc>()),
        BlocProvider(create: (_) => sl<HomeBloc>()),
        BlocProvider(create: (_) => sl<SearchBloc>()),
        BlocProvider(create: (_) => sl<BookingBloc>()),
        BlocProvider(create: (_) => sl<MovieDetailsBloc>()),
        BlocProvider(create: (_) => sl<TheatreBloc>()),
        BlocProvider(create: (_) => sl<SeatCubit>()),
        BlocProvider(create: (_) => sl<WatchlistCubit>()),
      ],
      child: MaterialApp.router(
        title: 'Cinefy',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        routerConfig: appRouter,
      ),
    );
  }
}
