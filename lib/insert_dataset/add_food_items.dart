import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

Future <void > uploadFromJsonFile() async {

  String jsondata = await rootBundle.loadString('assets/products.json');
  List data = jsonDecode(jsondata);
  final col = FirebaseFirestore.instance.collection('food_items');

  for (var item in data){
    await col.doc(item['id']).set(item);
    print('Uploaded ${item['name']}');
  }

}


Future <void> upload_cooking_steps() async{
  String jsondata = await rootBundle.loadString('assets/cooking_recipes.json');
   Map<String, dynamic> data = jsonDecode(jsondata);
  final col = FirebaseFirestore.instance.collection('cooking_steps');

  for (var entry in data.entries) {
    String recipeId = entry.key;  
    Map<String, dynamic> recipeData = entry.value;

    await col.doc(recipeData['name']).set(recipeData);
    print('✅ Uploaded: ${recipeData['name']} (ID: $recipeId)');
  }
  
  print('\n🎉 All cooking recipes uploaded successfully!');
}
