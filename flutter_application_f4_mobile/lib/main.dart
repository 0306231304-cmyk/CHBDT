import 'package:flutter/material.dart';
import 'View/login_screen.dart';
import 'package:flutter_application_f4_mobile/View/shoppingcard_screen.dart'; 
// Lưu ý: Thay đổi đường dẫn trên cho đúng với vị trí thực tế của file shoppingcard_screen.dart
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
      home:   ShoppingCardScreen(),
    );
  }
}