import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../bloc/seat/seat_cubit.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../services/booking_session_cache.dart';
import 'widgets/seat_widget.dart';
import 'widgets/seat_legend.dart';

class SeatSelectionScreen extends StatefulWidget {
  final String showId;

  const SeatSelectionScreen({super.key, required this.showId});

  @override
  State<SeatSelectionScreen> createState() => _SeatSelectionScreenState();
}

class _SeatSelectionScreenState extends State<SeatSelectionScreen> {
  @override
  void initState() {
    super.initState();
    context.read<SeatCubit>().loadLayout(widget.showId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              BookingSessionCache.instance.movie?.title ?? 'Select Seats',
              style: AppTextStyles.h3,
            ),
            Text(
              BookingSessionCache.instance.show?.formattedTime ?? '',
              style: const TextStyle(
                color: AppColors.textHint,
                fontSize: 12,
                fontFamily: 'Gilroy',
              ),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: BlocConsumer<SeatCubit, SeatState>(
        listener: (context, state) {
          if (state is SeatLoaded && state.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error!),
                backgroundColor: AppColors.primaryDark,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                margin: const EdgeInsets.all(16),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is SeatLoading || state is SeatInitial) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }
          if (state is SeatError) {
            return Center(
              child: Text(state.message, style: AppTextStyles.bodyMedium),
            );
          }

          final loaded = state as SeatLoaded;
          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildScreenIndicator(),
                      const SizedBox(height: 8),
                      _buildSeatMap(loaded),
                      const SeatLegend(),
                      _buildPricingInfo(loaded),
                    ],
                  ),
                ),
              ),
              _buildBottomBar(loaded),
            ],
          );
        },
      ),
    );
  }

  Widget _buildScreenIndicator() {
    return Container(
      margin: const EdgeInsets.fromLTRB(40, 16, 40, 0),
      child: Column(
        children: [
          Container(
            height: 4,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  AppColors.textHint.withValues(alpha: 0.6),
                  Colors.transparent,
                ],
              ),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'SCREEN',
            style: AppTextStyles.caption.copyWith(letterSpacing: 3),
          ),
        ],
      ),
    );
  }

  Widget _buildSeatMap(SeatLoaded state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: state.layout.rows.map((row) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                children: [
                  // Row label
                  SizedBox(
                    width: 24,
                    child: Text(
                      row.rowLabel,
                      style: AppTextStyles.caption.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(width: 6),
                  ...row.seats.asMap().entries.map((entry) {
                    final i = entry.key;
                    final seat = entry.value;
                    final isSelected =
                        state.selectedSeats.any((s) => s.id == seat.id);

                    // Small gap in the middle for the aisle
                    return Row(
                      children: [
                        if (i == row.seats.length ~/ 2)
                          const SizedBox(width: 16),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2),
                          child: SeatWidget(
                            seat: seat,
                            isSelected: isSelected,
                            onTap: () =>
                                context.read<SeatCubit>().toggleSeat(seat),
                          ),
                        ),
                      ],
                    );
                  }),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildPricingInfo(SeatLoaded state) {
    final pricing = state.layout.pricing;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: pricing.entries.map((entry) {
          final label = entry.key.name[0].toUpperCase() +
              entry.key.name.substring(1);
          return Column(
            children: [
              Text('₹${entry.value.toInt()}',
                  style: AppTextStyles.labelLarge),
              Text(label, style: AppTextStyles.caption),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBottomBar(SeatLoaded state) {
    final count = state.selectedSeats.length;
    final total = state.totalPrice;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: const Border(
          top: BorderSide(color: AppColors.divider),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  count == 0
                      ? 'No seats selected'
                      : '$count Seat${count > 1 ? 's' : ''} selected',
                  style: AppTextStyles.labelLarge,
                ),
                if (count > 0)
                  Text(
                    '₹${total.toStringAsFixed(0)} + fees',
                    style: AppTextStyles.bodySmall,
                  ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: count == 0 ? null : _onProceed,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(130, 48),
            ),
            child: const Text('Proceed'),
          ),
        ],
      ),
    );
  }

  void _onProceed() {
    final state = context.read<SeatCubit>().state;
    if (state is! SeatLoaded) return;

    // Save selection to the booking session
    final session = BookingSessionCache.instance;
    session.selectedSeats = List.from(state.selectedSeats);

    context.push('/booking/summary');
  }
}