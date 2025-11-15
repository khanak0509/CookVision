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
      backgroundColor:  Color.fromRGBO(199, 199, 253, 1),
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
    SizedBox(height: 30),
    Expanded(
      
      child: Container(
        
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
    ),
    
      child: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 20),
          
            Text('Meals', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
           Row(
            children: [
              Container(
                margin: EdgeInsets.only(left: 20, right: 20,top:10),
                width: 180,
                height: 200,
                decoration: BoxDecoration(
                  color: Color.fromRGBO(199, 199, 253, 1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Text(
                    'Breakfast',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

              )
              ,
               Container(
                margin: EdgeInsets.only(left: 5,top:10),

                width: 180,
                height: 200,
                decoration: BoxDecoration(
                  color: Color.fromRGBO(199, 199, 253, 1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Text(
                    'Breakfast',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

              )
            ],
           ),
           Row(
            children: [
              Container(
                margin: EdgeInsets.only(left: 20, right: 20,top:20),
                width: 180,
                height: 200,
                decoration: BoxDecoration(
                  color: Color.fromRGBO(199, 199, 253, 1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Text(
                    'Breakfast',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

              )
              ,
               Container(
   margin: EdgeInsets.only(left:10,top:20),
                width: 180,
                height: 200,
                decoration: BoxDecoration(
                  color: Color.fromRGBO(199, 199, 253, 1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Text(
                    'Breakfast',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

              )
            ],
           ),
           Row(
            children: [
              Container(
                margin: EdgeInsets.all(20),
                width: 180,
                height: 200,
                decoration: BoxDecoration(
                  color: Color.fromRGBO(199, 199, 253, 1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Text(
                    'Breakfast',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

              )
              ,
               Container(

                width: 180,
                height: 200,
                decoration: BoxDecoration(
                  color: Color.fromRGBO(199, 199, 253, 1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Text(
                    'Breakfast',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

              )
            ],
           )

            


          ],
        )
      ),
    
  ),
)

  ],
),

    );
  }
}