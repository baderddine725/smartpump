import 'package:flutter/material.dart';
import 'info_systeme_page.dart';
import 'weather.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Smart Pump Power',
      home: const InfoSystemePage(),
    );
  }
}
