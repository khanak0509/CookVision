class AppSpacing {
  // Base unit - 4px
  static const double base = 4.0;
  
  // Spacing scale
  static const double xs = base; // 4px
  static const double sm = base * 2; // 8px
  static const double md = base * 3; // 12px
  static const double lg = base * 4; // 16px
  static const double xl = base * 5; // 20px
  static const double xxl = base * 6; // 24px
  static const double xxxl = base * 8; // 32px
  
  // Specific use cases
  static const double cardPadding = lg; // 16px
  static const double screenPadding = xl; // 20px
  static const double sectionSpacing = xxl; // 24px
  static const double elementSpacing = md; // 12px
  
  // Border radius
  static const double radiusXs = base; // 4px
  static const double radiusSm = base * 2; // 8px
  static const double radiusMd = base * 3; // 12px
  static const double radiusLg = base * 4; // 16px
  static const double radiusXl = base * 5; // 20px
  static const double radiusXxl = base * 6; // 24px
  static const double radiusFull = 9999; // Fully rounded
  static const double radiusRound = 9999; // Fully rounded (alias)
  
  // Elevation (for shadows)
  static const double elevation1 = 2.0;
  static const double elevation2 = 4.0;
  static const double elevation3 = 8.0;
  static const double elevation4 = 12.0;
  static const double elevation5 = 16.0;
}
