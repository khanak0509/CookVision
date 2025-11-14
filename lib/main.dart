import 'package:flutter/material.dart';

void main(){
  runApp(MainScreen());
}


class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('Hello, Food App!'),
      ),

    );
  }
}