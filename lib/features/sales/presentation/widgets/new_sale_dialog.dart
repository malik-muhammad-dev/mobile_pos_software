import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/currency_text.dart';
import '../../../../core/widgets/receipt_view.dart';
import '../../../inventory/presentations/controllers/inventory_controller.dart';
import '../controllers/sales_controller.dart';

final _moneyFormat = NumberFormat.decimalPattern('en_PK');

/// One item the cashier can pick in the device search field — either a real
/// unit/product still in stock, or the always-present "custom" option for
/// something not tracked in Inventory (an accessory, a phone not yet added).
/// `salePrice` is the listed retail price — the cashier can still knock a
/// discount off it at the counter, tracked separately below.
class _DeviceOption {
  const _DeviceOption({required this.label, required this.salePrice, this.iphoneUnitId, this.androidProductId});

  final String label;
  final int salePrice;
  final String? iphoneUnitId;
  final String? androidProductId;

  bool get isCustom => iphoneUnitId == null && androidProductId == null;

  @override
  String toString() => label;
}

const _customDeviceOption = _DeviceOption(label: 'Custom Item / Not in Inventory…', salePrice: 0);

/// Quick "record a sale" form — demo-grade for now: it appends to the
/// in-memory sample lists (via SalesController.addSale) and, when a real
/// Inventory unit is picked, marks it sold/decrements it there too. There's
/// still no real invoicing/database behind this — it exists so the full
/// flow (pick device → take payment → get a receipt) can be shown to a
/// client before the real Sales/Inventory data layer is wired in.
class NewSaleDialog extends StatefulWidget {
  const NewSaleDialog({super.key});

  @override
  State<NewSaleDialog> createState() => _NewSaleDialogState();
}

class _NewSaleDialogState extends State<NewSaleDialog> {
  final _customerController = TextEditingController();
  final _itemController = TextEditingController();
  final _priceController = TextEditingController();
  final _discountController = TextEditingController();
  final _paidController = TextEditingController();

  _DeviceOption? _selectedDevice;
  String? _error;
  TextEditingController? _autocompleteController;

  List<_DeviceOption> get _deviceOptions {
    final inventory = Get.find<InventoryController>();
    final options = <_DeviceOption>[
      for (final unit in inventory.sellableIphoneUnits)
        _DeviceOption(
          label: '${unit.model} • ${unit.storage} • ${unit.color}',
          salePrice: unit.salePrice,
          iphoneUnitId: unit.id,
        ),
      for (final product in inventory.sellableAndroidProducts)
        _DeviceOption(
          label: '${product.brand} ${product.model} • ${product.storage}',
          salePrice: product.salePrice,
          androidProductId: product.id,
        ),
    ];
    return options;
  }

  int get _price => int.tryParse(_priceController.text.trim()) ?? 0;
  int get _discount => int.tryParse(_discountController.text.trim()) ?? 0;
  int get _netPrice => (_price - _discount).clamp(0, _price < 0 ? 0 : _price);
  int get _paid => int.tryParse(_paidController.text.trim()) ?? 0;
  int get _balance => (_netPrice - _paid).clamp(0, _netPrice < 0 ? 0 : _netPrice);

  @override
  void dispose() {
    _customerController.dispose();
    _itemController.dispose();
    _priceController.dispose();
    _discountController.dispose();
    _paidController.dispose();
    super.dispose();
  }

  void _onDeviceSelected(_DeviceOption option) {
    setState(() {
      if (option.isCustom) {
        _selectedDevice = null;
        _itemController.clear();
        _priceController.clear();
      } else {
        _selectedDevice = option;
        _priceController.text = option.salePrice.toString();
      }
      // A new device means any discount typed for the previous one no
      // longer applies.
      _discountController.clear();
      // Default "Amount Paid" to the full (net) price — the cashier only
      // needs to change it when the customer is paying part now (Udhar for
      // the rest).
      _paidController.text = _netPrice.toString();
      _error = null;
    });
  }

  void _submit() {
    final itemDescription = _itemController.text.trim();
    if (itemDescription.isEmpty) {
      setState(() => _error = 'Select or describe what was sold');
      return;
    }
    if (_price <= 0) {
      setState(() => _error = 'Enter a valid price');
      return;
    }
    if (_discount < 0 || _discount > _price) {
      setState(() => _error = "Discount can't be negative or more than the price");
      return;
    }
    if (_paid < 0 || _paid > _netPrice) {
      setState(() => _error = "Amount paid can't be negative or more than the net price");
      return;
    }

    final receipt = Get.find<SalesController>().addSale(
      customerName: _customerController.text.trim(),
      itemDescription: itemDescription,
      price: _price,
      discount: _discount,
      amountPaid: _paid,
      soldIphoneUnitId: _selectedDevice?.iphoneUnitId,
      soldAndroidProductId: _selectedDevice?.androidProductId,
    );
    // Close this dialog first — showing the receipt while this is still the
    // top route would mean the next back-navigation closes the receipt
    // instead of this form.
    Get.back();
    showReceiptDialog(receipt);
  }

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.of(context).size;
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
      insetPadding: const EdgeInsets.all(AppSpacing.gutterLg),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: math.min(440, screen.width * 0.92),
          maxHeight: math.min(720, screen.height * 0.9),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.gutterLg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('New Sale', style: AppTypography.headlineMd),
              const SizedBox(height: AppSpacing.xs),
              const Text(
                'Pick what was sold, or use Custom Item for anything not in Inventory.',
                style: AppTypography.bodySm,
              ),
              const SizedBox(height: AppSpacing.lg),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _deviceField(),
                      const SizedBox(height: AppSpacing.md),
                      AppTextField(
                        controller: _customerController,
                        label: 'Customer name (optional)',
                        hint: 'Walk-in Customer',
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Row(
                        children: [
                          Expanded(
                            child: AppTextField(
                              controller: _priceController,
                              label: 'Price (Rs.)',
                              keyboardType: TextInputType.number,
                              onChanged: (_) => setState(() {
                                if (_paidController.text.isEmpty) _paidController.text = _netPrice.toString();
                              }),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: AppTextField(
                              controller: _discountController,
                              label: 'Discount (Rs.)',
                              hint: 'optional',
                              keyboardType: TextInputType.number,
                              onChanged: (_) => setState(() {
                                if (_paidController.text.isEmpty) _paidController.text = _netPrice.toString();
                              }),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      AppTextField(
                        controller: _paidController,
                        label: 'Amount Paid (Rs.)',
                        keyboardType: TextInputType.number,
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _balanceSummary(),
                    ],
                  ),
                ),
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
                  Expanded(child: AppButton(label: 'Complete Sale', onPressed: _submit)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _deviceField() {
    return Autocomplete<_DeviceOption>(
      displayStringForOption: (option) => option.label,
      optionsBuilder: (textEditingValue) {
        final query = textEditingValue.text.toLowerCase();
        final matches = _deviceOptions.where((o) => o.label.toLowerCase().contains(query));
        return [...matches, _customDeviceOption];
      },
      onSelected: _onDeviceSelected,
      fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
        // Keep the Autocomplete's own field in sync with _itemController so
        // a manually-typed custom description (after picking the sentinel)
        // is what actually gets saved. Guarded so the listener is attached
        // only once per controller instance, not on every rebuild.
        if (_autocompleteController != controller) {
          _autocompleteController = controller;
          controller.addListener(() {
            if (_itemController.text != controller.text) _itemController.text = controller.text;
          });
        }
        return TextField(
          controller: controller,
          focusNode: focusNode,
          decoration: const InputDecoration(labelText: 'What was sold', hintText: 'Search Inventory or pick Custom Item'),
        );
      },
      optionsViewBuilder: (context, onSelected, options) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(AppRadius.md),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 240, maxWidth: 380),
              child: ListView(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                children: [
                  for (final option in options)
                    ListTile(
                      dense: true,
                      title: Text(
                        option.label,
                        style: option.isCustom
                            ? AppTypography.bodyMd.copyWith(color: AppColors.primary, fontWeight: FontWeight.w700)
                            : AppTypography.bodyMd,
                      ),
                      trailing: option.isCustom ? null : CurrencyText(option.salePrice, style: AppTypography.bodySm),
                      onTap: () => onSelected(option),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _balanceSummary() {
    final isFullyPaid = _balance == 0;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isFullyPaid ? AppColors.successBg : AppColors.warningBg,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_discount > 0) ...[
            _summaryLine('Price', 'Rs. ${_moneyFormat.format(_price)}'),
            _summaryLine('Discount', '− Rs. ${_moneyFormat.format(_discount)}', color: AppColors.danger),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.xs),
              child: Divider(height: 1),
            ),
            _summaryLine('Net Price', 'Rs. ${_moneyFormat.format(_netPrice)}', bold: true),
            const SizedBox(height: AppSpacing.sm),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isFullyPaid ? 'Fully paid' : 'Balance due (added as Udhar)',
                style: AppTypography.labelLg.copyWith(color: isFullyPaid ? AppColors.success : AppColors.warning),
              ),
              CurrencyText(
                _balance,
                style: AppTypography.headlineSm.copyWith(color: isFullyPaid ? AppColors.success : AppColors.warning),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryLine(String label, String valueText, {bool bold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: bold ? AppTypography.labelLg.copyWith(color: color) : AppTypography.bodyMd.copyWith(color: color)),
          Text(
            valueText,
            style: (bold ? AppTypography.labelLg : AppTypography.bodyMd).copyWith(color: color, fontWeight: bold ? FontWeight.w700 : null),
          ),
        ],
      ),
    );
  }
}