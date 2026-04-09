import 'package:flutter/material.dart';

abstract class AppColors {
  // Brand
  static const Color primary = Color(0xFF6C63FF);
  static const Color primaryDark = Color(0xFF4B44D6);
  static const Color secondary = Color(0xFFFF6B6B);
  static const Color accent = Color(0xFFFFD93D);

  // Background
  static const Color background = Color(0xFF1A1A2E);
  static const Color surface = Color(0xFF16213E);
  static const Color surfaceVariant = Color(0xFF0F3460);

  // Text
  static const Color onBackground = Color(0xFFF5F5F5);
  static const Color onSurface = Color(0xFFE0E0E0);
  static const Color onSurfaceMuted = Color(0xFF9E9E9E);

  // Game tiles
  static const Color tileDefault = Color(0xFF1E3A5F);
  static const Color tileSelected = Color(0xFF6C63FF);
  static const Color tileOpponent = Color(0xFFFF6B6B);
  static const Color tileUsed = Color(0xFF2E4A6F);

  // Status
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFEF5350);
  static const Color warning = Color(0xFFFF9800);

  // Timer
  static const Color timerTrack = Color(0xFF2A2A4A);
  static const Color timerNormal = Color(0xFF6C63FF);
  static const Color timerWarning = Color(0xFFFFD93D);
  static const Color timerDanger = Color(0xFFFF6B6B);

  // Bet options
  static const Color betFast = Color(0xFFFF6B6B);
  static const Color betNormal = Color(0xFF6C63FF);
  static const Color betSlow = Color(0xFF4CAF50);
}
