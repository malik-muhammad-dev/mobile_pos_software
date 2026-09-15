import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/services/backup_service.dart';
import '../controllers/settings_controller.dart';

/// Last-backup summary, a Backup Now button, and recent backup history.
/// Mirrors backups_log (created_at, type, size_bytes) — restoring isn't
/// part of this pass, just visibility into what's there so an owner trusts
/// backups are actually happening before that's built.
class BackupRestoreCard extends StatelessWidget {
  const BackupRestoreCard({super.key, required this.controller});

  final SettingsController controller;

  @override
  Widget build(BuildContext context) {
    // Reads its own RxList/getter here, inside its own Obx, rather than
    // trusting a caller's Obx to catch it — a value read while merely
    // constructing this widget (e.g. `Obx(() => BackupRestoreCard(...))`)
    // never actually touches `controller.backups`, so nothing would
    // register as a dependency and Backup Now wouldn't refresh this card.
    return Obx(() {
      final lastBackupAt = controller.lastBackup?.createdAt;
      final recentBackups = controller.backups.take(5).toList();

      return AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Backup & Restore', style: AppTypography.headlineMd),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        lastBackupAt == null
                            ? 'No backups yet.'
                            : 'Last backup: ${DateFormat('MMM d, h:mm a').format(lastBackupAt)}',
                        style: AppTypography.bodyMd,
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 140,
                  child: AppButton(label: 'Backup Now', icon: Icons.backup_outlined, onPressed: controller.backupNow),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            const Divider(height: 1, color: AppColors.borderDefault),
            const SizedBox(height: AppSpacing.md),
            if (recentBackups.isEmpty)
              const Text('Nothing backed up yet.', style: AppTypography.bodyMd)
            else
              for (final backup in recentBackups) ...[
                _backupRow(backup),
                if (backup != recentBackups.last) const SizedBox(height: AppSpacing.sm),
              ],
          ],
        ),
      );
    });
  }

  Widget _backupRow(BackupRecord backup) {
    final isAuto = backup.type == 'auto';
    return Row(
      children: [
        Icon(
          isAuto ? Icons.schedule_outlined : Icons.touch_app_outlined,
          size: 16,
          color: AppColors.textMuted,
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(DateFormat('MMM d, yyyy — h:mm a').format(backup.createdAt), style: AppTypography.bodyMd),
        ),
        Text(isAuto ? 'Automatic' : 'Manual', style: AppTypography.bodySm),
        const SizedBox(width: AppSpacing.md),
        SizedBox(
          width: 64,
          child: Text(_formatSize(backup.sizeBytes), style: AppTypography.bodySm, textAlign: TextAlign.right),
        ),
      ],
    );
  }

  String _formatSize(int bytes) => '${(bytes / 1024).round()} KB';
}