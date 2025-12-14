import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:food_app/auth_service.dart';
import 'package:food_app/login.dart';
import 'package:food_app/edit_profile.dart';
import 'package:food_app/about_screen.dart';
import 'package:food_app/privacy_policy_screen.dart';
import 'package:food_app/address_screen.dart';
import 'theme/app_colors.dart';
import 'theme/app_spacing.dart';
import 'theme/app_text_styles.dart';
import 'widgets/custom_button.dart';
import 'animations/page_transitions.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  String name = "";
  String email = "";
  int orders = 0;
  int favorites = 0;
  int reviews = 0;
  String? _profileImageBase64;

  @override
  void initState() {
    super.initState();
    fetchusers();
  }

  void signout() async {
    authservice.value.signOut();
    Navigator.pushReplacement(
      context,
      CustomPageRoute(page: const LoginScreen()),
    );
  }

  void fetchusers() async {
    final user = authservice.value.currentUser;
    if (user == null) return;

    final snapshot = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    if (!snapshot.exists) return;
    final userinfo = snapshot.data();
    setState(() {
      name = userinfo?['name'] ?? "Guest User";
      email = userinfo?['email'] ?? "";
      orders = userinfo?['orders'] ?? 0;
      favorites = userinfo?['favorites'] ?? 0;
      reviews = userinfo?['reviews'] ?? 0;
      _profileImageBase64 = userinfo?['photoBase64'];
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(AppSpacing.screenPadding),
                decoration: BoxDecoration(
                  gradient: isDark ? AppColors.darkPrimaryGradient : AppColors.lightPrimaryGradient,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(AppSpacing.radiusXxl),
                    bottomRight: Radius.circular(AppSpacing.radiusXxl),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            padding: const EdgeInsets.all(AppSpacing.sm),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                            ),
                            child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
                          ),
                        ),
                        Text('Profile', style: AppTextStyles.headlineMedium.copyWith(color: Colors.white)),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              CustomPageRoute(page: const EditProfile()),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(AppSpacing.sm),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                            ),
                            child: const Icon(Icons.edit, color: Colors.white, size: 20),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    
                    // Profile Image
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 4),
                      ),
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.white.withOpacity(0.2),
                        child: _buildProfileImage(),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    
                    // Name & Email
                    Text(name, style: AppTextStyles.headlineMedium.copyWith(color: Colors.white)),
                    const SizedBox(height: AppSpacing.xs),
                    Text(email, style: AppTextStyles.bodyMedium.copyWith(color: Colors.white.withOpacity(0.9))),
                    const SizedBox(height: AppSpacing.lg),
                  ],
                ),
              ),

              // Stats
              Padding(
                padding: const EdgeInsets.all(AppSpacing.screenPadding),
                child: Row(
                  children: [
                    Expanded(child: _buildStatCard('Orders', orders, Icons.shopping_bag_outlined, isDark)),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(child: _buildStatCard('Favorites', favorites, Icons.favorite_outline, isDark)),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(child: _buildStatCard('Reviews', reviews, Icons.star_outline, isDark)),
                  ],
                ),
              ),

              // Menu Sections
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
                child: Column(
                  children: [
                    _buildMenuSection('Account', [
                      _buildMenuItem(Icons.person_outline, 'Edit Profile', () {
                        Navigator.push(context, CustomPageRoute(page: const EditProfile()));
                      }, isDark),
                      _buildMenuItem(Icons.location_on_outlined, 'Addresses', () {
                        Navigator.push(context, CustomPageRoute(page: const AddressScreen()));
                      }, isDark),
                      _buildMenuItem(Icons.notifications_outlined, 'Notifications', () {}, isDark),
                    ], isDark),
                    
                    const SizedBox(height: AppSpacing.lg),
                    
                    _buildMenuSection('Support', [
                      _buildMenuItem(Icons.help_outline, 'Help Center', () {}, isDark),
                      _buildMenuItem(Icons.info_outline, 'About', () {
                        Navigator.push(context, CustomPageRoute(page: const AboutScreen()));
                      }, isDark),
                      _buildMenuItem(Icons.privacy_tip_outlined, 'Privacy Policy', () {
                        Navigator.push(context, CustomPageRoute(page: const PrivacyPolicyScreen()));
                      }, isDark),
                    ], isDark),
                    
                    const SizedBox(height: AppSpacing.xxl),
                    
                    // Logout Button
                    CustomButton(
                      text: 'Logout',
                      onPressed: signout,
                      variant: ButtonVariant.primary,
                      size: ButtonSize.large,
                      fullWidth: true,
                      icon: Icons.logout,
                    ),
                    
                    const SizedBox(height: AppSpacing.xxl),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, int value, IconData icon, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        boxShadow: [
          BoxShadow(
            color: isDark ? AppColors.darkShadow : AppColors.lightShadow,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary, size: 24),
          const SizedBox(height: AppSpacing.sm),
          Text(
            value.toString(),
            style: AppTextStyles.headlineSmall.copyWith(
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection(String title, List<Widget> items, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.titleLarge.copyWith(
            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          ),
          child: Column(children: items),
        ),
      ],
    );
  }

  Widget _buildMenuItem(IconData icon, String title, VoidCallback onTap, bool isDark) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          gradient: isDark ? AppColors.darkPrimaryGradient : AppColors.lightPrimaryGradient,
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
      title: Text(
        title,
        style: AppTextStyles.bodyLarge.copyWith(
          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
      ),
    );
  }

  Widget _buildProfileImage() {
    if (_profileImageBase64 != null && _profileImageBase64!.isNotEmpty) {
      try {
        final bytes = base64Decode(_profileImageBase64!);
        return ClipOval(
          child: Image.memory(bytes, width: 100, height: 100, fit: BoxFit.cover),
        );
      } catch (e) {
        return const Icon(Icons.person, size: 50, color: Colors.white);
      }
    }
    return const Icon(Icons.person, size: 50, color: Colors.white);
  }
}