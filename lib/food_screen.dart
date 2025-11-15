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
        actions: [
          IconButton(onPressed: (){

          }, icon:Icon(Icons.notifications_active))
        ],
        title: Row(
          children: [
            SizedBox(width: 50),
            Icon(Icons.calendar_today, size: 20),
            SizedBox(width: 10),
            Text(formattedDate, style: TextStyle(fontSize: 20)),
          ],
        ),
        backgroundColor: Color.fromRGBO(199, 199, 253, 1),
        leading: IconButton(
          icon: const Icon(Icons.person_2_rounded),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        
      ),
     body: Column(
  children: [
    Container(
      width: double.infinity,
      height: 220,
      decoration: BoxDecoration(
        color: Color.fromRGBO(199, 199, 253, 1),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Center(
        child: Container(
          
          
          width: 400,
          height: 180,
          decoration: BoxDecoration(
            color: Color.fromRGBO(129, 121, 231, 1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(
            child: Text(
              'your daily calorie intake',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    ),
    Expanded(
      child: Center(
        child: Text('Food Items Here'),
      ),
    ),
  ],
),

    );
  }
}