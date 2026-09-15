import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../auth/presentation/widgets/auth_brand_panel.dart';
import '../../../auth/presentation/widgets/auth_shell.dart';
import '../controllers/shop_account_controller.dart';

/// The very first screen a brand-new install shows, before Setup Wizard —
/// register a new shop, or reactivate one that's already registered (the
/// reinstall / new-machine path).
class ShopAccountScreen extends StatelessWidget {
  const ShopAccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ShopAccountController());

    return Obx(() {
      const brand = AuthBrandPanel(title: 'Mobile Shop POS', subtitle: 'Point of Sale');
      final isNew = controller.mode.value == ShopAccountMode.newShop;

      return AuthShell(
        brand: brand,
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(isNew ? 'Register Your Shop' : 'Welcome Back', style: AppTypography.headlineLg),
            const SizedBox(height: AppSpacing.xs),
            Text(
              isNew
                  ? 'Setting this shop up for the first time.'
                  : 'Reinstalling on this machine? Log back into your shop account.',
              style: AppTypography.bodyMd,
            ),
            const SizedBox(height: AppSpacing.lg),
            _ModeSwitcher(
              isNew: isNew,
              onChanged: (value) =>
                  controller.setMode(value ? ShopAccountMode.newShop : ShopAccountMode.existingShop),
            ),
            const SizedBox(height: AppSpacing.lg),
            if (isNew) _NewShopForm(controller: controller) else _ExistingShopForm(controller: controller),
          ],
        ),
      );
    });
  }
}

class _ModeSwitcher extends StatelessWidget {
  const _ModeSwitcher({required this.isNew, required this.onChanged});

  final bool isNew;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _ModeTab(label: 'New Shop', selected: isNew, onTap: () => onChanged(true))),
        const SizedBox(width: AppSpacing.sm),
        Expanded(child: _ModeTab(label: 'Existing Shop', selected: !isNew, onTap: () => onChanged(false))),
      ],
    );
  }
}

class _ModeTab extends StatelessWidget {
  const _ModeTab({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? AppColors.primary.withValues(alpha: 0.08) : null,
          border: Border.all(color: selected ? AppColors.primary : AppColors.borderDefault),
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Text(
          label,
          style: AppTypography.labelLg.copyWith(color: selected ? AppColors.primary : AppColors.textSecondary),
        ),
      ),
    );
  }
}

class _NewShopForm extends StatelessWidget {
  const _NewShopForm({required this.controller});

  final ShopAccountController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppTextField(controller: controller.shopNameController, label: 'Shop name', hint: 'e.g. Al-Karam Mobiles'),
        const SizedBox(height: AppSpacing.md),
        AppTextField(controller: controller.phoneController, label: 'Phone number', hint: 'e.g. 0300-1234567'),
        const SizedBox(height: AppSpacing.md),
        AppTextField(
          controller: controller.newEmailController,
          label: 'Email',
          hint: "you'll use this to log back in later",
        ),
        const SizedBox(height: AppSpacing.md),
        AppTextField(controller: controller.newPasswordController, label: 'Password', obscureText: true),
        const SizedBox(height: AppSpacing.md),
        AppTextField(
          controller: controller.confirmPasswordController,
          label: 'Confirm password',
          obscureText: true,
        ),
        const SizedBox(height: AppSpacing.lg),
        Obx(
          () => AppButton(
            label: controller.isSubmitting.value ? 'Registering...' : 'Register Shop',
            onPressed: controller.isSubmitting.value ? null : controller.submitNewShop,
          ),
        ),
      ],
    );
  }
}

class _ExistingShopForm extends StatelessWidget {
  const _ExistingShopForm({required this.controller});

  final ShopAccountController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppTextField(controller: controller.existingEmailController, label: 'Email'),
        const SizedBox(height: AppSpacing.md),
        AppTextField(controller: controller.existingPasswordController, label: 'Password', obscureText: true),
        const SizedBox(height: AppSpacing.lg),
        Obx(
          () => AppButton(
            label: controller.isSubmitting.value ? 'Logging in...' : 'Log In',
            onPressed: controller.isSubmitting.value ? null : controller.submitExistingShop,
          ),
        ),
      ],
    );
  }
}