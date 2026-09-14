import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../config/di/service_locator.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/utils/currency_utils.dart';
import '../../../core/utils/date_utils.dart';
import '../../../domain/entities/booking.dart';
import '../../../domain/repositories/booking_repository.dart';
import '../../widgets/error_widget.dart';

/// Ticket details for a persisted booking. Reads the booking passed as
/// router extra when available (no extra data fetch); falls back to
/// fetching by ID so deep links into /tickets/:bookingId keep working.
class TicketDetailScreen extends StatefulWidget {
  final String bookingId;
  final Booking? booking;

  const TicketDetailScreen({
    super.key,
    required this.bookingId,
    this.booking,
  });

  @override
  State<TicketDetailScreen> createState() => _TicketDetailScreenState();
}

class _TicketDetailScreenState extends State<TicketDetailScreen> {
  Booking? _booking;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _booking = widget.booking;
    if (_booking == null) _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final result =
        await sl<BookingRepository>().getBookingDetails(widget.bookingId);

    if (!mounted) return;
    result.fold(
      (failure) => setState(() {
        _loading = false;
        _error = failure.message;
      }),
      (booking) => setState(() {
        _loading = false;
        _booking = booking;
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: Text('Ticket Details', style: AppTextStyles.h3),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.canPop()
              ? context.pop()
              : context.go('/my-bookings'),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }
    if (_error != null) {
      return AppErrorWidget(message: _error!, onRetry: _load);
    }

    final booking = _booking;
    if (booking == null) return const SizedBox.shrink();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(booking),
          const SizedBox(height: 20),
          _buildInfoCard(booking),
          const SizedBox(height: 20),
          _buildQrCard(booking),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildHeader(Booking booking) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: CachedNetworkImage(
            imageUrl: booking.moviePosterUrl,
            width: 90,
            height: 130,
            fit: BoxFit.cover,
            placeholder: (_, _) => Container(color: AppColors.surfaceLight),
            errorWidget: (_, _, _) => Container(
              width: 90,
              height: 130,
              color: AppColors.surfaceLight,
              child: const Icon(Icons.movie_outlined,
                  color: AppColors.textHint),
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                booking.movieTitle,
                style: AppTextStyles.h2,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              Text(
                '${booking.language} · ${booking.format}',
                style: AppTextStyles.caption,
              ),
              const SizedBox(height: 10),
              _StatusChip(status: booking.status),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(Booking booking) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          _InfoRow(
            icon: Icons.theaters_rounded,
            label: booking.theatreName,
            sub: booking.theatreAddress,
          ),
          const Divider(color: AppColors.divider, height: 20),
          _InfoRow(
            icon: Icons.event_rounded,
            label:
                '${AppDateUtils.formatShortDate(booking.showTime)} · ${AppDateUtils.formatTime(booking.showTime)}',
            sub: booking.seatCount,
          ),
          const Divider(color: AppColors.divider, height: 20),
          _InfoRow(
            icon: Icons.event_seat_rounded,
            label: booking.seatLabels,
            sub: 'Seats',
          ),
          if (booking.foodItems.isNotEmpty) ...[
            const Divider(color: AppColors.divider, height: 20),
            _InfoRow(
              icon: Icons.fastfood_rounded,
              label: booking.foodItems
                  .map((f) => '${f.name} x${f.quantity}')
                  .join(', '),
              sub: 'Food & Beverages',
            ),
          ],
          const Divider(color: AppColors.divider, height: 20),
          _buildPriceRow(
              'Ticket amount', booking.baseAmount),
          if (booking.foodItems.isNotEmpty)
            _buildPriceRow('Food & beverages', booking.foodItems.fold<double>(0, (sum, f) => sum + f.totalPrice)),
          _buildPriceRow('Convenience fee', booking.convenienceFee),
          _buildPriceRow('GST', booking.taxes),
          if (booking.discountAmount > 0)
            _buildPriceRow('Discount', -booking.discountAmount),
          const Divider(color: AppColors.divider, height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total Paid', style: AppTextStyles.h3),
              Text(
                CurrencyUtils.format(booking.totalAmount),
                style: AppTextStyles.h2.copyWith(color: AppColors.primary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, double value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.bodySmall),
          Text(
            CurrencyUtils.format(value.abs()),
            style: AppTextStyles.labelLarge.copyWith(
              color: value < 0 ? AppColors.green : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQrCard(Booking booking) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: QrImageView(
              data: booking.qrData,
              size: 160,
              backgroundColor: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Text('Booking ID: ${booking.id}', style: AppTextStyles.labelMedium),
          const SizedBox(height: 4),
          Text(
            'Show this QR at the theatre entrance',
            style: AppTextStyles.caption,
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String sub;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.sub,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.primary, size: 18),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: AppTextStyles.labelLarge,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis),
              Text(sub, style: AppTextStyles.caption),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  final BookingStatus status;

  const _StatusChip({required this.status});

  Color get _color {
    switch (status) {
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: _color),
      ),
      child: Text(
        status.name[0].toUpperCase() + status.name.substring(1),
        style: AppTextStyles.labelSmall.copyWith(color: _color),
      ),
    );
  }
}
