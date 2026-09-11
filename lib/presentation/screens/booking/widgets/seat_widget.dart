import 'package:flutter/material.dart';
import '../../../../domain/entities/seat.dart';
import '../../../../core/constants/app_colors.dart';

class SeatWidget extends StatelessWidget {
  final Seat seat;
  final bool isSelected;
  final VoidCallback? onTap;

  const SeatWidget({
    super.key,
    required this.seat,
    required this.isSelected,
    this.onTap,
  });

  Color get _color {
    if (isSelected) return AppColors.seatSelected;
    switch (seat.status) {
      case SeatStatus.booked:
      case SeatStatus.blocked:
        return AppColors.seatBooked;
      case SeatStatus.available:
        switch (seat.category) {
          case SeatCategory.recliner:
            return AppColors.seatRecliner;
          case SeatCategory.premium:
            return AppColors.seatPremium;
          case SeatCategory.normal:
            return AppColors.seatAvailable;
        }
      default:
        return AppColors.seatBooked;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: seat.isSelectable ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        width: 26,
        height: 24,
        decoration: BoxDecoration(
          color: _color.withOpacity(
            seat.status == SeatStatus.booked ? 0.35 : 1.0,
          ),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(5),
            topRight: Radius.circular(5),
            bottomLeft: Radius.circular(2),
            bottomRight: Radius.circular(2),
          ),
          border: isSelected
              ? Border.all(color: Colors.white, width: 1.5)
              : null,
        ),
        child: isSelected
            ? const Icon(Icons.check_rounded, color: Colors.white, size: 12)
            : null,
      ),
    );
  }
}