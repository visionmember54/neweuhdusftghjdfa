import 'package:flutter/material.dart';

class AppColors {
  // --- Primary Brand Palette: Luxury Emerald & Teal ---
  static const Color emeraldDarkest = Color(0xFF002821); // Deep luxury backdrop
  static const Color emeraldDark = Color(0xFF00382E);    // Rich forest emerald
  static const Color emeraldDeep = Color(0xFF004D40);    // Heritage dark teal
  static const Color emerald = Color(0xFF005A4C);        // Signature brand emerald teal
  static const Color emeraldMedium = Color(0xFF006D5B);  // Rich mid teal
  static const Color emeraldLight = Color(0xFF00897B);   // Vibrant emerald teal
  static const Color emeraldAccent = Color(0xFF00B49F);  // High-contrast mint highlight
  static const Color emeraldSurface = Color(0xFFE6F4F1); // Soft theme card/badge tint
  static const Color emeraldTint = Color(0xFFF0FAF8);    // Ultra-soft wash

  // Backward-compatible primary aliases
  static const Color teal = Color(0xFF005A4C);
  static const Color tealDark = Color(0xFF00382E);
  static const Color tealLight = Color(0xFF00897B);

  // --- Luxury Metallic Gold & Warm Amber Accents ---
  static const Color gold = Color(0xFFD4AF37);           // Classic metallic gold
  static const Color goldLight = Color(0xFFE2B755);      // Champagne gold highlight
  static const Color goldDark = Color(0xFFB45309);       // Deep warm amber
  static const Color goldSurface = Color(0xFFFEF3C7);    // Soft gold tint for badges
  static const Color goldBorder = Color(0xFFFDE68A);     // Subtle gold outline

  // Card game theme colors (retained for compatibility)
  static const Color cardRed = Color(0xFFB22222);
  static const Color cardBlack = Color(0xFF1C1C1C);
  static const Color cardGold = Color(0xFFD4AF37);
  static const Color cardGreen = Color(0xFF228B22);

  // --- Surfaces & Neutral Hierarchy ---
  static const Color canvasBackground = Color(0xFFF4F7F6); // Clean, calm luxury off-white
  static const Color cardSurface = Color(0xFFFFFFFF);      // Crisp pure white cards
  static const Color surfaceMuted = Color(0xFFF8FAFC);     // Slate soft background
  static const Color borderSubtle = Color(0xFFE2E8F0);     // Delicate divider & outline
  static const Color borderMedium = Color(0xFFCBD5E1);     // Active border
  static const Color borderTeal = Color(0xFFB2DFDB);       // Subtle teal outline

  // --- Typography Colors ---
  static const Color textPrimary = Color(0xFF0F241F);       // Deepest forest charcoal
  static const Color textSecondary = Color(0xFF33534B);     // Refined slate teal
  static const Color textMuted = Color(0xFF809893);         // Muted secondary label
  static const Color textSlate = Color(0xFF475569);         // Cool neutral slate
  static const Color textSlateMuted = Color(0xFF94A3B8);    // Subtle slate hint

  // Common colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);

  // Background
  static const Color splashBackground = emerald;
  static const Color circleBackground = white;
}
