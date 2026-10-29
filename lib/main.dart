import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const TorqCustomerApp());
}

class TorqCustomerApp extends StatelessWidget {
  const TorqCustomerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TORQ Customer',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFFCD34D)),
        useMaterial3: true,
      ),
      home: const LoginScreen(),
      routes: {
        '/home': (context) => const HomeScreen(),
        '/register': (context) => const PlaceholderScreen(title: 'Register'),
      },
    );
  }
}

class PlaceholderScreen extends StatelessWidget {
  final String title;
  const PlaceholderScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(child: Text(title)),
    );
  }
}

