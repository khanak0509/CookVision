import 'package:flutter/material.dart';

class AppColors {
  // Enhanced Light Theme Colors - More vibrant and premium
  static const lightPrimary = Color(0xFF6366F1); // Vibrant Indigo
  static const lightPrimaryVariant = Color(0xFF4F46E5);
  static const lightSecondary = Color(0xFFFF6B9D); // Vibrant Pink (enhanced)
  static const lightSecondaryVariant = Color(0xFFF02D77);
  static const lightAccent = Color(0xFFFFB800); // Gold accent (new)
  
  static const lightBackground = Color(0xFFF8FAFC);
  static const lightSurface = Color(0xFFFFFFFF);
  static const lightSurfaceVariant = Color(0xFFF1F5F9);
  
  static const lightOnPrimary = Color(0xFFFFFFFF);
  static const lightOnSecondary = Color(0xFFFFFFFF);
  static const lightOnBackground = Color(0xFF1E293B);
  static const lightOnSurface = Color(0xFF1E293B);
  
  static const lightTextPrimary = Color(0xFF0F172A);
  static const lightTextSecondary = Color(0xFF64748B);
  static const lightTextTertiary = Color(0xFF94A3B8);
  
  static const lightDivider = Color(0xFFE2E8F0);
  static const lightBorder = Color(0xFFCBD5E1);
  
  // Enhanced Dark Theme Colors - Better contrast and vibrancy
  static const darkPrimary = Color(0xFF818CF8); // Lighter indigo for dark mode
  static const darkPrimaryVariant = Color(0xFF6366F1);
  static const darkSecondary = Color(0xFFFF8AB6); // Lighter pink for dark mode (enhanced)
  static const darkSecondaryVariant = Color(0xFFFF6B9D);
  static const darkAccent = Color(0xFFFFC933); // Brighter gold for dark mode (new)
  
  static const darkBackground = Color(0xFF0F172A);
  static const darkSurface = Color(0xFF1E293B);
  static const darkSurfaceVariant = Color(0xFF334155);
  
  static const darkOnPrimary = Color(0xFF0F172A);
  static const darkOnSecondary = Color(0xFF0F172A);
  static const darkOnBackground = Color(0xFFF1F5F9);
  static const darkOnSurface = Color(0xFFF1F5F9);
  
  static const darkTextPrimary = Color(0xFFF8FAFC);
  static const darkTextSecondary = Color(0xFFCBD5E1);
  static const darkTextTertiary = Color(0xFF94A3B8);
  
  static const darkDivider = Color(0xFF334155);
  static const darkBorder = Color(0xFF475569);
  
  // Enhanced Semantic Colors
  static const success = Color(0xFF10B981);
  static const successLight = Color(0xFFD1FAE5);
  static const successDark = Color(0xFF059669);
  
  static const error = Color(0xFFEF4444);
  static const errorLight = Color(0xFFFEE2E2);
  static const errorDark = Color(0xFFDC2626);
  
  static const warning = Color(0xFFF59E0B);
  static const warningLight = Color(0xFFFEF3C7);
  static const warningDark = Color(0xFFD97706);
  
  static const info = Color(0xFF3B82F6);
  static const infoLight = Color(0xFFDBEAFE);
  static const infoDark = Color(0xFF2563EB);
  
  // Enhanced Gradients - More vibrant
  static const lightPrimaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6), Color(0xFFA855F7)],
  );
  
  static const darkPrimaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF818CF8), Color(0xFFA78BFA), Color(0xFFC084FC)],
  );
  
  static const accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFF6B9D), Color(0xFFFF8AB6), Color(0xFFFFA8CC)],
  );
  
  static const foodGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF59E0B), Color(0xFFF97316), Color(0xFFFFB800)],
  );
  
  static const successGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF10B981), Color(0xFF34D399), Color(0xFF6EE7B7)],
  );
  
  // New vibrant gradients
  static const tropicalGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF06B6D4), Color(0xFF3B82F6), Color(0xFF8B5CF6)],
  );
  
  static const sunsetGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFB923C), Color(0xFFF97316), Color(0xFFEF4444)],
  );
  
  // Overlay Gradients
  static final imageOverlayGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Colors.transparent,
      Colors.black.withOpacity(0.7),
    ],
  );
  
  // Shadow Colors
  static final lightShadow = Colors.black.withOpacity(0.08);
  static final darkShadow = Colors.black.withOpacity(0.3);
  
  // Shimmer colors for loading states
  static const lightShimmerBase = Color(0xFFE2E8F0);
  static const lightShimmerHighlight = Color(0xFFF8FAFC);
  static const darkShimmerBase = Color(0xFF334155);
  static const darkShimmerHighlight = Color(0xFF475569);
}
