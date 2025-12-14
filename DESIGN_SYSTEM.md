# CookVision Design System Reference

## Quick Start Guide

### Using the Theme System

```dart
import 'package:flutter/material.dart';
import 'theme/app_colors.dart';
import 'theme/app_spacing.dart';
import 'theme/app_text_styles.dart';

// Get theme awareness
final theme = Theme.of(context);
final isDark = theme.brightness == Brightness.dark;

// Use theme-aware colors
final primaryColor = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;
final textColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
```

### Color Usage

```dart
// Primary colors
AppColors.lightPrimary  // #6366F1 (Indigo)
AppColors.darkPrimary   // #818CF8 (Lighter Indigo for dark mode)

// Gradients
gradient: isDark ? AppColors.darkPrimaryGradient : AppColors.lightPrimaryGradient

// Semantic colors (same for both themes)
AppColors.success  // Green
AppColors.error    // Red
AppColors.warning  // Orange
AppColors.info     // Blue
```

### Typography

```dart
// Display (32-24px) - Hero text
AppTextStyles.displayLarge
AppTextStyles.displayMedium
AppTextStyles.displaySmall

// Headlines (22-18px) - Section headers
AppTextStyles.headlineLarge
AppTextStyles.headlineMedium
AppTextStyles.headlineSmall

// Titles (16-14px) - Card titles
AppTextStyles.titleLarge
AppTextStyles.titleMedium
AppTextStyles.titleSmall

// Body (16-12px) - Regular text
AppTextStyles.bodyLarge
AppTextStyles.bodyMedium
AppTextStyles.bodySmall

// Labels (14-11px) - Buttons, tags
AppTextStyles.labelLarge
AppTextStyles.labelMedium
AppTextStyles.labelSmall

// Caption (12-10px) - Helper text
AppTextStyles.caption
AppTextStyles.captionSmall
```

### Spacing

```dart
// Padding
AppSpacing.xs    // 4px
AppSpacing.sm    // 8px
AppSpacing.md    // 12px
AppSpacing.lg    // 16px
AppSpacing.xl    // 20px
AppSpacing.xxl   // 24px
AppSpacing.xxxl  // 32px

// Specific use cases
AppSpacing.cardPadding      // 16px
AppSpacing.screenPadding    // 20px
AppSpacing.sectionSpacing   // 24px
AppSpacing.elementSpacing   // 12px

// Border Radius
AppSpacing.radiusXs   // 4px
AppSpacing.radiusSm   // 8px
AppSpacing.radiusMd   // 12px
AppSpacing.radiusLg   // 16px
AppSpacing.radiusXl   // 20px
AppSpacing.radiusXxl  // 24px
```

### Using Custom Widgets

#### Custom Button

```dart
import 'widgets/custom_button.dart';

// Primary button
CustomButton(
  text: 'Continue',
  onPressed: () {},
  variant: ButtonVariant.primary,
  size: ButtonSize.large,
  fullWidth: true,
)

// Gradient button
CustomButton(
  text: 'Login',
  onPressed: login,
  variant: ButtonVariant.gradient,
  isLoading: _isLoading,
  icon: Icons.login,
)

// Outlined button
CustomButton(
  text: 'Cancel',
  onPressed: () {},
  variant: ButtonVariant.outlined,
  size: ButtonSize.medium,
)
```

#### Custom Text Field

```dart
import 'widgets/custom_text_field.dart';

CustomTextField(
  controller: _emailController,
  hintText: 'Enter your email',
  labelText: 'Email',
  prefixIcon: Icons.email_outlined,
  keyboardType: TextInputType.emailAddress,
  validator: (value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    return null;
  },
)
```

#### Custom Card

```dart
import 'widgets/custom_card.dart';

// Simple card
CustomCard(
  padding: EdgeInsets.all(AppSpacing.lg),
  child: Text('Content'),
)

// Gradient card with tap
CustomCard(
  gradient: AppColors.lightPrimaryGradient,
  onTap: () {},
  child: Row(...),
)

// Glassmorphic card
CustomCard(
  glassmorphism: true,
  child: Content(),
)
```

#### Food Card

```dart
import 'widgets/food_card.dart';

FoodCard(
  imageUrl: 'https://example.com/image.jpg',
  name: 'Chicken Biryani',
  price: 299.0,
  rating: '4.5',
  calories: '450',
  onTap: () {
    // Navigate to details
  },
  onAddToCart: () {
    // Add to cart
  },
)
```

#### Skeleton Loaders

```dart
import 'widgets/skeleton_loader.dart';

// Simple skeleton
SkeletonLoader(
  width: 100,
  height: 20,
  borderRadius: AppSpacing.radiusSm,
)

// Food card skeleton
FoodCardSkeleton()

// List item skeleton
ListItemSkeleton()
```

### Page Transitions

```dart
import 'animations/page_transitions.dart';

// Fade + Slide transition
Navigator.push(
  context,
  CustomPageRoute(
    page: NextScreen(),
    transitionType: PageTransitionType.fadeSlide,
  ),
);

// Scale transition
Navigator.push(
  context,
  CustomPageRoute(
    page: NextScreen(),
    transitionType: PageTransitionType.scale,
  ),
);
```

### Common Patterns

#### Theme-Aware Container

```dart
Container(
  decoration: BoxDecoration(
    color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
    borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
    boxShadow: [
      BoxShadow(
        color: isDark ? AppColors.darkShadow : AppColors.lightShadow,
        blurRadius: 8,
        offset: Offset(0, 4),
      ),
    ],
  ),
  child: ...,
)
```

#### Gradient Background

```dart
Container(
  decoration: BoxDecoration(
    gradient: isDark
      ? AppColors.darkPrimaryGradient
      : AppColors.lightPrimaryGradient,
  ),
  child: ...,
)
```

#### Success Snackbar

```dart
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: Text('Success!'),
    backgroundColor: AppColors.success,
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
    ),
  ),
);
```

## Best Practices

1. **Always use theme-aware colors** - Check `isDark` and use appropriate color variants
2. **Use spacing constants** - Never hardcode pixel values
3. **Apply text styles** - Use AppTextStyles instead of inline TextStyle
4. **Reuse widgets** - Use the widget library instead of creating from scratch
5. **Add animations** - Use AnimationController for smooth 60fps animations
6. **Handle loading states** - Show skeleton loaders while data loads
7. **Error handling** - Always provide error states for images and data
8. **Accessibility** - Ensure proper contrast and touch target sizes

## File Structure

```
lib/
├── theme/
│   ├── app_theme.dart         # Main theme configuration
│   ├── app_colors.dart        # Color palette
│   ├── app_text_styles.dart   # Typography
│   └── app_spacing.dart       # Spacing constants
├── widgets/
│   ├── custom_button.dart     # Button widget
│   ├── custom_text_field.dart # Input field widget
│   ├── custom_card.dart       # Card widget
│   ├── food_card.dart         # Food item card
│   └── skeleton_loader.dart   # Loading skeletons
├── animations/
│   ├── animation_constants.dart  # Timing and curves
│   └── page_transitions.dart     # Route transitions
└── [screen files]
```

## Design Principles

- **Consistency**: Same patterns across all screens
- **Performance**: 60fps animations, efficient rebuilds
- **Accessibility**: High contrast, large touch targets
- **Responsiveness**: Works on all screen sizes
- **Modern**: Follows latest Material Design 3 guidelines
- **Premium**: Feels better than 90% of food apps

---

**Need help?** Refer to the implemented screens (login.dart, signup.dart, MainScreen.dart, food_screen.dart) for real-world examples.
