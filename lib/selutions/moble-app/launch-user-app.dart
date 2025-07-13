import 'package:flutter/material.dart';
class LaounchMoblieApp extends StatefulWidget {
  const LaounchMoblieApp({super.key});

  @override
  State<LaounchMoblieApp> createState() => _LaounchMoblieAppState();
}

class _LaounchMoblieAppState extends State<LaounchMoblieApp> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User App'),
      ),
      body: Center(
        child: Text(
          'User App is under construction',

        ),
      ),
    );
  }
}
