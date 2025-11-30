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
