import 'package:flutter/material.dart';
import 'package:step_by_step/page/Home.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Step by Step',
      theme: ThemeData.dark(),
      home: const Home(),
    );
  }
}
