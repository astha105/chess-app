import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; 

import 'screens/home_screen.dart'; // starting screen

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase in background 
  Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Your App Name',
      theme: ThemeData.dark(),
      home: const HomeScreen(), // or your AuthPage / LoginScreen
    );
  }
}
