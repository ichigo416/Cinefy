import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/utils/currency_utils.dart';
import '../../../core/utils/date_utils.dart';
import '../../../services/booking_session_cache.dart';

class BookingConfirmationScreen extends StatefulWidget {
  final String bookingId;

  const BookingConfirmationScreen({super.key, required this.bookingId});

  @override
  State<BookingConfirmationScreen> createState() =>
      _BookingConfirmationScreenState();
}

class _BookingConfirmationScreenState
    extends State<BookingConfirmationScreen> {
  final ScreenshotController _screenshotController = ScreenshotController();
  bool _isDownloading = false;
  bool _isSharing = false;

  @override
  Widget build(BuildContext context) {
    final session = BookingSessionCache.instance;
    final movie = session.movie;
    final show = session.show;
    final theatre = session.theatre;
    final seats = session.selectedSeats;
    final total = session.totalAmount;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 20),
              _buildSuccessHeader(),
              const SizedBox(height: 32),
              _buildTicket(
                context,
                bookingId: widget.bookingId,
                movieTitle: movie?.title ?? '',
                theatreName: theatre?.name ?? '',
                theatreAddress: theatre?.address ?? '',
                showTime: show?.formattedTime ?? '',
                language: show?.language ?? '',
                format: show?.format ?? '',
                seatLabels: seats.map((s) => s.label).join(', '),
                seatCount: seats.length,
                totalAmount: total,
              ),
              const SizedBox(height: 28),
              _buildActions(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessHeader() {
    return Column(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: AppColors.green.withOpacity(0.15),
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.green, width: 2),
          ),
          child: const Icon(Icons.check_rounded,
              color: AppColors.green, size: 38),
        ),
        const SizedBox(height: 16),
        Text('Booking Confirmed!', style: AppTextStyles.h1),
        const SizedBox(height: 6),
        Text(
          'Have a great time!',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  /// Generates the ticket image from the on-screen ticket widget (existing
  /// design system, QR included) and saves it as a PNG. Prefers the platform
  /// Downloads directory (Windows/desktop); falls back to the temporary
  /// directory (mobile). Shows a clear success/error message.
  Future<void> _downloadTicket() async {
    setState(() => _isDownloading = true);
    try {
      final bytes = await _screenshotController.capture();
      if (bytes == null) {
        throw Exception('Ticket generation failed');
      }

      final dir =
          await getDownloadsDirectory() ?? await getTemporaryDirectory();
      final fileName = 'Cinefy_Ticket_${widget.bookingId}.png';
      final file = File('${dir.path}${Platform.pathSeparator}$fileName');
      await file.writeAsBytes(bytes);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ticket saved as $fileName'),
            backgroundColor: AppColors.green,
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not download ticket. Please try again.'),
            backgroundColor: AppColors.primary,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isDownloading = false);
    }
  }

  /// Shares the booking summary through the platform share sheet. Attempts
  /// to include the generated ticket image; falls back to text-only on
  /// capture failure. Share cancellation is handled gracefully (no error).
  Future<void> _shareTicket() async {
    setState(() => _isSharing = true);
    try {
      final session = BookingSessionCache.instance;
      final show = session.show;
      final date = show?.startTime != null
          ? AppDateUtils.formatShortDate(show!.startTime)
          : '';
      final time = show?.formattedTime ?? '';
      final seats = session.selectedSeats.map((s) => s.label).join(', ');

      final text = 'Cinefy\n\n'
          '${session.movie?.title ?? ''}\n'
          '${session.theatre?.name ?? ''}\n'
          '$date • $time\n'
          'Seats: $seats\n'
          'Booking ID: ${widget.bookingId}\n'
          'Total: ${CurrencyUtils.format(session.totalAmount)}';

      XFile? ticketFile;
      try {
        final bytes = await _screenshotController.capture();
        if (bytes != null) {
          final dir = await getTemporaryDirectory();
          final fileName = 'Cinefy_Ticket_${widget.bookingId}.png';
          final file =
              File('${dir.path}${Platform.pathSeparator}$fileName');
          await file.writeAsBytes(bytes);
          ticketFile = XFile(file.path);
        }
      } catch (_) {
        ticketFile = null;
      }

      if (ticketFile != null) {
        await Share.shareXFiles(
          [ticketFile],
          text: text,
          subject: 'Cinefy Ticket',
        );
      } else {
        await Share.share(text, subject: 'Cinefy Ticket');
      }
    } finally {
      if (mounted) setState(() => _isSharing = false);
    }
  }

  Widget _buildTicket(
    BuildContext context, {
    required String bookingId,
    required String movieTitle,
    required String theatreName,
    required String theatreAddress,
    required String showTime,
    required String language,
    required String format,
    required String seatLabels,
    required int seatCount,
    required double totalAmount,
  }) {
    return Screenshot(
      controller: _screenshotController,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
      child: Column(
        children: [
          // Top section
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(movieTitle, style: AppTextStyles.h2),
                const SizedBox(height: 14),
                _TicketRow(
                    icon: Icons.location_on_outlined,
                    label: theatreName,
                    sub: theatreAddress),
                const SizedBox(height: 10),
                _TicketRow(
                    icon: Icons.access_time_rounded,
                    label: showTime,
                    sub: '$language  •  $format'),
                const SizedBox(height: 10),
                _TicketRow(
                    icon: Icons.event_seat_rounded,
                    label: seatLabels,
                    sub:
                        '$seatCount seat${seatCount > 1 ? 's' : ''}'),
              ],
            ),
          ),
          // Dashed divider (ticket tear line)
          _DashedDivider(),
          // QR section
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                QrImageView(
                  data: bookingId,
                  version: QrVersions.auto,
                  size: 160,
                  backgroundColor: Colors.white,
                  padding: const EdgeInsets.all(10),
                ),
                const SizedBox(height: 12),
                Text(
                  bookingId,
                  style: AppTextStyles.labelMedium.copyWith(
                    letterSpacing: 2,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Show this QR at the entry',
                  style: AppTextStyles.caption,
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: AppColors.primary.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        CurrencyUtils.format(totalAmount),
                        style: AppTextStyles.h3.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text('paid', style: AppTextStyles.bodySmall),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      ),
    );
  }

  Widget _buildActions() {
    return Column(
      children: [
        ElevatedButton.icon(
          onPressed: _isDownloading ? null : _downloadTicket,
          icon: _isDownloading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white),
                )
              : const Icon(Icons.download_rounded, size: 18),
          label: Text(_isDownloading ? 'Generating…' : 'Download Ticket'),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 50),
          ),
        ),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          onPressed: _isSharing ? null : _shareTicket,
          icon: const Icon(Icons.share_rounded, size: 18),
          label: const Text('Share'),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 50),
          ),
        ),
        const SizedBox(height: 10),
        TextButton(
          onPressed: () {
            // Clear session and go back to home
            BookingSessionCache.instance.reset();
            context.go('/home');
          },
          child: Text(
            'Back to Home',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}

class _TicketRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String sub;

  const _TicketRow({
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
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
              Text(sub, style: AppTextStyles.caption),
            ],
          ),
        ),
      ],
    );
  }
}

class _DashedDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: AppColors.background,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.border),
          ),
          transform: Matrix4.translationValues(-10, 0, 0),
        ),
        Expanded(
          child: LayoutBuilder(
            builder: (_, constraints) {
              final count = (constraints.maxWidth / 8).floor();
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(
                  count,
                  (_) => Container(
                    width: 4,
                    height: 1.5,
                    color: AppColors.border,
                  ),
                ),
              );
            },
          ),
        ),
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: AppColors.background,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.border),
          ),
          transform: Matrix4.translationValues(10, 0, 0),
        ),
      ],
    );
  }
}