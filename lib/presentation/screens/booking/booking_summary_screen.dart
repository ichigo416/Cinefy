import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../config/di/service_locator.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../domain/entities/booking.dart';
import '../../../domain/repositories/booking_repository.dart';
import '../../../presentation/bloc/booking/booking_bloc.dart';
import '../../../services/booking_session_cache.dart';

class BookingSummaryScreen extends StatefulWidget {
  const BookingSummaryScreen({super.key});

  @override
  State<BookingSummaryScreen> createState() => _BookingSummaryScreenState();
}

class _BookingSummaryScreenState extends State<BookingSummaryScreen> {
  final _promoController = TextEditingController();
  bool _promoApplied = false;
  bool _loading = false;

  // Sample food items
  final List<FoodItem> _foodMenu = [
    FoodItem(id: 'f1', name: 'Butter Popcorn (Large)', price: 220, isVeg: true),
    FoodItem(id: 'f2', name: 'Caramel Popcorn (Medium)', price: 180, isVeg: true),
    FoodItem(id: 'f3', name: 'Nachos with Cheese', price: 150, isVeg: true),
    FoodItem(id: 'f4', name: 'Pepsi (600ml)', price: 80, isVeg: true),
    FoodItem(id: 'f5', name: 'Hot Dog', price: 130, isVeg: false),
    FoodItem(id: 'f6', name: 'Samosa (2 pcs)', price: 60, isVeg: true),
  ];

  final List<FoodItem> _cart = [];
  final session = BookingSessionCache.instance;

  @override
  void dispose() {
    _promoController.dispose();
    super.dispose();
  }

  void _addToCart(FoodItem item) {
    setState(() {
      final index = _cart.indexWhere((f) => f.id == item.id);
      if (index == -1) {
        _cart.add(FoodItem(
          id: item.id,
          name: item.name,
          price: item.price,
          isVeg: item.isVeg,
        ));
      } else {
        _cart[index] = _cart[index].copyWith(
          quantity: _cart[index].quantity + 1,
        );
      }
    });
  }

  void _removeFromCart(FoodItem item) {
    setState(() {
      final index = _cart.indexWhere((f) => f.id == item.id);
      if (index == -1) return;
      if (_cart[index].quantity <= 1) {
        _cart.removeAt(index);
      } else {
        _cart[index] = _cart[index].copyWith(
          quantity: _cart[index].quantity - 1,
        );
      }
    });
  }

  int _cartQty(String id) {
    final match = _cart.where((f) => f.id == id);
    return match.isEmpty ? 0 : match.first.quantity;
  }

  double get _baseAmount {
    final layout = session.selectedSeats;
    // Use flat show base price × seat count as approximation here
    final show = session.show;
    if (show == null) return 0;
    return show.basePrice * layout.length;
  }

  double get _foodTotal =>
      _cart.fold(0, (sum, f) => sum + f.totalPrice);

  double get _convenienceFee =>
      (session.selectedSeats.length * 30).toDouble();

  double get _discount =>
      _promoApplied ? (_baseAmount * 0.1).clamp(0, 50) : 0;

  double get _taxes =>
      (_baseAmount + _foodTotal + _convenienceFee) * 0.18;

  double get _grandTotal =>
      _baseAmount + _foodTotal + _convenienceFee + _taxes - _discount;

  void _applyPromo() {
    final code = _promoController.text.trim().toUpperCase();
    setState(() {
      _promoApplied = code == 'FIRST50';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _promoApplied
              ? 'Promo applied! You saved ₹${_discount.toInt()}'
              : 'Invalid promo code',
        ),
        backgroundColor:
            _promoApplied ? AppColors.green : AppColors.primaryDark,
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Future<void> _pay() async {
    setState(() => _loading = true);

    // Save food items and promo to session before proceeding
    session.foodItems = List.from(_cart);
    session.promoCode = _promoApplied ? _promoController.text.trim() : null;
    session.baseAmount = _baseAmount + _foodTotal;
    session.convenienceFee = _convenienceFee;
    session.taxes = _taxes;
    session.discountAmount = _discount;

    // Simulate payment gateway delay
    await Future.delayed(const Duration(seconds: 2));

    // Create the booking through the (mock) backend
    final result = await sl<BookingRepository>().createBooking(
      showId: session.show?.id ?? '',
      seatIds: session.selectedSeats.map((s) => s.id).toList(),
      foodItems: List.from(_cart),
      promoCode: session.promoCode,
    );

    if (!mounted) return;
    setState(() => _loading = false);

    result.fold(
      (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(failure.message),
            backgroundColor: AppColors.primaryDark,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            margin: const EdgeInsets.all(16),
          ),
        );
      },
      (booking) {
        // Invalidate the My Bookings list so a new booking appears on the
        // next tab entry (in-memory store changed)
        sl<BookingBloc>().add(const BookingFetchEvent());

        // Sync session totals with the persisted booking record so the
        // confirmation screen matches what the (mock) backend actually stored
        session.baseAmount = booking.baseAmount;
        session.convenienceFee = booking.convenienceFee;
        session.taxes = booking.taxes;
        session.discountAmount = booking.discountAmount;
        context.go('/booking/confirmed/${booking.id}');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: Text('Booking Summary', style: AppTextStyles.h3),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildShowCard(),
                  const SizedBox(height: 20),
                  _buildSeatsCard(),
                  const SizedBox(height: 20),
                  _buildFoodSection(),
                  const SizedBox(height: 20),
                  _buildPromoSection(),
                  const SizedBox(height: 20),
                  _buildPriceBreakdown(),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
          _buildPayButton(),
        ],
      ),
    );
  }

  Widget _buildShowCard() {
    final movie = session.movie;
    final show = session.show;
    final theatre = session.theatre;
    if (movie == null || show == null || theatre == null) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              movie.posterUrl,
              width: 56,
              height: 80,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Container(
                width: 56,
                height: 80,
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
                Text(movie.title,
                    style: AppTextStyles.h3,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text(theatre.name,
                    style: AppTextStyles.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text(
                  '${show.formattedTime}  •  ${show.language}  •  ${show.format}',
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeatsCard() {
    final seats = session.selectedSeats;
    return _SectionCard(
      title: 'Seats',
      child: Row(
        children: [
          const Icon(Icons.event_seat_rounded,
              color: AppColors.primary, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              seats.map((s) => s.label).join(', '),
              style: AppTextStyles.bodyMedium,
            ),
          ),
          Text(
            '${seats.length} ticket${seats.length > 1 ? 's' : ''}',
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFoodSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Food & Beverages', style: AppTextStyles.h2),
        const SizedBox(height: 4),
        Text('Optional — save time at the counter',
            style: AppTextStyles.bodySmall),
        const SizedBox(height: 12),
        ..._foodMenu.map((item) {
          final qty = _cartQty(item.id);
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: item.isVeg ? AppColors.green : AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(item.name, style: AppTextStyles.labelLarge),
                ),
                Text('₹${item.price.toInt()}',
                    style: AppTextStyles.labelLarge),
                const SizedBox(width: 12),
                _QtyControl(
                  qty: qty,
                  onAdd: () => _addToCart(item),
                  onRemove: () => _removeFromCart(item),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildPromoSection() {
    return _SectionCard(
      title: 'Promo Code',
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _promoController,
              style: AppTextStyles.bodyMedium,
              textCapitalization: TextCapitalization.characters,
              decoration: const InputDecoration(
                hintText: 'Enter code (try FIRST50)',
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
            ),
          ),
          const SizedBox(width: 10),
          ElevatedButton(
            onPressed: _applyPromo,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(80, 46),
              backgroundColor: AppColors.primary,
            ),
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceBreakdown() {
    return _SectionCard(
      title: 'Price Breakdown',
      child: Column(
        children: [
          _PriceRow(
              label: 'Base amount (${session.selectedSeats.length} seats)',
              value: _baseAmount),
          if (_foodTotal > 0)
            _PriceRow(label: 'Food & beverages', value: _foodTotal),
          _PriceRow(label: 'Convenience fee', value: _convenienceFee),
          _PriceRow(label: 'GST (18%)', value: _taxes),
          if (_promoApplied)
            _PriceRow(
              label: 'Promo discount',
              value: -_discount,
              valueColor: AppColors.green,
            ),
          const Divider(color: AppColors.divider, height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total', style: AppTextStyles.h3),
              Text(
                '₹${_grandTotal.toStringAsFixed(0)}',
                style: AppTextStyles.h2.copyWith(color: AppColors.primary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPayButton() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: const Border(top: BorderSide(color: AppColors.divider)),
      ),
      child: ElevatedButton(
        onPressed: _loading ? null : _pay,
        child: _loading
            ? const SizedBox(
                height: 22,
                width: 22,
                child:
                    CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
            : Text('Pay ₹${_grandTotal.toStringAsFixed(0)}'),
      ),
    );
  }
}

// ─── Small reusable widgets ───────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.labelMedium),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  final String label;
  final double value;
  final Color? valueColor;

  const _PriceRow({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.bodySmall),
          Text(
            '${value < 0 ? '-' : ''}₹${value.abs().toStringAsFixed(0)}',
            style: AppTextStyles.labelLarge.copyWith(
              color: valueColor ?? AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _QtyControl extends StatelessWidget {
  final int qty;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  const _QtyControl({
    required this.qty,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    if (qty == 0) {
      return GestureDetector(
        onTap: onAdd,
        child: Container(
          width: 60,
          height: 30,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.primary),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text('ADD',
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.primary,
              )),
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _StepButton(icon: Icons.remove, onTap: onRemove),
        SizedBox(
          width: 28,
          child: Text('$qty',
              textAlign: TextAlign.center,
              style: AppTextStyles.labelLarge),
        ),
        _StepButton(icon: Icons.add, onTap: onAdd),
      ],
    );
  }
}

class _StepButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _StepButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon, color: Colors.white, size: 16),
      ),
    );
  }
}