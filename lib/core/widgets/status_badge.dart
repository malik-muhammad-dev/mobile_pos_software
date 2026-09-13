import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// Compliance status as stored in the DB (iphone_units.compliance_status).
enum ComplianceStatus { ptaApproved, nonPta, jv, mdm, factoryUnlocked }

extension ComplianceStatusX on ComplianceStatus {
  static ComplianceStatus fromDb(String value) {
    switch (value) {
      case 'pta_approved':
        return ComplianceStatus.ptaApproved;
      case 'non_pta':
        return ComplianceStatus.nonPta;
      case 'jv':
        return ComplianceStatus.jv;
      case 'mdm':
        return ComplianceStatus.mdm;
      case 'factory_unlocked':
        return ComplianceStatus.factoryUnlocked;
      default:
        throw ArgumentError('Unknown compliance status: $value');
    }
  }

  /// Plain-language label — no abbreviations, no jargon. This is the single
  /// most important piece of information in the app; it must read cleanly
  /// even at a glance.
  String get label {
    switch (this) {
      case ComplianceStatus.ptaApproved:
        return 'PTA Approved';
      case ComplianceStatus.nonPta:
        return 'Non-PTA';
      case ComplianceStatus.jv:
        return 'Carrier Locked (JV)';
      case ComplianceStatus.mdm:
        return 'MDM Locked';
      case ComplianceStatus.factoryUnlocked:
        return 'Factory Unlocked';
    }
  }

  Color get ink {
    switch (this) {
      case ComplianceStatus.ptaApproved:
        return AppColors.ptaApprovedInk;
      case ComplianceStatus.nonPta:
        return AppColors.nonPtaInk;
      case ComplianceStatus.jv:
        return AppColors.jvInk;
      case ComplianceStatus.mdm:
        return AppColors.mdmInk;
      case ComplianceStatus.factoryUnlocked:
        return AppColors.factoryUnlockedInk;
    }
  }

  Color get bg {
    switch (this) {
      case ComplianceStatus.ptaApproved:
        return AppColors.ptaApprovedBg;
      case ComplianceStatus.nonPta:
        return AppColors.nonPtaBg;
      case ComplianceStatus.jv:
        return AppColors.jvBg;
      case ComplianceStatus.mdm:
        return AppColors.mdmBg;
      case ComplianceStatus.factoryUnlocked:
        return AppColors.factoryUnlockedBg;
    }
  }

  IconData get icon {
    switch (this) {
      case ComplianceStatus.ptaApproved:
        return Icons.verified_outlined;
      case ComplianceStatus.nonPta:
        return Icons.error_outline;
      case ComplianceStatus.jv:
        return Icons.lock_outline;
      case ComplianceStatus.mdm:
        return Icons.shield_outlined;
      case ComplianceStatus.factoryUnlocked:
        return Icons.public;
    }
  }
}

/// Generic pill badge: color + icon + label together, never color alone —
/// this is what makes a status recognizable at a glance rather than read.
class StatusBadge extends StatelessWidget {
  const StatusBadge({
    super.key,
    required this.label,
    required this.ink,
    required this.bg,
    required this.icon,
  });

  final String label;
  final Color ink;
  final Color bg;
  final IconData icon;

  factory StatusBadge.compliance(ComplianceStatus status) => StatusBadge(
        label: status.label,
        ink: status.ink,
        bg: status.bg,
        icon: status.icon,
      );

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 28,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(AppRadius.full)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: ink),
          const SizedBox(width: 6),
          // Flexible + ellipsis: a badge sitting in a narrow table column
          // (e.g. Compliance, whose longest label is "FACTORY UNLOCKED")
          // must be able to shrink instead of overflowing the Row by a
          // few pixels when its parent gives it a tight width.
          Flexible(
            child: Text(
              label.toUpperCase(),
              style: AppTypography.labelSm.copyWith(color: ink),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }
}