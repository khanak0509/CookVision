import 'package:flutter/material.dart';

class AppColors {
  // ============================================================
  // 🍊 FOOD-FRIENDLY LIGHT  // Soft gradients for cards
  static const lightCardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFFFFF), Color(0xFFF8FAFC)],
  );
  
  static const darkCardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1E293B), Color(0xFF334155), Color(0xFF3730A3)],
  );
  
  // Dark mode card with blue glow
  static const darkCardGradientBlue = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1E293B), Color(0xFF312E81), Color(0xFF4338CA)],
  );
  
  // Dark mode card with purple glow
  static const darkCardGradientPurple = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1E293B), Color(0xFF581C87), Color(0xFF7E22CE)],
  );
  
  // Food-specific gradient
  static const foodGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6), Color(0xFF06B6D4)],
  );
  
  // Image overlay gradient
  static const imageOverlayGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Colors.transparent,
      Color(0x99000000),
    ],
  );
  
  // ============================================================
  // 💫 SHADOWS - Elevation system
  // ============================================================
  
  // Primary: Cool Blue/Indigo - modern and professional
  static const lightPrimary = Color(0xFF6366F1); // Indigo blue
  static const lightPrimaryVariant = Color(0xFF818CF8);
  static const lightPrimaryDark = Color(0xFF4F46E5);
  
  // Secondary: Vibrant Purple - creative and energetic
  static const lightSecondary = Color(0xFF8B5CF6); // Purple
  static const lightSecondaryVariant = Color(0xFFA78BFA);
  
  // Accent: Electric Cyan - fresh and modern
  static const lightAccent = Color(0xFF06B6D4); // Cyan
  static const lightAccentVariant = Color(0xFF22D3EE);
  
  // Surfaces & Backgrounds - Soft, cool tones
  static const lightBackground = Color(0xFFF8FAFC); // Very light blue-gray
  static const lightSurface = Color(0xFFFFFFFF); // Pure white for cards
  static const lightSurfaceVariant = Color(0xFFF1F5F9); // Light slate
  static const lightSurfaceElevated = Color(0xFFFFFFFF);
  
  // Text Colors
  static const lightTextPrimary = Color(0xFF1F2937); // Rich dark gray
  static const lightTextSecondary = Color(0xFF6B7280); // Medium gray
  static const lightTextTertiary = Color(0xFF9CA3AF); // Light gray
  static const lightTextDisabled = Color(0xFFD1D5DB);
  
  // On Colors (text on colored backgrounds)
  static const lightOnPrimary = Color(0xFFFFFFFF);
  static const lightOnSecondary = Color(0xFFFFFFFF);
  static const lightOnBackground = Color(0xFF1F2937);
  static const lightOnSurface = Color(0xFF1F2937);
  
  // Borders & Dividers
  static const lightDivider = Color(0xFFE5E7EB);
  static const lightBorder = Color(0xFFD1D5DB);
  static const lightBorderLight = Color(0xFFF3F4F6);
  
  // ============================================================
  // 🌙 PREMIUM DARK THEME - Soft & Eye-Comfortable
  // ============================================================
  
  // Primary: Bright Blue - vibrant for dark mode
  static const darkPrimary = Color(0xFF818CF8); // Light indigo
  static const darkPrimaryVariant = Color(0xFFA5B4FC);
  static const darkPrimaryDark = Color(0xFF6366F1);
  
  // Secondary: Bright Purple - energetic
  static const darkSecondary = Color(0xFFA78BFA); // Light purple
  static const darkSecondaryVariant = Color(0xFFC4B5FD);
  
  // Accent: Bright Cyan - electric
  static const darkAccent = Color(0xFF22D3EE); // Bright cyan
  static const darkAccentVariant = Color(0xFF67E8F9);
  
  // Surfaces & Backgrounds - Brighter dark mode with gradient feel
  static const darkBackground = Color(0xFF0F172A); // Deep slate blue
  static const darkSurface = Color(0xFF1E293B); // Slate with blue tint
  static const darkSurfaceVariant = Color(0xFF334155); // Mid slate
  static const darkSurfaceElevated = Color(0xFF475569); // Light slate
  
  // Dark theme gradient backgrounds
  static const darkBackgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0F172A), Color(0xFF1E293B), Color(0xFF312E81)],
  );
  
  static const darkSurfaceGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1E293B), Color(0xFF334155), Color(0xFF3730A3)],
  );
  
  // Text Colors - High contrast but not harsh
  static const darkTextPrimary = Color(0xFFEFEFEF); // Soft white
  static const darkTextSecondary = Color(0xFFB0B0B0); // Medium gray
  static const darkTextTertiary = Color(0xFF808080); // Dimmed gray
  static const darkTextDisabled = Color(0xFF505050);
  
  // On Colors
  static const darkOnPrimary = Color(0xFF1F2937);
  static const darkOnSecondary = Color(0xFF1F2937);
  static const darkOnBackground = Color(0xFFEFEFEF);
  static const darkOnSurface = Color(0xFFEFEFEF);
  
  // Borders & Dividers
  static const darkDivider = Color(0xFF3C3C3C);
  static const darkBorder = Color(0xFF404040);
  static const darkBorderLight = Color(0xFF2C2C2C);
  
  // ============================================================
  // 🎨 SEMANTIC COLORS (Same for both themes)
  // ============================================================
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
  
  // ============================================================
  // 🌈 PREMIUM GRADIENTS - Food-Themed
  // ============================================================
  
  // Primary Blue Gradients
  static const lightPrimaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF6366F1), Color(0xFF818CF8), Color(0xFFA5B4FC)],
  );
  
  static const darkPrimaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF6366F1), Color(0xFF818CF8), Color(0xFF8B5CF6)],
  );
  
  // Extra vibrant gradient for dark mode buttons
  static const darkPrimaryGradientVibrant = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF4F46E5), Color(0xFF6366F1), Color(0xFF7C3AED)],
  );
  
  // Secondary Purple Gradients
  static const lightSecondaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF8B5CF6), Color(0xFFA78BFA), Color(0xFFC4B5FD)],
  );
  
  static const darkSecondaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF7C3AED), Color(0xFF8B5CF6), Color(0xFFA78BFA)],
  );
  
  // Extra vibrant purple gradient for dark mode
  static const darkSecondaryGradientVibrant = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF6D28D9), Color(0xFF7C3AED), Color(0xFFA855F7)],
  );
  
  // Accent Cyan Gradients
  static const accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF06B6D4), Color(0xFF22D3EE), Color(0xFF67E8F9)],
  );
  
  // Food-specific gradients
  static const sunsetGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6), Color(0xFFEC4899)],
  );
  
  static const freshGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF06B6D4), Color(0xFF8B5CF6), Color(0xFF6366F1)],
  );
  
  // Dark mode glow gradients
  static const darkGlowBlue = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF1E293B),
      Color(0xFF312E81),
      Color(0xFF4F46E5),
      Color(0xFF6366F1),
    ],
  );
  
  static const darkGlowPurple = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF1E293B),
      Color(0xFF581C87),
      Color(0xFF7C3AED),
      Color(0xFF8B5CF6),
    ],
  );
  
  static const darkGlowCyan = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF1E293B),
      Color(0xFF164E63),
      Color(0xFF0891B2),
      Color(0xFF06B6D4),
    ],
  );
  
  // ============================================================
  // 💫 SHADOWS - Elevation system
  // ============================================================
  static final lightShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.04),
      blurRadius: 4,
      offset: const Offset(0, 2),
    ),
  ];
  
  static final lightShadowMd = [
    BoxShadow(
      color: Colors.black.withOpacity(0.06),
      blurRadius: 8,
      offset: const Offset(0, 4),
    ),
  ];
  
  static final lightShadowLg = [
    BoxShadow(
      color: Colors.black.withOpacity(0.08),
      blurRadius: 16,
      offset: const Offset(0, 8),
    ),
  ];
  
  static final darkShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.2),
      blurRadius: 8,
      offset: const Offset(0, 4),
    ),
  ];
  
  static final darkShadowMd = [
    BoxShadow(
      color: Colors.black.withOpacity(0.3),
      blurRadius: 16,
      offset: const Offset(0, 6),
    ),
  ];
  
  static final darkShadowLg = [
    BoxShadow(
      color: Colors.black.withOpacity(0.4),
      blurRadius: 24,
      offset: const Offset(0, 12),
    ),
  ];
  
  // Colored shadows for emphasis
  static BoxShadow primaryShadow(bool isDark) => BoxShadow(
    color: (isDark ? darkPrimary : lightPrimary).withOpacity(0.3),
    blurRadius: 12,
    offset: const Offset(0, 4),
  );
  
  static BoxShadow secondaryShadow(bool isDark) => BoxShadow(
    color: (isDark ? darkSecondary : lightSecondary).withOpacity(0.3),
    blurRadius: 12,
    offset: const Offset(0, 4),
  );
  
  static BoxShadow accentShadow(bool isDark) => BoxShadow(
    color: (isDark ? darkAccent : lightAccent).withOpacity(0.3),
    blurRadius: 12,
    offset: const Offset(0, 4),
  );
  
  // ============================================================
  // 🎭 OVERLAY & SHIMMER COLORS
  // ============================================================
  
  // Shimmer colors for loading states
  static const lightShimmerBase = Color(0xFFE5E7EB);
  static const lightShimmerHighlight = Color(0xFFFAFAFA);
  static const darkShimmerBase = Color(0xFF2C2C2C);
  static const darkShimmerHighlight = Color(0xFF404040);
}
