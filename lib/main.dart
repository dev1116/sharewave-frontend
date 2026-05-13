import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'feature/auth/screen/login_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized(); // ← Yeh add karo
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ShareWave',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}