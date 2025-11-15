import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; 
class FoodScreen extends StatefulWidget {
  const FoodScreen({super.key});

  @override
  State<FoodScreen> createState() => _FoodScreenState();
}

class _FoodScreenState extends State<FoodScreen> {
  String formattedDate = DateFormat('EEE, d MMM').format(DateTime.now());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            SizedBox(width: 50),
            Icon(Icons.calendar_today, size: 20),
            SizedBox(width: 10),
            Text(formattedDate, style: TextStyle(fontSize: 20)),
          ],
        ),
        backgroundColor: const Color.fromARGB(255, 82, 100, 200),
        leading: IconButton(
          icon: const Icon(Icons.person_2_rounded),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        
      ),
      body: Container(
        child: Column(
          children: [
            Container(
              width: 1000,  
              height: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
                color: const Color.fromARGB(255, 82, 100, 200),
              ),
              child: const Center(
               
              ),
            )
          ],
        ),
      ),
    );
  }
}