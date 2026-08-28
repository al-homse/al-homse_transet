import 'package:flutter/material.dart';
import 'screens/welcome_screen.dart'; // استدعاء شاشة الترحيب

void main() {
  runApp(const AlhomseTransetApp());
}

class AlhomseTransetApp extends StatelessWidget {
  const AlhomseTransetApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Alhomse Transet',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const WelcomeScreen(), // البداية أصبحت من شاشة الترحيب
    );
  }
}