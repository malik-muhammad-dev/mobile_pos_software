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
  final _priceController = TextEditingController();
  String _condition = _iphoneConditions.first;
  ComplianceStatus _compliance = ComplianceStatus.ptaApproved;

  // Android fields
  final _brandController = TextEditingController();
  final _ramController = TextEditingController();
  final _quantityController = TextEditingController(text: '1');

  String? _error;

  @override
  void dispose() {
    _modelController.dispose();
    _storageController.dispose();
    _colorController.dispose();
    _imeiController.dispose();
    _batteryController.dispose();
    _priceController.dispose();
    _brandController.dispose();
    _ramController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  void _submit() {
    final price = int.tryParse(_priceController.text.trim());
    if (_modelController.text.trim().isEmpty) {
      setState(() => _error = 'Model is required');
      return;
    }
    if (price == null || price <= 0) {
      setState(() => _error = 'Enter a valid price');
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
        price: price,
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
        price: price,
      );
    }

    Get.back();
    Get.snackbar('Stock added', 'Added to your inventory list.', snackPosition: SnackPosition.BOTTOM);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460, maxHeight: 640),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.gutterLg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Add Stock', style: AppTypography.headlineMd),
              const SizedBox(height: AppSpacing.xs),
              const Text(
                'For the demo this just adds a sample row — real intake comes once the database is wired up.',
                style: AppTypography.bodySm,
              ),
              const SizedBox(height: AppSpacing.lg),
              InventoryTabSwitcher(selected: _tab, onChanged: (tab) => setState(() => _tab = tab)),
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
        AppTextField(controller: _modelController, label: 'Model', hint: 'e.g. iPhone 13 Pro'),
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
        Row(
          children: [
            Expanded(
              child: AppTextField(
                controller: _batteryController,
                label: 'Battery Health (%)',
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: AppTextField(
                controller: _priceController,
                label: 'Price (Rs.)',
                hint: 'e.g. 185000',
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
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
        Row(
          children: [
            Expanded(
              child: AppTextField(controller: _quantityController, label: 'Quantity', keyboardType: TextInputType.number),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: AppTextField(
                controller: _priceController,
                label: 'Price (Rs.)',
                hint: 'e.g. 42000',
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _dropdown({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(labelText: label),
      items: [for (final item in items) DropdownMenuItem(value: item, child: Text(item))],
      onChanged: onChanged,
    );
  }

  Widget _complianceDropdown() {
    return DropdownButtonFormField<ComplianceStatus>(
      value: _compliance,
      decoration: const InputDecoration(labelText: 'Compliance'),
      items: [
        for (final status in ComplianceStatus.values)
          DropdownMenuItem(value: status, child: Text(status.label)),
      ],
      onChanged: (v) => setState(() => _compliance = v!),
    );
  }
}