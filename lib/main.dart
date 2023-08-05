import 'package:flutter/material.dart';
import 'main/ui.dart';

void main() {
  runApp(const PptApp());
}

class PptApp extends StatelessWidget {
  const PptApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PowerPoint Launcher',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MainScreen(),
    );
  }
}
