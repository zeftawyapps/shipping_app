import 'package:flutter/material.dart';
class Order extends StatefulWidget {
  const Order({super.key});

  @override
  State<Order> createState() => _OrderState();
}

class _OrderState extends State<Order> {
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
        title: const Text('Order Page'),
      ),
      body: MaterialButton(
        onPressed: () {
          // Action when the button is pressed
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Button Pressed')),
          );
        },
        child: Center(
          child: Text(
            'Welcome to the Home Page',
            style: TextStyle(fontSize: 24),
          ),
        ),
      ),
    );
  }
}
