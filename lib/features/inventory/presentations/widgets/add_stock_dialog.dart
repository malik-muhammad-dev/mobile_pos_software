import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/status_badge.dart';
import '../controllers/inventory_controller.dart';
import 'inventory_tab_switcher.dart';

const List<String> _iphoneConditions = ['New', 'Used — Excellent', 'Used — Good', 'Used — Fair'];
const List<String> _androidConditions = ['New', 'Used'];

/// Shown at the end of the iPhone model search results — picking it clears
/// the field so the shop can type a model that isn't on the standard list.
const String _customModelSentinel = 'Custom / Not Listed…';

/// Quick "add stock" form — demo-grade for now: it only appends to the
/// in-memory sample lists (via InventoryController), there's no real
/// database write yet. Good enough to show a client the flow works end to
/// end before the real iphone_units / android_products tables are wired in.
class AddStockDialog extends StatefulWidget {
  const AddStockDialog({super.key, required this.initialTab});

  final InventoryTab initialTab;

  @override
  State<AddStockDialog> createState() => _AddStockDialogState();
}

class _AddStockDialogState extends State<AddStockDialog> {
  late InventoryTab _tab = widget.initialTab;

  // iPhone fields
  final _modelController = TextEditingController();
  final _storageController = TextEditingController();
  final _colorController = TextEditingController();
  final _imeiController = TextEditingController();
  final _batteryController = TextEditingController(text: '100');
  final _costPriceController = TextEditingController();
  final _salePriceController = TextEditingController();
  String _condition = _iphoneConditions.first;
  ComplianceStatus _compliance = ComplianceStatus.ptaApproved;

  // Android fields
  final _brandController = TextEditingController();
  final _ramController = TextEditingController();
  final _quantityController = TextEditingController(text: '1');

  String? _error;
  TextEditingController? _autocompleteModelController;

  @override
  void dispose() {
    _modelController.dispose();
    _storageController.dispose();
    _colorController.dispose();
    _imeiController.dispose();
    _batteryController.dispose();
    _costPriceController.dispose();
    _salePriceController.dispose();
    _brandController.dispose();
    _ramController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  void _submit() {
    final costPrice = int.tryParse(_costPriceController.text.trim());
    final salePrice = int.tryParse(_salePriceController.text.trim());
    if (_modelController.text.trim().isEmpty) {
      setState(() => _error = 'Model is required');
      return;
    }
    if (costPrice == null || costPrice <= 0) {
      setState(() => _error = 'Enter a valid cost price (what you paid for it)');
      return;
    }
    if (salePrice == null || salePrice <= 0) {
      setState(() => _error = "Enter a valid sale price (what you'll charge)");
      return;
    }

    final controller = Get.find<InventoryController>();

    if (_tab == InventoryTab.iphone) {
      if (_imeiController.text.trim().length != 15) {
        setState(() => _error = 'IMEI must be 15 digits');
        return;
      }
      controller.addIphoneUnit(
        model: _modelController.text.trim(),
        storage: _storageController.text.trim().isEmpty ? '—' : _storageController.text.trim(),
        color: _colorController.text.trim().isEmpty ? '—' : _colorController.text.trim(),
        condition: _condition,
        imei: _imeiController.text.trim(),
        compliance: _compliance,
        batteryHealth: int.tryParse(_batteryController.text.trim()) ?? 100,
        costPrice: costPrice,
        salePrice: salePrice,
      );
    } else {
      final quantity = int.tryParse(_quantityController.text.trim());
      if (quantity == null || quantity <= 0) {
        setState(() => _error = 'Enter a valid quantity');
        return;
      }
      controller.addAndroidProduct(
        brand: _brandController.text.trim().isEmpty ? '—' : _brandController.text.trim(),
        model: _modelController.text.trim(),
        storage: _storageController.text.trim().isEmpty ? '—' : _storageController.text.trim(),
        ram: _ramController.text.trim().isEmpty ? '—' : _ramController.text.trim(),
        color: _colorController.text.trim().isEmpty ? '—' : _colorController.text.trim(),
        condition: _condition,
        quantity: quantity,
        costPrice: costPrice,
        salePrice: salePrice,
      );
    }

    Get.back();
    Get.snackbar('Stock added', 'Added to your inventory list.', snackPosition: SnackPosition.BOTTOM);
  }

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.of(context).size;
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
      insetPadding: const EdgeInsets.all(AppSpacing.gutterLg),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: math.min(460, screen.width * 0.92),
          maxHeight: math.min(640, screen.height * 0.88),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.gutterLg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Add Stock', style: AppTypography.headlineMd),
              const SizedBox(height: AppSpacing.xs),
              const Text(
                'For the demo this just adds a sample row — real intake comes once the database is wired up.',
                style: AppTypography.bodySm,
              ),
              const SizedBox(height: AppSpacing.lg),
              InventoryTabSwitcher(
                selected: _tab,
                onChanged: (tab) => setState(() {
                  _tab = tab;
                  // Condition options differ per tab (iPhone has 4, Android
                  // has 2) — reset so the dropdown's value is never left
                  // pointing at an option the other tab doesn't have.
                  _condition = (tab == InventoryTab.iphone ? _iphoneConditions : _androidConditions).first;
                }),
              ),
              const SizedBox(height: AppSpacing.lg),
              Expanded(
                child: SingleChildScrollView(
                  child: _tab == InventoryTab.iphone ? _iphoneFields() : _androidFields(),
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
                  Expanded(child: AppButton(label: 'Add Stock', onPressed: _submit)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _iphoneFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _iphoneModelField(),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(child: AppTextField(controller: _storageController, label: 'Storage', hint: '128GB')),
            const SizedBox(width: AppSpacing.md),
            Expanded(child: AppTextField(controller: _colorController, label: 'Color', hint: 'Graphite')),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        _dropdown(
          label: 'Condition',
          value: _condition,
          items: _iphoneConditions,
          onChanged: (v) => setState(() => _condition = v!),
        ),
        const SizedBox(height: AppSpacing.md),
        AppTextField(
          controller: _imeiController,
          label: 'IMEI (15 digits)',
          hint: '356938035643809',
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: AppSpacing.md),
        _complianceDropdown(),
        const SizedBox(height: AppSpacing.md),
        AppTextField(
          controller: _batteryController,
          label: 'Battery Health (%)',
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: AppSpacing.md),
        _priceFields(costHint: 'e.g. 162000', saleHint: 'e.g. 185000'),
      ],
    );
  }

  Widget _androidFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: AppTextField(controller: _brandController, label: 'Brand', hint: 'Samsung')),
            const SizedBox(width: AppSpacing.md),
            Expanded(child: AppTextField(controller: _modelController, label: 'Model', hint: 'Galaxy S23')),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(child: AppTextField(controller: _storageController, label: 'Storage', hint: '128GB')),
            const SizedBox(width: AppSpacing.md),
            Expanded(child: AppTextField(controller: _ramController, label: 'RAM', hint: '8GB')),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(child: AppTextField(controller: _colorController, label: 'Color', hint: 'Black')),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _dropdown(
                label: 'Condition',
                value: _condition,
                items: _androidConditions,
                onChanged: (v) => setState(() => _condition = v!),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        AppTextField(controller: _quantityController, label: 'Quantity', keyboardType: TextInputType.number),
        const SizedBox(height: AppSpacing.md),
        _priceFields(costHint: 'e.g. 35000', saleHint: 'e.g. 40000'),
      ],
    );
  }

  /// Cost Price (what the shop paid) and Sale Price (what's charged at the
  /// counter) side by side — every phone shop margin lives in the gap
  /// between the two, so both are tracked from the moment stock comes in.
  Widget _priceFields({required String costHint, required String saleHint}) {
    return Row(
      children: [
        Expanded(
          child: AppTextField(
            controller: _costPriceController,
            label: 'Cost Price (Rs.)',
            hint: costHint,
            keyboardType: TextInputType.number,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: AppTextField(
            controller: _salePriceController,
            label: 'Sale Price (Rs.)',
            hint: saleHint,
            keyboardType: TextInputType.number,
          ),
        ),
      ],
    );
  }

  /// Model field for the iPhone tab: search the standard model list, or
  /// pick "Custom / Not Listed…" to clear the field and type anything —
  /// matches Android's already-free-text Model field for the cases a
  /// standard iPhone name doesn't fit (an old model, a regional variant).
  Widget _iphoneModelField() {
    return Autocomplete<String>(
      initialValue: TextEditingValue(text: _modelController.text),
      optionsBuilder: (textEditingValue) {
        final query = textEditingValue.text.toLowerCase();
        final matches = standardIphoneModels.where((m) => m.toLowerCase().contains(query));
        return [...matches, _customModelSentinel];
      },
      onSelected: (selection) {
        if (selection == _customModelSentinel) {
          _modelController.clear();
        } else {
          _modelController.text = selection;
        }
      },
      fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
        // Autocomplete manages its own controller (passing textEditingController
        // directly requires a matching focusNode too, which fieldViewBuilder
        // doesn't give us) — so mirror it into _modelController instead,
        // guarded to attach the listener only once per controller instance.
        if (_autocompleteModelController != controller) {
          _autocompleteModelController = controller;
          controller.addListener(() {
            if (_modelController.text != controller.text) _modelController.text = controller.text;
          });
        }
        return TextField(
          controller: controller,
          focusNode: focusNode,
          decoration: const InputDecoration(labelText: 'Model', hintText: 'Search or type a model'),
        );
      },
      optionsViewBuilder: (context, onSelected, options) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(AppRadius.md),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 220, maxWidth: 380),
              child: ListView(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                children: [
                  for (final option in options)
                    ListTile(
                      dense: true,
                      title: Text(
                        option,
                        style: option == _customModelSentinel
                            ? AppTypography.bodyMd.copyWith(color: AppColors.primary, fontWeight: FontWeight.w700)
                            : AppTypography.bodyMd,
                      ),
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

  Widget _dropdown({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      decoration: InputDecoration(labelText: label),
      items: [for (final item in items) DropdownMenuItem(value: item, child: Text(item))],
      onChanged: onChanged,
    );
  }

  Widget _complianceDropdown() {
    return DropdownButtonFormField<ComplianceStatus>(
      initialValue: _compliance,
      decoration: const InputDecoration(labelText: 'Compliance'),
      items: [
        for (final status in ComplianceStatus.values)
          DropdownMenuItem(value: status, child: Text(status.label)),
      ],
      onChanged: (v) => setState(() => _compliance = v!),
    );
  }
}