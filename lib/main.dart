import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:food_app/MainScreen.dart';
import 'package:food_app/auth_service.dart';
import 'package:food_app/firebase_options.dart';
import 'package:food_app/insert_dataset/add_food_items.dart';
import 'package:food_app/login.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // uploadFromJsonFile();
// upload_cooking_steps();
  runApp(const Main());

}

class Main extends StatefulWidget {
  const Main({super.key});


  @override
  State<Main> createState() => _MainState();
}

class _MainState extends State<Main> {
  final user = authservice.value.currentUser;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: user == null ? LoginScreen() : MainScreen(),
    );
  }
}
