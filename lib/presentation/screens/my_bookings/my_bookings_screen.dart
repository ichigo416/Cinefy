import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/utils/currency_utils.dart';
import '../../../core/utils/date_utils.dart';
import '../../../domain/entities/booking.dart';
import '../../bloc/booking/booking_bloc.dart';
import '../../widgets/error_widget.dart';
import '../../widgets/shimmer_loader.dart';

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> {
  bool _showUpcoming = true;

  @override
  void initState() {
    super.initState();
    // Fetch only when there is no loaded data yet — avoids re-querying
    // every time the tab is re-entered. A new booking dispatches a
    // BookingFetchEvent from the summary screen to invalidate stale data.
    if (context.read<BookingBloc>().state is! BookingsLoaded) {
      context.read<BookingBloc>().add(const BookingFetchEvent());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: Text(AppStrings.myBookings, style: AppTextStyles.h3),
      ),
      body: BlocBuilder<BookingBloc, BookingState>(
        builder: (context, state) {
          if (state is BookingLoading || state is BookingInitial) {
            return _buildLoading();
          }
          if (state is BookingsError) {
            return RefreshIndicator(
              onRefresh: () async =>
                  context.read<BookingBloc>().add(const BookingFetchEvent()),
              child: AppErrorWidget(
                message: state.message,
                onRetry: () =>
                    context.read<BookingBloc>().add(const BookingFetchEvent()),
              ),
            );
          }
          if (state is BookingsLoaded) {
            final upcoming =
                state.bookings.where((b) => b.isUpcoming).toList();
            final past =
                state.bookings.where((b) => !b.isUpcoming).toList();

            return RefreshIndicator(
              onRefresh: () async =>
                  context.read<BookingBloc>().add(const BookingFetchEvent()),
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                      child: _buildToggle(upcoming, past),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.all(16),
                    sliver:
                        _buildList(_showUpcoming ? upcoming : past),
                  ),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  // ─── Loading ───────────────────────────────────────────────────────────────

  Widget _buildLoading() {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: 3,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (_, _) => const ShimmerWidget(
        width: double.infinity,
        height: 130,
      ),
    );
  }

  // ─── Toggle ────────────────────────────────────────────────────────────────

  Widget _buildToggle(List<Booking> upcoming, List<Booking> past) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: _ToggleItem(
              label: '${AppStrings.upcoming} (${upcoming.length})',
              isSelected: _showUpcoming,
              onTap: () => setState(() => _showUpcoming = true),
            ),
          ),
          Expanded(
            child: _ToggleItem(
              label: '${AppStrings.past} (${past.length})',
              isSelected: !_showUpcoming,
              onTap: () => setState(() => _showUpcoming = false),
            ),
          ),
        ],
      ),
    );
  }

  // ─── List / Empty ──────────────────────────────────────────────────────────

  Widget _buildList(List<Booking> bookings) {
    if (bookings.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: _buildEmpty(),
      );
    }

    return SliverList.separated(
      itemCount: bookings.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (_, i) => _BookingCard(
        booking: bookings[i],
        onTap: () =>
            context.push('/tickets/${bookings[i].id}', extra: bookings[i]),
      ),
    );
  }

  Widget _buildEmpty() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.confirmation_number_outlined,
            color: AppColors.textHint, size: 52),
        const SizedBox(height: 12),
        Text(AppStrings.noBookingsYet, style: AppTextStyles.h3),
        const SizedBox(height: 4),
        Text('Book your first movie ticket now', style: AppTextStyles.bodySmall),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () => context.go('/home'),
          child: const Text('Browse Movies'),
        ),
      ],
    );
  }
}

// ─── Booking Card ────────────────────────────────────────────────────────────

class _BookingCard extends StatelessWidget {
  final Booking booking;
  final VoidCallback onTap;

  const _BookingCard({required this.booking, required this.onTap});

  Color get _statusColor {
    switch (booking.status) {
      case BookingStatus.confirmed:
        return AppColors.green;
      case BookingStatus.cancelled:
        return AppColors.primary;
      case BookingStatus.failed:
        return AppColors.orange;
      case BookingStatus.refunded:
        return AppColors.blue;
      default:
        return AppColors.textHint;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                imageUrl: booking.moviePosterUrl,
                width: 56,
                height: 80,
                fit: BoxFit.cover,
                placeholder: (_, _) =>
                    Container(color: AppColors.surfaceLight),
                errorWidget: (_, _, _) => Container(
                  width: 56,
                  height: 80,
                  color: AppColors.surfaceLight,
                  child: const Icon(Icons.movie_outlined,
                      color: AppColors.textHint, size: 22),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(child: _buildDetails()),
          ],
        ),
      ),
    );
  }

  Widget _buildDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                booking.movieTitle,
                style: AppTextStyles.h3,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: _statusColor,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          booking.theatreName,
          style: AppTextStyles.caption,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 8),
        _MetaRow(
          icon: Icons.calendar_today_rounded,
          text:
              '${AppDateUtils.formatShortDate(booking.showTime)} · ${AppDateUtils.formatTime(booking.showTime)}',
        ),
        const SizedBox(height: 4),
        _MetaRow(
          icon: Icons.event_seat_rounded,
          text: booking.seatLabels,
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                '#${booking.id}',
                style: AppTextStyles.labelSmall.copyWith(fontSize: 10),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              CurrencyUtils.format(booking.totalAmount),
              style: AppTextStyles.labelLarge.copyWith(
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _MetaRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _MetaRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.textHint, size: 12),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.labelSmall,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

// ─── Toggle Item ─────────────────────────────────────────────────────────────

class _ToggleItem extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ToggleItem({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            label,
            style: AppTextStyles.labelMedium.copyWith(
              color: isSelected ? Colors.white : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
