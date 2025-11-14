import 'dart:io';

import 'package:flutter/material.dart';
import 'package:food_app/chat.dart';
import 'package:image_picker/image_picker.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
   File? _image;

  Future pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile == null) return;

    setState(() {
      _image = File(pickedFile.path);
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 11, 72, 97),
      appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 86, 4, 210),
          title: const Text('Welcome to the Food App!'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _image == null
                  ? const Text("No Image Selected")
                  : ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                      child: Image.file(
                        _image!,
                        height: 250,
                        width: 250,
                        fit: BoxFit.cover,
                      ),
                    ),
              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: pickImage,
                child: const Text("Pick Image"),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.only(right: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  
                  children: [
                    
                    ElevatedButton(onPressed:(){
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Chat()),
    );
  }, child: Text('chat')),
                    const SizedBox(width: 20),
                    ElevatedButton(onPressed: (){}, child: Text('chat')),
                
                
                  ],
                ),
              )
              
            ],
          ),
        ),

    );
  }
}