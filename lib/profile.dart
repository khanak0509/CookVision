import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:food_app/auth_service.dart';
import 'package:food_app/login.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final user = FirebaseAuth.instance.currentUser;
  String name = "";
  String email = "";
  int orders = 10;
  int favorites = 5;
  int reviews = 20;

  @override
  void initState() {
    super.initState();
    
    fetchusers();
  }
  //logout logic here
 void signout () async {
  authservice.value.signOut();
  Navigator.push(context, MaterialPageRoute(builder:(context)=> LoginScreen()));

 }


 void fetchusers()async {
  final user = authservice.value.currentUser;
  if (user == null) return; 

  final snapshot = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
  if (!snapshot.exists) return;
  final userinfo = snapshot.data();
  setState(() {
    name = userinfo?['name'] ?? "no name";

    email = userinfo?['email'] ?? "no email";
    orders = userinfo?['orders'] ?? 1;
    favorites = userinfo?['favorites'] ?? 10;
    reviews = userinfo?['reviews'] ?? 100;

  });

 }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1a1a2e),
              Color(0xFF16213e),
              Color(0xFF0f3460),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2a2d3a),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.arrow_back_ios_new,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                      const Text(
                        'Profile',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.edit,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Profile Picture
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF667eea).withOpacity(0.5),
                        blurRadius: 30,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(4),
                  child: CircleAvatar(
                    radius: 60,
                    backgroundColor: const Color(0xFF2a2d3a),
                    child: user?.photoURL != null
                        ? ClipOval(
                            child: Image.network(
                              user!.photoURL!,
                              width: 120,
                              height: 120,
                              fit: BoxFit.cover,
                            ),
                          )
                        : const Icon(
                            Icons.person,
                            size: 60,
                            color: Colors.white,
                          ),
                  ),
                ),

                const SizedBox(height: 20),

                // Name
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 8),

                // Email
                Text(
                  email,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white60,
                  ),
                ),

                const SizedBox(height: 30),

                // Stats Cards
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Orders Card
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2a2d3a),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child:  Column(
                          children: [
                            Icon(Icons.shopping_bag, color: Color(0xFF667eea), size: 28),
                            SizedBox(height: 10),
                            Text(
                              orders.toString(),
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              'Orders',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white60,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Favorites Card
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2a2d3a),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: const Column(
                          children: [
                            Icon(Icons.favorite, color: Color(0xFF667eea), size: 28),
                            SizedBox(height: 10),
                            Text(
                              '8',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              'Favorites',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white60,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Reviews Card
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2a2d3a),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: const Column(
                          children: [
                            Icon(Icons.star, color: Color(0xFF667eea), size: 28),
                            SizedBox(height: 10),
                            Text(
                              '15',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              'Reviews',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white60,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // Menu Options
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      _buildMenuSection('Account Settings', [
                        _buildMenuItem(
                          Icons.person_outline,
                          'Edit Profile',
                          'Update your personal information',
                          () {
                          
                          },
                        ),
                        _buildMenuItem(
                          Icons.lock_outline,
                          'Change Password',
                          'Update your password',
                          () {
                            // Add change password logic
                          },
                        ),
                        _buildMenuItem(
                          Icons.notifications_outlined,
                          'Notifications',
                          'Manage notification preferences',
                          () {
                            // Add notifications logic
                          },
                        ),
                      ]),

                      const SizedBox(height: 20),

                      _buildMenuSection('Preferences', [
                        _buildMenuItem(
                          Icons.restaurant_menu,
                          'Dietary Preferences',
                          'Set your dietary restrictions',
                          () {
                            // Add dietary preferences logic
                          },
                        ),
                        _buildMenuItem(
                          Icons.location_on_outlined,
                          'Delivery Address',
                          'Manage your addresses',
                          () {
                            // Add address logic
                          },
                        ),
                        _buildMenuItem(
                          Icons.payment_outlined,
                          'Payment Methods',
                          'Manage payment options',
                          () {
                            // Add payment logic
                          },
                        ),
                      ]),

                      const SizedBox(height: 20),

                      _buildMenuSection('Support', [
                        _buildMenuItem(
                          Icons.help_outline,
                          'Help Center',
                          'Get help and support',
                          () {
                            // Add help logic
                          },
                        ),
                        _buildMenuItem(
                          Icons.info_outline,
                          'About',
                          'App information and version',
                          () {
                            // Add about logic
                          },
                        ),
                        _buildMenuItem(
                          Icons.privacy_tip_outlined,
                          'Privacy Policy',
                          'Read our privacy policy',
                          () {
                            // Add privacy policy logic
                          },
                        ),
                      ]),

                      const SizedBox(height: 30),

                      // Logout Button
                      GestureDetector(
                        onTap: signout,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFF416C), Color(0xFFFF4B2B)],
                            ),
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFFF416C).withOpacity(0.5),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.logout, color: Colors.white),
                              SizedBox(width: 10),
                              Text(
                                'Logout',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Version
                      const Text(
                        'Version 1.0.0',
                        style: TextStyle(
                          color: Colors.white38,
                          fontSize: 12,
                        ),
                      ),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuSection(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 5, bottom: 15),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white70,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF2a2d3a),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(children: items),
        ),
      ],
    );
  }

  Widget _buildMenuItem(
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white54,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: Colors.white38,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}