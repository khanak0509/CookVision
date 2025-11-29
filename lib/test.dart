import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> testFirestore() async {
  final snapshot =
      await FirebaseFirestore.instance.collection('food_items').get();

  for (var doc in snapshot.docs) {
    print(doc.data());
  }
}


