import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'workspace_select_page.dart';
import 'login_page.dart';

class FirebaseConfig {
  static const FirebaseOptions options = FirebaseOptions(
    apiKey: "AIzaSyAhCzEkhO4miNDG3aQweqpAzCg8EiSuKCI",
    authDomain: "marche-9929e.firebaseapp.com",
    projectId: "marche-9929e",
    storageBucket: "marche-9929e.firebasestorage.app",
    messagingSenderId: "766329029486",
    appId: "1:766329029486:web:4839a56381adcf19af777f",
    measurementId: "G-65F9V0H9L5",
  );
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: FirebaseConfig.options);
  runApp(const MarcheZApp());
}

class MarcheZApp extends StatelessWidget {
  const MarcheZApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'marcheZ | Gamified Project Market', 
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF0F4F8),
        primaryColor: const Color(0xFF1B263B),
        fontFamily: 'Inter', 
      ),
      home: const AuthCheck(),
    );
  }
}

class AuthCheck extends StatelessWidget {
  const AuthCheck({super.key});
  
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<auth.User?>(
      stream: auth.FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (snapshot.hasData) {
          return const WorkspaceSelectPage();
        }
        return const LoginPage();
      },
    );
  }
}