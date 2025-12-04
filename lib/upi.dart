import 'package:flutter/material.dart';

class UpiPaymentIntent extends StatelessWidget {


  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("UPI Payment")),
      body: Center(
        child: ElevatedButton(
          onPressed: () => {

          },
          child: Text("Pay with UPI"),
        ),
      ),
    );
  }
}
