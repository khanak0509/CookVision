// import 'package:food_app/auth_service.dart';

// class CartService{
//   String userid = authservice.value.currentUser?.uid ?? '';
//   final snapshot = firebaseFirestore
//       .instance
//       .collection('users')
//       .doc(userid)
//       .collection('cart_items');

//   if (snapshot.docs.isEmpty) {
//     print('Cart is empty');
//   } 
//   else {
//     for (var doc in snapshot.docs) {
//       print(doc.data());
//     }

//   }

//   Future<void> addItemToCart(Map<String, dynamic> item) async {
//     await firebaseFirestore
//         .instance
//         .collection('users')
//         .doc(userid)
//         .collection('cart_items')
//         .add(item);
//   }






// final CartService = CartService();