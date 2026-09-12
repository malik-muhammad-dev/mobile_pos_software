import 'package:flutter/material.dart';

/// Design tokens carried over from the approved Stitch design system
/// ("Retail POS Clarity"). Visual language only — do not put copy/labels
/// here, those get simplified separately per screen.
class AppColors {
  AppColors._();

  // Core surfaces
  static const Color canvas = Color(0xFFF8FAFC);
  static const Color surfaceCard = Color(0xFFFFFFFF);
  static const Color borderDefault = Color(0xFFE2E8F0);
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF434655);
  static const Color textMuted = Color(0xFF747686);

  // Brand
  static const Color primary = Color(0xFF1D4ED8);
  static const Color onPrimary = Color(0xFFFFFFFF);

  // Semantic feedback
  static const Color danger = Color(0xFFBA1A1A);
  static const Color dangerBg = Color(0xFFFFF1F2);
  static const Color warning = Color(0xFFD97706);
  static const Color warningBg = Color(0xFFFFFBEB);
  static const Color success = Color(0xFF059669);
  static const Color successBg = Color(0xFFECFDF5);

  /// Compliance status palette — every badge pairs an ink color with a
  /// soft tint background. Recognition-over-reading: color + icon + label,
  /// never color alone.
  static const Color ptaApprovedInk = Color(0xFF059669);
  static const Color ptaApprovedBg = Color(0xFFECFDF5);
  static const Color nonPtaInk = Color(0xFFD97706);
  static const Color nonPtaBg = Color(0xFFFFFBEB);
  static const Color jvInk = Color(0xFF4F46E5);
  static const Color jvBg = Color(0xFFEEF2FF);
  static const Color mdmInk = Color(0xFFE11D48);
  static const Color mdmBg = Color(0xFFFFF1F2);
  static const Color factoryUnlockedInk = Color(0xFF0891B2);
  static const Color factoryUnlockedBg = Color(0xFFECFEFF);

  /// Unit stock status
  static const Color inStock = Color(0xFF059669);
  static const Color reserved = Color(0xFFD97706);
  static const Color sold = Color(0xFF64748B);

  /// Payment status
  static const Color paid = Color(0xFF059669);
  static const Color pending = Color(0xFFD97706);
  static const Color partial = Color(0xFF4F46E5);
}