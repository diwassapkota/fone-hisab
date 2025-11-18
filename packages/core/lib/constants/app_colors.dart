import 'package:flutter/material.dart';

/// App color palette based on Fonepay Khata Book design system
class AppColors {
  AppColors._();

  // Primary Color
  static const Color primary = Color(0xFFBE3431);
  static const Color primaryLight = Color(0xFFE85855);
  static const Color primaryDark = Color(0xFF8B2623);

  // Background Colors
  static const Color backgroundLight = Color(0xFFF7F8FA);
  static const Color backgroundDark = Color(0xFF121212);

  // Surface Colors
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF1E1E1E);

  // Text Colors
  static const Color textPrimaryLight = Color(0xFF1A202C);
  static const Color textPrimaryDark = Color(0xFFE2E8F0);
  static const Color textSecondaryLight = Color(0xFF718096);
  static const Color textSecondaryDark = Color(0xFFA0AEC0);

  // Status Colors
  static const Color success = Color(0xFF10B981);
  static const Color successLight = Color(0xFFD1FAE5);
  static const Color successDark = Color(0xFF065F46);

  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFFEE2E2);
  static const Color errorDark = Color(0xFF991B1B);

  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color warningDark = Color(0xFF92400E);

  static const Color info = Color(0xFF3B82F6);
  static const Color infoLight = Color(0xFFDBEAFE);
  static const Color infoDark = Color(0xFF1E3A8A);

  // Transaction Colors
  static const Color creditRed = Color(0xFFBE3431);
  static const Color creditRedLight = Color(0xFFFFEBEB);
  static const Color debitGreen = Color(0xFF10B981);
  static const Color debitGreenLight = Color(0xFFD1FAE5);
  static const Color advanceYellow = Color(0xFFF59E0B);
  static const Color advanceYellowLight = Color(0xFFFEF3C7);

  // Neutral Colors
  static const Color gray50 = Color(0xFFF9FAFB);
  static const Color gray100 = Color(0xFFF3F4F6);
  static const Color gray200 = Color(0xFFE5E7EB);
  static const Color gray300 = Color(0xFFD1D5DB);
  static const Color gray400 = Color(0xFF9CA3AF);
  static const Color gray500 = Color(0xFF6B7280);
  static const Color gray600 = Color(0xFF4B5563);
  static const Color gray700 = Color(0xFF374151);
  static const Color gray800 = Color(0xFF1F2937);
  static const Color gray900 = Color(0xFF111827);

  // Overlay Colors
  static Color overlay(BuildContext context, {double opacity = 0.5}) {
    return Colors.black.withValues(alpha: opacity);
  }

  // Shimmer Colors (for loading states)
  static const Color shimmerBase = Color(0xFFE0E0E0);
  static const Color shimmerHighlight = Color(0xFFF5F5F5);
}
