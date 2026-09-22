class CurrencyUtils {
  CurrencyUtils._();

  static String format(
    num amount, {
    bool showDecimals = false,
  }) {
    if (showDecimals) {
      return '₹${amount.toStringAsFixed(2)}';
    }

    return '₹${amount.round()}';
  }

  static String formatWithLabel(num amount) {
    return '₹${amount.toStringAsFixed(0)}';
  }
} 