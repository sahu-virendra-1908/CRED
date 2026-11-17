import 'package:intl/intl.dart';

class FormattedCurrencyParts {
  const FormattedCurrencyParts({
    required this.symbol,
    required this.wholePart,
    required this.decimalPart,
  });

  final String symbol;
  final String wholePart;
  final String decimalPart;

  String get fullFormatted => '$symbol$wholePart.$decimalPart';
}

abstract final class CurrencyFormatter {
  static final NumberFormat _indianGrouping = NumberFormat('#,##,##0', 'en_IN');

  static FormattedCurrencyParts splitInr(double amount) {
    final safeAmount = amount.isNaN || amount.isInfinite ? 0.0 : amount;
    final absolute = safeAmount.abs();
    final whole = absolute.floor();
    final paise = ((absolute - whole) * 100).round();

    final adjustedWhole = paise >= 100 ? whole + 1 : whole;
    final adjustedPaise = paise >= 100 ? 0 : paise;

    final prefix = safeAmount < 0 ? '-₹' : '₹';
    return FormattedCurrencyParts(
      symbol: prefix,
      wholePart: _indianGrouping.format(adjustedWhole),
      decimalPart: adjustedPaise.toString().padLeft(2, '0'),
    );
  }

  static double parseAmount(String? raw) {
    if (raw == null || raw.trim().isEmpty) return 0.0;
    final cleaned = raw.replaceAll(RegExp(r'[^0-9.-]'), '');
    return double.tryParse(cleaned) ?? 0.0;
  }
}
