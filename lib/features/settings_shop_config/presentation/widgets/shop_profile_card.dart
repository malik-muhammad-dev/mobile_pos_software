import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../controllers/settings_controller.dart';

/// Shop name, address, and low-stock threshold — the fields the desktop
/// app itself needs day to day, not a general "business info" page. Local
/// controllers seeded from SettingsController's current values, matching
/// the same edit-then-Save pattern as Add Stock / Record Payment, rather
/// than writing on every keystroke.
class ShopProfileCard extends StatefulWidget {
  const ShopProfileCard({super.key});

  @override
  State<ShopProfileCard> createState() => _ShopProfileCardState();
}

class _ShopProfileCardState extends State<ShopProfileCard> {
  late final _controller = Get.find<SettingsController>();
  late final _nameController = TextEditingController(text: _controller.shopName.value);
  late final _addressController = TextEditingController(text: _controller.address.value);
  late final _thresholdController = TextEditingController(text: '${_controller.lowStockThreshold.value}');
  // Fixed — this build only supports PKR, no other currency is planned,
  // so this field is shown disabled rather than left editable.
  final _currencyController = TextEditingController(text: 'PKR (Rs.)');
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _thresholdController.dispose();
    _currencyController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_nameController.text.trim().isEmpty) {
      setState(() => _error = 'Shop name is required');
      return;
    }
    final threshold = int.tryParse(_thresholdController.text.trim());
    if (threshold == null || threshold <= 0) {
      setState(() => _error = 'Low stock threshold must be a positive number');
      return;
    }

    setState(() => _error = null);
    // The success snackbar lives in the controller (only fires once the
    // real save actually succeeds); a failure surfaces its own message via
    // safeSubmit, so nothing else to show here either way.
    await _controller.saveShopProfile(
      name: _nameController.text.trim(),
      shopAddress: _addressController.text.trim(),
      threshold: threshold,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Shop Profile', style: AppTypography.headlineMd),
          const SizedBox(height: AppSpacing.xs),
          const Text(
            'Shown on receipts and used across the app.',
            style: AppTypography.bodySm,
          ),
          const SizedBox(height: AppSpacing.lg),
          AppTextField(controller: _nameController, label: 'Shop name', hint: 'e.g. Al-Karam Mobiles'),
          const SizedBox(height: AppSpacing.md),
          AppTextField(controller: _addressController, label: 'Address', hint: 'e.g. Commercial Market, Mianwali'),
          const SizedBox(height: AppSpacing.md),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: AppTextField(
                  controller: _thresholdController,
                  label: 'Low stock threshold',
                  hint: 'e.g. 3',
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: AppTextField(controller: _currencyController, label: 'Currency', enabled: false),
              ),
            ],
          ),
          if (_error != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(_error!, style: AppTypography.bodySm.copyWith(color: AppColors.danger)),
          ],
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            width: 160,
            child: AppButton(label: 'Save', onPressed: _save),
          ),
        ],
      ),
    );
  }
}