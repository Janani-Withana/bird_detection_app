import 'package:flutter/material.dart';
import 'camera_screen.dart';

void main() {
  runApp(BirdDetectionApp());
}

class BirdDetectionApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Bird Detection',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: CameraScreen(),
    );
  }
}
