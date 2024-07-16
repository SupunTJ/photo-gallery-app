import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:flutter/material.dart';

import 'package:photo_gallery_app/screens/home_page.dart';
import 'package:photo_gallery_app/screens/login_screen.dart'; // Use an alias to avoid conflict

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter App',
      home: FirebaseAuth.instance.currentUser == null
          ? LoginScreen()
          : MyHomePage(),
    );
  }
}
