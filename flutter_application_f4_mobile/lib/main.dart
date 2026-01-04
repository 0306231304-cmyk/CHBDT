import 'package:flutter/material.dart';
//import 'View/login_screen.dart';
import 'View/Home/home_screen.dart';
/*import 'View/Category/category_screen.dart';
import 'View/Product/product_detail_screen.dart';*/

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
      home: const HomeScreen(),
      
      
    );
    
  }
   
  
}