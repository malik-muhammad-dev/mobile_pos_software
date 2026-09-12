import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// Renders a whole-PKR amount with tabular figures and thousands separators
/// (e.g. "Rs. 408,000"). Never handles decimals — the schema stores money
/// as whole-integer PKR, no floating point currency anywhere.
class CurrencyText extends StatelessWidget {
  const CurrencyText(
    this.amount, {
    super.key,
    this.style,
    this.currencySymbol = 'Rs.',
    this.isLiveValue = false,
  });

  final int amount;
  final TextStyle? style;
  final String currencySymbol;

  /// Marks a system-calculated number (stock counts, customer balances) —
  /// these are never manually editable, and should read as trustworthy
  /// rather than as an editable field. Callers can style around this flag.
  final bool isLiveValue;

  @override
  Widget build(BuildContext context) {
    final formatted = NumberFormat.decimalPattern('en_PK').format(amount);
    final baseStyle = (style ?? AppTypography.headlineSm).merge(AppTypography.numeric);
    return Text(
      '$currencySymbol $formatted',
      style: isLiveValue ? baseStyle.copyWith(color: AppColors.textPrimary) : baseStyle,
    );
  }
}