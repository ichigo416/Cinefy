import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../bloc/theatre/theatre_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../domain/entities/theatre.dart';
import '../../../services/booking_session_cache.dart';

class TheatreListScreen extends StatefulWidget {
  final String movieId;

  const TheatreListScreen({super.key, required this.movieId});

  @override
  State<TheatreListScreen> createState() => _TheatreListScreenState();
}

class _TheatreListScreenState extends State<TheatreListScreen> {
  late DateTime _selectedDate;
  final List<DateTime> _dateOptions = List.generate(
    7,
    (i) => DateTime.now().add(Duration(days: i)),
  );

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    context.read<TheatreBloc>().add(TheatreFetchEvent(
          movieId: widget.movieId,
          city: 'Bengaluru',
          date: _selectedDate,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: BlocBuilder<TheatreBloc, TheatreState>(
          builder: (_, state) {
            final movieTitle = BookingSessionCache.instance.movie?.title ?? 'Select Show';
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(movieTitle, style: AppTextStyles.h3),
                const Text('Bengaluru',
                    style: TextStyle(
                      color: AppColors.textHint,
                      fontSize: 12,
                      fontFamily: 'Gilroy',
                    )),
              ],
            );
          },
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list_rounded),
            onPressed: _showFilterSheet,
          ),
        ],
      ),
      body: Column(
        children: [
          _DateSelector(),
          const Divider(height: 1, color: AppColors.divider),
          Expanded(
            child: BlocBuilder<TheatreBloc, TheatreState>(
              builder: (context, state) {
                if (state is TheatreLoading) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  );
                }
                if (state is TheatreError) {
                  return _buildError(state.message);
                }
                if (state is TheatreLoaded) {
                  if (state.theatres.isEmpty) {
                    return _buildEmpty();
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: state.theatres.length,
                    separatorBuilder: (_, __) =>
                        const Divider(height: 1, color: AppColors.divider),
                    itemBuilder: (_, i) => _TheatreCard(
                      theatre: state.theatres[i],
                      onShowTapped: (show) => _onShowSelected(
                        state.theatres[i],
                        show,
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _DateSelector() {
    return SizedBox(
      height: 72,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        itemCount: _dateOptions.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final date = _dateOptions[i];
          final isSelected = _isSameDay(date, _selectedDate);
          final isToday = _isSameDay(date, DateTime.now());

          return GestureDetector(
            onTap: () {
              setState(() => _selectedDate = date);
              context
                  .read<TheatreBloc>()
                  .add(TheatreDateChangedEvent(date));
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 52,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.border,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    isToday ? 'Today' : _weekday(date),
                    style: TextStyle(
                      fontFamily: 'Gilroy',
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: isSelected
                          ? Colors.white70
                          : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${date.day}',
                    style: TextStyle(
                      fontFamily: 'Gilroy',
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    _month(date),
                    style: TextStyle(
                      fontFamily: 'Gilroy',
                      fontSize: 10,
                      color: isSelected ? Colors.white70 : AppColors.textHint,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildError(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline_rounded,
              color: AppColors.textHint, size: 48),
          const SizedBox(height: 12),
          Text(message, style: AppTextStyles.bodySmall),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.read<TheatreBloc>().add(TheatreFetchEvent(
                  movieId: widget.movieId,
                  city: 'Bengaluru',
                  date: _selectedDate,
                )),
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.movie_creation_outlined,
              color: AppColors.textHint, size: 52),
          const SizedBox(height: 12),
          Text('No shows available', style: AppTextStyles.h3),
          const SizedBox(height: 4),
          Text('Try a different date or city',
              style: AppTextStyles.bodySmall),
        ],
      ),
    );
  }

  void _onShowSelected(Theatre theatre, Show show) {
    // Populate session cache with full context
    final session = BookingSessionCache.instance;
    session.theatre = theatre;
    session.show = show;
    // movie is already set from the movie detail screen
    context.push('/booking/seats/${show.id}');
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const _FilterSheet(),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  String _weekday(DateTime d) =>
      ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][d.weekday - 1];

  String _month(DateTime d) => [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ][d.month - 1];
}

// ─── Theatre Card ────────────────────────────────────────────────────────────

class _TheatreCard extends StatelessWidget {
  final Theatre theatre;
  final void Function(Show) onShowTapped;

  const _TheatreCard({required this.theatre, required this.onShowTapped});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(theatre.name, style: AppTextStyles.h3),
                    const SizedBox(height: 2),
                    Text(
                      '${theatre.distanceKm.toStringAsFixed(1)} km  •  ${theatre.address}',
                      style: AppTextStyles.caption,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  const Icon(Icons.star_rounded,
                      color: AppColors.gold, size: 13),
                  const SizedBox(width: 2),
                  Text(
                    theatre.rating.toStringAsFixed(1),
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.gold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Amenities
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: theatre.amenities
                .map((a) => _AmenityChip(label: a))
                .toList(),
          ),
          const SizedBox(height: 12),
          // Showtimes
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: theatre.shows
                .map((show) => _ShowtimeChip(
                      show: show,
                      onTap: () => onShowTapped(show),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _AmenityChip extends StatelessWidget {
  final String label;
  const _AmenityChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(label,
          style: AppTextStyles.caption.copyWith(fontSize: 10)),
    );
  }
}

class _ShowtimeChip extends StatelessWidget {
  final Show show;
  final VoidCallback onTap;

  const _ShowtimeChip({required this.show, required this.onTap});

  Color get _borderColor {
    if (show.isSoldOut) return AppColors.border;
    if (show.isAlmostFull) return AppColors.orange;
    return AppColors.green;
  }

  Color get _textColor {
    if (show.isSoldOut) return AppColors.textHint;
    return AppColors.textPrimary;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: show.isSoldOut ? null : onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: _borderColor, width: 1.3),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              show.formattedTime,
              style: AppTextStyles.labelLarge.copyWith(color: _textColor),
            ),
            const SizedBox(height: 2),
            Text(
              '${show.language} · ${show.format}',
              style: AppTextStyles.caption.copyWith(fontSize: 10),
            ),
            if (show.isAlmostFull)
              Text('Filling fast',
                  style: AppTextStyles.caption.copyWith(
                      color: AppColors.orange, fontSize: 9)),
            if (show.isSoldOut)
              Text('Sold out',
                  style: AppTextStyles.caption
                      .copyWith(color: AppColors.textHint, fontSize: 9)),
          ],
        ),
      ),
    );
  }
}

// ─── Filter Bottom Sheet ──────────────────────────────────────────────────────

class _FilterSheet extends StatelessWidget {
  const _FilterSheet();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Filters', style: AppTextStyles.h2),
              TextButton(
                onPressed: () {
                  context.read<TheatreBloc>().add(
                        const TheatreFilterChangedEvent(),
                      );
                  Navigator.pop(context);
                },
                child: const Text('Reset'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text('Language', style: AppTextStyles.labelMedium),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: ['Hindi', 'English', 'Telugu', 'Tamil', 'Kannada']
                .map((lang) => ChoiceChip(
                      label: Text(lang),
                      selected: false,
                      onSelected: (_) {
                        context.read<TheatreBloc>().add(
                              TheatreFilterChangedEvent(language: lang),
                            );
                        Navigator.pop(context);
                      },
                    ))
                .toList(),
          ),
          const SizedBox(height: 16),
          Text('Format', style: AppTextStyles.labelMedium),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: ['2D', '3D', 'IMAX 3D', '4DX']
                .map((fmt) => ChoiceChip(
                      label: Text(fmt),
                      selected: false,
                      onSelected: (_) {
                        context.read<TheatreBloc>().add(
                              TheatreFilterChangedEvent(format: fmt),
                            );
                        Navigator.pop(context);
                      },
                    ))
                .toList(),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}