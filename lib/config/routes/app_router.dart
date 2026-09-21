import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../config/env/app_config.dart';
import '../../presentation/bloc/auth/auth_bloc.dart';
import '../../presentation/screens/splash/splash_screen.dart';
import '../../presentation/screens/auth/login_screen.dart';
import '../../presentation/screens/home/home_screen.dart';
import '../../presentation/screens/movies/movie_detail_screen.dart';
import '../../presentation/screens/search/search_screen.dart';
import '../../presentation/screens/profile/profile_screen.dart';
import '../../presentation/screens/profile/watchlist_screen.dart';
import '../../presentation/screens/events/events_list_screen.dart';
import '../../presentation/screens/events/event_detail_screen.dart';
import '../../presentation/screens/explore/explore_screen.dart';
import '../../presentation/screens/booking/theatre_list_screen.dart';
import '../../presentation/screens/booking/seat_selection_screen.dart';
import '../../presentation/screens/booking/booking_summary_screen.dart';
import '../../presentation/screens/booking/booking_confirmation_screen.dart';
import '../../presentation/screens/my_bookings/my_bookings_screen.dart';
import '../../presentation/screens/my_bookings/ticket_detail_screen.dart';
import '../../presentation/widgets/bottom_nav_bar.dart';
import '../../domain/entities/booking.dart';
import '../../domain/entities/event.dart';
import '../../domain/entities/movie.dart';

/// Original protected location requested while signed out — used to return
/// the user there after a successful login.
String? _pendingProtectedLocation;

String? takePendingProtectedLocation() {
  final location = _pendingProtectedLocation;
  _pendingProtectedLocation = null;
  return location;
}

bool _isProtectedRoute(String location) =>
    location == '/my-bookings' ||
    location == '/profile' ||
    location == '/watchlist' ||
    location.startsWith('/tickets/');

final GoRouter appRouter = GoRouter(
  initialLocation: '/splash',
  debugLogDiagnostics: !AppConfig.isRelease,
  redirect: (context, state) {
    final authenticated = context.read<AuthBloc>().state is AuthAuthenticated;
    final location = state.matchedLocation;

    // Signed-in users have no use for the login page.
    if (authenticated && location == '/login') return '/home';

    // User-specific screens require a session: capture where they were
    // heading and send them to login. Everything else (home, search, movie
    // browsing, the booking flow) remains guest-accessible.
    if (!authenticated && _isProtectedRoute(location)) {
      _pendingProtectedLocation = location;
      return '/login';
    }

    return null;
  },
  routes: [
    GoRoute(path: '/splash', builder: (_, _) => const SplashScreen()),
    GoRoute(path: '/login', builder: (_, _) => const LoginScreen()),

    // Shell route for bottom nav
    ShellRoute(
      builder: (context, state, child) {
        final location = state.uri.path;
        final index = _navIndex(location);
        return MainScaffold(currentIndex: index, child: child);
      },
      routes: [
        GoRoute(path: '/home', builder: (_, _) => const HomeScreen()),
        GoRoute(path: '/events', builder: (_, _) => const EventsListScreen()),
        GoRoute(path: '/explore', builder: (_, _) => const ExploreScreen()),
        GoRoute(
          path: '/my-bookings',
          builder: (_, _) => const MyBookingsScreen(),
        ),
        GoRoute(path: '/profile', builder: (_, _) => const ProfileScreen()),
      ],
    ),

    // Event detail (outside the shell to keep the bottom nav hidden)
    GoRoute(
      path: '/events/:id',
      builder: (context, state) {
        final event = state.extra as Event?;
        final eventId = state.pathParameters['id']!;
        return EventDetailScreen(eventId: eventId, event: event);
      },
    ),

    // Search (outside the shell — focused, full-screen experience)
    GoRoute(path: '/search', builder: (_, _) => const SearchScreen()),

    // Movie detail (outside shell so no bottom nav)
    GoRoute(
      path: '/movie/:id',
      builder: (context, state) {
        final movie = state.extra as Movie?;
        final movieId = state.pathParameters['id']!;
        return MovieDetailScreen(movieId: movieId, movie: movie);
      },
    ),

    // Booking flow
    GoRoute(
      path: '/booking/theatres/:movieId',
      builder: (context, state) {
        final movieId = state.pathParameters['movieId']!;
        return TheatreListScreen(movieId: movieId);
      },
    ),
    GoRoute(
      path: '/booking/seats/:showId',
      builder: (context, state) {
        final showId = state.pathParameters['showId']!;
        return SeatSelectionScreen(showId: showId);
      },
    ),
    GoRoute(
      path: '/booking/summary',
      builder: (context, state) {
        return const BookingSummaryScreen();
      },
    ),
    GoRoute(
      path: '/booking/confirmed/:bookingId',
      builder: (context, state) {
        final bookingId = state.pathParameters['bookingId']!;
        return BookingConfirmationScreen(bookingId: bookingId);
      },
    ),

    // Ticket details (persisted booking, deep-linkable)
    GoRoute(
      path: '/tickets/:bookingId',
      builder: (context, state) {
        final bookingId = state.pathParameters['bookingId']!;
        final booking = state.extra as Booking?;
        return TicketDetailScreen(bookingId: bookingId, booking: booking);
      },
    ),

    // Watchlist (authenticated, accessible from Profile)
    GoRoute(path: '/watchlist', builder: (_, _) => const WatchlistScreen()),
  ],

  errorBuilder: (context, state) =>
      Scaffold(body: Center(child: Text('Page not found: ${state.uri.path}'))),
);

int _navIndex(String location) {
  if (location.startsWith('/home')) return 0;
  if (location.startsWith('/events')) return 1;
  if (location.startsWith('/explore')) return 2;
  if (location.startsWith('/my-bookings')) return 3;
  if (location.startsWith('/profile')) return 4;
  return 0;
}
