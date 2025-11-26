
import 'package:flutter/material.dart';

class Chat extends StatefulWidget {
  const Chat({super.key});

  @override
  State<Chat> createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 12, 35, 42),
      appBar: AppBar(

        backgroundColor: const Color.fromARGB(255, 11, 87, 99),
         actions: [
          IconButton(onPressed: (){

          }, icon:Icon(Icons.line_axis))
        ],
        title: Text('chat'),
      ),
      body : Column(
        children: [
        
        ],
      )







    );
  }
}