import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:food_app/cart.dart';
import 'package:food_app/chat.dart';
import 'package:food_app/cooking_mode.dart';
import 'package:food_app/food_screen.dart';
import 'package:food_app/profile.dart';
import 'package:food_app/suggestions_screen.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'theme/app_colors.dart';
import 'theme/app_spacing.dart';
import 'theme/app_text_styles.dart';
import 'widgets/custom_card.dart';
import 'animations/page_transitions.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with SingleTickerProviderStateMixin {
  File? _image;
  String weather = "Loading weather...";
  String _currentCity = "Loading...";
  Stream<Position>? positionStream;
  String suggestion = "";
  int _currentIndex = 0;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _startLiveLocation();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animationController.forward();
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Pick image from gallery
  Future pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile == null) return;

    setState(() {
      _image = File(pickedFile.path);
    });
  }

  // Fetch weather from API
  void getWeather({required String city}) async {
    final url = Uri.parse('http://localhost:8000/weather/$city');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data != null && data['description'] != null && data['temperature'] != null) {
        setState(() {
          weather = "${data['description']}, ${data['temperature']}°C";
        });
      } else {
        setState(() {
          weather = "Weather data missing in API";
        });
      }
    } else {
      setState(() {
        weather = "Failed to load weather (Code ${response.statusCode})";
      });
    }
    final url2 = Uri.parse('http://localhost:8000/suggestions/$weather');
    final response2 = await http.get(url2);

    if (response2.statusCode == 200) {
      final data2 = jsonDecode(response2.body);
      setState(() {
        suggestion = data2['suggestions'];
      });
      print(data2['suggestions']);
    } else {
      print("Failed to load suggestions");
    }
  }

  // Start live location tracking
  Future<void> _startLiveLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    if (permission == LocationPermission.deniedForever) return;

    positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter: 5,
      ),
    );

    positionStream!.listen((Position position) async {
      String city = await _getCityFromCoordinates(position.latitude, position.longitude);
      setState(() {
        _currentCity = city;
      });
      if (city != "Unknown City" && city.isNotEmpty) {
        getWeather(city: city);
      }
    });
  }

  // Get city from coordinates
  Future<String> _getCityFromCoordinates(double lat, double lng) async {
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(lat, lng, localeIdentifier: "en_IN");
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        return place.locality ?? "Unknown City";
      }
      return "Unknown City";
    } catch (e) {
      return "Error: $e";
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(AppSpacing.screenPadding),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 40),
                  Text(
                    'CookVision',
                    style: AppTextStyles.headlineLarge.copyWith(
                      color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      gradient: isDark ? AppColors.darkPrimaryGradient : AppColors.lightPrimaryGradient,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                      boxShadow: [
                        BoxShadow(
                          color: (isDark ? AppColors.darkPrimary : AppColors.lightPrimary)
                              .withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.notifications_outlined, color: Colors.white, size: 24),
                  ),
                ],
              ),
            ),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Weather Card
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          CustomPageRoute(
                            page: SuggestionsScreen(
                             
                            ),
                          ),
                        );
                      },
                      child: CustomCard(
                        gradient: isDark ? AppColors.darkPrimaryGradient : AppColors.lightPrimaryGradient,
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(AppSpacing.md),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                              ),
                              child: const Icon(Icons.wb_sunny, color: Colors.white, size: 32),
                            ),
                            const SizedBox(width: AppSpacing.lg),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _currentCity,
                                    style: AppTextStyles.headlineSmall.copyWith(
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    weather,
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      color: Colors.white.withOpacity(0.9),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.arrow_forward_ios,
                              color: Colors.white70,
                              size: 18,
                            ),
                          ],
                        ),
                      ),
                    ),

                    if (suggestion.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.lg),
                      CustomCard(
                        backgroundColor: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant,
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        child: Row(
                          children: [
                            Icon(
                              Icons.lightbulb_outline,
                              color: isDark ? AppColors.darkSecondary : AppColors.lightSecondary,
                              size: 24,
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Text(
                                suggestion,
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: AppSpacing.sectionSpacing),

                    // Food Scanner Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Food Scanner',
                          style: AppTextStyles.headlineMedium.copyWith(
                            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                          ),
                        ),
                        if (_image != null)
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _image = null;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.all(AppSpacing.sm),
                              decoration: BoxDecoration(
                                color: AppColors.error.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                              ),
                              child: const Icon(
                                Icons.close,
                                color: AppColors.error,
                                size: 18,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    
                    // Scanner Card
                    GestureDetector(
                      onTap: pickImage,
                      child: Container(
                        height: 200,
                        decoration: BoxDecoration(
                          color: _image != null
                              ? (isDark ? AppColors.darkSurface : AppColors.lightSurface)
                              : (isDark
                                  ? AppColors.darkSurfaceVariant
                                  : AppColors.lightSurfaceVariant),
                          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                          border: Border.all(
                            color: (isDark ? AppColors.darkPrimary : AppColors.lightPrimary)
                                .withOpacity(0.3),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: isDark ? AppColors.darkShadow : AppColors.lightShadow,
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: _image == null
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(AppSpacing.lg),
                                    decoration: BoxDecoration(
                                      gradient: isDark
                                          ? AppColors.darkPrimaryGradient
                                          : AppColors.lightPrimaryGradient,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.camera_alt_rounded,
                                      color: Colors.white,
                                      size: 32,
                                    ),
                                  ),
                                  const SizedBox(height: AppSpacing.lg),
                                  Text(
                                    'Scan Your Food',
                                    style: AppTextStyles.titleLarge.copyWith(
                                      color: isDark
                                          ? AppColors.darkTextPrimary
                                          : AppColors.lightTextPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: AppSpacing.xs),
                                  Text(
                                    'Tap to capture or select from gallery',
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: isDark
                                          ? AppColors.darkTextSecondary
                                          : AppColors.lightTextSecondary,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              )
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    Image.file(
                                      _image!,
                                      fit: BoxFit.cover,
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                        gradient: AppColors.imageOverlayGradient,
                                      ),
                                    ),
                                    Positioned(
                                      bottom: AppSpacing.lg,
                                      left: AppSpacing.lg,
                                      right: AppSpacing.lg,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Image Captured',
                                                style: AppTextStyles.titleMedium.copyWith(
                                                  color: Colors.white,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                'Tap to change',
                                                style: AppTextStyles.bodySmall.copyWith(
                                                  color: Colors.white70,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: AppSpacing.lg,
                                              vertical: AppSpacing.sm,
                                            ),
                                            decoration: BoxDecoration(
                                              gradient: AppColors.accentGradient,
                                              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Icon(
                                                  Icons.search,
                                                  color: Colors.white,
                                                  size: 16,
                                                ),
                                                const SizedBox(width: AppSpacing.xs),
                                                Text(
                                                  'Analyze',
                                                  style: AppTextStyles.labelSmall.copyWith(
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: AppSpacing.sectionSpacing),

                    // Quick Actions
                    Text(
                      'Quick Actions',
                      style: AppTextStyles.headlineMedium.copyWith(
                        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    
                    Row(
                      children: [
                        Expanded(
                          child: _buildQuickActionCard(
                            icon: Icons.chat_bubble_outline,
                            title: 'AI Chat',
                            onTap: () {
                              Navigator.push(
                                context,
                                CustomPageRoute(page: const Chat()),
                              );
                            },
                            isDark: isDark,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: _buildQuickActionCard(
                            icon: Icons.restaurant_menu,
                            title: 'Menu',
                            onTap: () {
                              Navigator.push(
                                context,
                                CustomPageRoute(page: const FoodScreen()),
                              );
                            },
                            isDark: isDark,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: AppSpacing.lg),

                    // Cooking Mode Card
                    CustomCard(
                      gradient: AppColors.foodGradient,
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      onTap: () {
                        Navigator.push(
                          context,
                          CustomPageRoute(page: const CookingModeScreen()),
                        );
                      },
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(AppSpacing.md),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                            ),
                            child: const Icon(
                              Icons.restaurant,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.lg),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Want to Cook?',
                                  style: AppTextStyles.titleLarge.copyWith(
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Get step-by-step cooking guidance',
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: Colors.white.withOpacity(0.9),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.white,
                            size: 16,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppSpacing.sectionSpacing),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(isDark),
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return CustomCard(
      onTap: onTap,
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              gradient: isDark ? AppColors.darkPrimaryGradient : AppColors.lightPrimaryGradient,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            title,
            style: AppTextStyles.titleMedium.copyWith(
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withOpacity(0.3) : Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.home, 'Home', 0, isDark),
              _buildNavItem(Icons.menu_book, 'Menu', 1, isDark),
              _buildNavItem(Icons.shopping_cart_outlined, 'Cart', 2, isDark),
              _buildNavItem(Icons.person_outline, 'Profile', 3, isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index, bool isDark) {
    final isSelected = _currentIndex == index;
    final color = isSelected
        ? (isDark ? AppColors.darkPrimary : AppColors.lightPrimary)
        : (isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary);

    return GestureDetector(
      onTap: () {
        setState(() => _currentIndex = index);
        switch (index) {
          case 0:
            break;
          case 1:
            Navigator.push(
              context,
              CustomPageRoute(page: const FoodScreen()),
            );
            break;
          case 2:
            Navigator.push(
              context,
              CustomPageRoute(page: const Cart()),
            );
            break;
          case 3:
            Navigator.push(
              context,
              CustomPageRoute(page: const Profile()),
            );
            break;
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTextStyles.captionSmall.copyWith(
                color: color,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
