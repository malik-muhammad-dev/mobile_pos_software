import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import 'app_button.dart';
import 'currency_text.dart';

/// Everything a receipt needs to render — deliberately generic (a plain
/// list of lines) rather than tied to Sales' sample models, since this
/// widget is meant to be reused anywhere a transaction needs to be shown
/// or handed to a customer: Sales right now, Reports/ledger history later.
class ReceiptData {
  const ReceiptData({
    required this.customerName,
    required this.itemDescription,
    required this.price,
    this.discount = 0,
    required this.amountPaid,
    required this.cashierName,
    required this.dateTime,
  });

  final String customerName;
  final String itemDescription;
  final int price;
  final int discount;
  final int amountPaid;
  final String cashierName;
  final DateTime dateTime;

  int get netPrice => (price - discount).clamp(0, price);
  int get balanceDue => (netPrice - amountPaid).clamp(0, netPrice);
  bool get isFullyPaid => balanceDue == 0;
  bool get hasDiscount => discount > 0;
}

/// A printable-looking sales receipt. Kept in core/widgets because it's
/// generic enough to be reused wherever a transaction needs to be shown —
/// not just right after a New Sale, but later from Reports/ledger history
/// or an eventual real "print" action.
class ReceiptView extends StatelessWidget {
  const ReceiptView({super.key, required this.data});

  final ReceiptData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.gutterLg),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.borderDefault),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Column(
              children: [
                const Icon(Icons.storefront_rounded, color: AppColors.primary, size: 28),
                const SizedBox(height: AppSpacing.xs),
                const Text('SALES RECEIPT', style: AppTypography.headlineSm),
                const SizedBox(height: 2),
                Text(
                  DateFormat('d MMM yyyy, h:mm a').format(data.dateTime),
                  style: AppTypography.bodySm,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          const _DashedDivider(),
          const SizedBox(height: AppSpacing.md),
          _line('Customer', data.customerName),
          const SizedBox(height: AppSpacing.xs),
          _line('Cashier', data.cashierName),
          const SizedBox(height: AppSpacing.md),
          const _DashedDivider(),
          const SizedBox(height: AppSpacing.md),
          Text(data.itemDescription, style: AppTypography.bodyLg),
          const SizedBox(height: AppSpacing.md),
          const _DashedDivider(),
          const SizedBox(height: AppSpacing.md),
          _amountRow('Price', data.price),
          if (data.hasDiscount) ...[
            const SizedBox(height: AppSpacing.xs),
            _amountRow('Discount', -data.discount, tint: AppColors.danger),
            const SizedBox(height: AppSpacing.xs),
            _amountRow('Net Price', data.netPrice, emphasize: true),
          ],
          const SizedBox(height: AppSpacing.xs),
          _amountRow('Amount Paid', data.amountPaid),
          const SizedBox(height: AppSpacing.xs),
          _amountRow(
            data.isFullyPaid ? 'Balance' : 'Balance Due (Udhar)',
            data.balanceDue,
            emphasize: !data.isFullyPaid,
          ),
          const SizedBox(height: AppSpacing.md),
          const _DashedDivider(),
          const SizedBox(height: AppSpacing.md),
          Center(
            child: Text(
              data.isFullyPaid ? 'PAID IN FULL — thank you!' : 'PARTIAL PAYMENT — balance recorded as Udhar',
              style: AppTypography.labelLg.copyWith(
                color: data.isFullyPaid ? AppColors.success : AppColors.warning,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _line(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTypography.bodyMd),
        Flexible(child: Text(value, style: AppTypography.bodyLg, overflow: TextOverflow.ellipsis, textAlign: TextAlign.right)),
      ],
    );
  }

  Widget _amountRow(String label, int amount, {bool emphasize = false, Color? tint}) {
    final color = tint ?? (emphasize ? AppColors.warning : null);
    final isNegative = amount < 0;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: emphasize ? AppTypography.labelLg.copyWith(color: color) : AppTypography.bodyMd.copyWith(color: color)),
        Row(
          children: [
            if (isNegative) Text('− ', style: AppTypography.headlineSm.copyWith(color: color)),
            CurrencyText(
              amount.abs(),
              style: emphasize
                  ? AppTypography.headlineSm.copyWith(color: color)
                  : AppTypography.headlineSm.copyWith(color: color),
            ),
          ],
        ),
      ],
    );
  }
}

class _DashedDivider extends StatelessWidget {
  const _DashedDivider();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const dashWidth = 6.0;
        const dashSpace = 4.0;
        final count = (constraints.maxWidth / (dashWidth + dashSpace)).floor();
        return Row(
          children: List.generate(
            count,
            (_) => Container(
              width: dashWidth,
              height: 1,
              margin: const EdgeInsets.only(right: dashSpace),
              color: AppColors.borderDefault,
            ),
          ),
        );
      },
    );
  }
}

/// Shows the receipt in a dialog right after a sale (or later, from history).
/// "Print" is stubbed for now — there's no printer integration yet.
void showReceiptDialog(ReceiptData data) {
  Get.dialog(
    Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
      insetPadding: const EdgeInsets.all(AppSpacing.gutterLg),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 380),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.gutterLg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ReceiptView(data: data),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        label: 'Print',
                        variant: AppButtonVariant.secondary,
                        icon: Icons.print_outlined,
                        onPressed: () => Get.snackbar(
                          'Not ready yet',
                          "Printing isn't wired up yet.",
                          snackPosition: SnackPosition.BOTTOM,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(child: AppButton(label: 'Done', onPressed: Get.back)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}