import 'package:flutter/material.dart';
import 'package:flutter_application_f4_mobile/View/Home/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'F4 Mobile',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.orange,
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'Roboto',
      ),
<<<<<<< HEAD
      home:  LoginScreen(),
=======
      home:  HomeScreen(),
>>>>>>> 9d899fdb26a436606bfb35ee1e51d527182369ab
    );
  }
}