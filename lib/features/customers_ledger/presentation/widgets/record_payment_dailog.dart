import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/currency_text.dart';
import '../controllers/customers_controller.dart';

/// Record a payment against a customer's Udhar balance. Demo-grade for
/// now — it only appends to the in-memory sample ledger (via
/// CustomersController), no real ledger_transactions write yet.
class RecordPaymentDialog extends StatefulWidget {
  const RecordPaymentDialog({super.key, required this.customer, required this.currentBalance});

  final SampleCustomer customer;
  final int currentBalance;

  @override
  State<RecordPaymentDialog> createState() => _RecordPaymentDialogState();
}

class _RecordPaymentDialogState extends State<RecordPaymentDialog> {
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _submit() {
    final amount = int.tryParse(_amountController.text.trim());
    if (amount == null || amount <= 0) {
      setState(() => _error = 'Enter a valid amount');
      return;
    }
    if (amount > widget.currentBalance) {
      setState(() => _error = "Can't be more than the balance owed");
      return;
    }

    Get.find<CustomersController>().recordPayment(
      customerId: widget.customer.id,
      amount: amount,
      note: _noteController.text.trim().isEmpty ? 'Payment received' : _noteController.text.trim(),
    );
    Get.back();
    Get.snackbar(
      'Payment recorded',
      "${widget.customer.name}'s balance has been updated.",
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.of(context).size;
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
      insetPadding: const EdgeInsets.all(AppSpacing.gutterLg),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: math.min(400, screen.width * 0.92),
          maxHeight: math.min(420, screen.height * 0.85),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.gutterLg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Record Payment', style: AppTypography.headlineMd),
              const SizedBox(height: AppSpacing.xs),
              Row(
                children: [
                  Text('${widget.customer.name} owes ', style: AppTypography.bodySm),
                  CurrencyText(widget.currentBalance, style: AppTypography.bodySm),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              AppTextField(
                controller: _amountController,
                label: 'Amount Received (Rs.)',
                hint: 'e.g. ${widget.currentBalance}',
                keyboardType: TextInputType.number,
                autofocus: true,
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                controller: _noteController,
                label: 'Note (optional)',
                hint: 'Payment received',
              ),
              if (_error != null) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(_error!, style: AppTypography.bodySm.copyWith(color: AppColors.danger)),
              ],
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  Expanded(child: AppButton(label: 'Cancel', variant: AppButtonVariant.secondary, onPressed: Get.back)),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(child: AppButton(label: 'Record Payment', onPressed: _submit)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}