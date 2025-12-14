import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:food_app/auth_service.dart';
import 'package:image_picker/image_picker.dart';
import 'theme/app_colors.dart';
import 'theme/app_spacing.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isLoading = false;
  File? _image;
  final userid = authservice.value.currentUser?.uid ?? '';
  String? _profileImageBase64; 

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> pickImage() async {
    try {
      final pickedFile = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 50,  
        maxWidth: 500,    
        maxHeight: 500,
      );

      if (pickedFile == null) return;

      setState(() {
        _image = File(pickedFile.path);
        _isLoading = true;
      });

      final bytes = await _image!.readAsBytes();
      final base64Image = base64Encode(bytes);

      print('📦 Image size: ${(base64Image.length / 1024).toStringAsFixed(2)} KB');

      if (base64Image.length > 900000) {  
        throw Exception('Image too large. Please choose a smaller image.');
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userid)
          .update({
            'photoBase64': base64Image,
            'updatedAt': FieldValue.serverTimestamp(),
          });

      await FirebaseAuth.instance.currentUser?.updatePhotoURL('base64_stored');

      setState(() {
        _profileImageBase64 = base64Image;
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('✅ Profile photo updated!'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error: $e'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            duration: const Duration(seconds: 3),
          ),
        );
      }
      print('❌ Error saving photo: $e');
    }
  }

  // ✅ Load user data
  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    if (doc.exists) {
      final data = doc.data();
      setState(() {
        _nameController.text = data?['name'] ?? '';
        _emailController.text = data?['email'] ?? '';
        _phoneController.text = data?['phone'] ?? '';
        _profileImageBase64 = data?['photoBase64'];  // ✅ Load Base64
      });
      print('✅ Loaded profile data');
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Profile updated successfully!'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark 
            ? AppColors.darkBackgroundGradient
            : const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFF8FAFC), Color(0xFFFFFFFF)],
              ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isDark 
                            ? AppColors.darkSurfaceVariant 
                            : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isDark 
                              ? AppColors.darkBorder.withOpacity(0.3)
                              : AppColors.lightBorder.withOpacity(0.3),
                          ),
                        ),
                        child: Icon(
                          Icons.arrow_back_ios_new,
                          color: isDark 
                            ? AppColors.darkTextPrimary 
                            : AppColors.lightTextPrimary,
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Text(
                      'Edit Profile',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: isDark 
                          ? AppColors.darkTextPrimary 
                          : AppColors.lightTextPrimary,
                      ),
                    ),
                  ],
                ),
              ),

              // Form
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // ✅ Profile Picture Section
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: isDark 
                              ? AppColors.darkPrimaryGradient 
                              : AppColors.lightPrimaryGradient,
                            boxShadow: [
                              BoxShadow(
                                color: (isDark 
                                  ? AppColors.darkPrimary 
                                  : AppColors.lightPrimary).withOpacity(0.5),
                                blurRadius: 30,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(4),
                          child: Stack(
                            children: [
                              GestureDetector(
                                onTap: pickImage,
                                child: CircleAvatar(
                                  radius: 60,
                                  backgroundColor: isDark 
                                    ? AppColors.darkSurface 
                                    : AppColors.lightSurface,
                                  child: ClipOval(
                                    child: _buildProfileImage(isDark),
                                  ),
                                ),
                              ),
                              
                              if (_isLoading)
                                Positioned.fill(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.5),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Center(
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 3,
                                      ),
                                    ),
                                  ),
                                ),
                              
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    gradient: isDark 
                                      ? AppColors.darkSecondaryGradient 
                                      : AppColors.lightSecondaryGradient,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.camera_alt,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 40),

                        _buildTextField(
                          controller: _nameController,
                          label: 'Full Name',
                          icon: Icons.person_outline,
                          isDark: isDark,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your name';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 20),

                        _buildTextField(
                          controller: _emailController,
                          label: 'Email',
                          icon: Icons.email_outlined,
                          isDark: isDark,
                          enabled: false,
                        ),

                        const SizedBox(height: 20),

                        _buildTextField(
                          controller: _phoneController,
                          label: 'Phone Number',
                          icon: Icons.phone_outlined,
                          isDark: isDark,
                          keyboardType: TextInputType.phone,
                          validator: (value) {
                            if (value != null && value.isNotEmpty && value.length < 10) {
                              return 'Please enter a valid phone number';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 40),

                        GestureDetector(
                          onTap: _isLoading ? null : _saveProfile,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            decoration: BoxDecoration(
                              gradient: isDark 
                                ? AppColors.darkPrimaryGradientVibrant 
                                : AppColors.lightPrimaryGradient,
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [
                                BoxShadow(
                                  color: (isDark 
                                    ? AppColors.darkPrimary 
                                    : AppColors.lightPrimary).withOpacity(0.5),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: _isLoading
                                ? const Center(
                                    child: SizedBox(
                                      height: 24,
                                      width: 24,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    ),
                                  )
                                : const Text(
                                    'Save Changes',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ✅ Show image from Base64 or File
  Widget _buildProfileImage(bool isDark) {
    // Priority 1: Show picked image
    if (_image != null) {
      return Image.file(
        _image!,
        width: 120,
        height: 120,
        fit: BoxFit.cover,
      );
    }
    
    // Priority 2: Show Base64 image from Firestore
    if (_profileImageBase64 != null && _profileImageBase64!.isNotEmpty) {
      try {
        final bytes = base64Decode(_profileImageBase64!);
        return Image.memory(
          bytes,
          width: 120,
          height: 120,
          fit: BoxFit.cover,
        );
      } catch (e) {
        print('❌ Error decoding image: $e');
      }
    }
    
    // Priority 3: Default icon
    return Icon(
      Icons.person,
      size: 60,
      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool isDark,
    bool enabled = true,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark 
          ? AppColors.darkSurface 
          : Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: isDark 
            ? AppColors.darkBorder.withOpacity(0.3)
            : AppColors.lightBorder.withOpacity(0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.black : Colors.grey).withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        enabled: enabled,
        keyboardType: keyboardType,
        validator: validator,
        style: TextStyle(
          color: enabled 
            ? (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary)
            : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
          fontSize: 16,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: enabled 
              ? (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)
              : (isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary),
          ),
          prefixIcon: Icon(
            icon,
            color: enabled 
              ? (isDark ? AppColors.darkPrimary : AppColors.lightPrimary)
              : (isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 18,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
}