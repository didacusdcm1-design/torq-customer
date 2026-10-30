import 'package:flutter/material.dart';

class AlertsScreen extends StatelessWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(title: const Text("Alerts", style: TextStyle(color: Colors.white)), backgroundColor: const Color(0xFF1E1E1E)),
      body: const Center(child: Text("Notifications (Coming soon)", style: TextStyle(color: Colors.grey))),
    );
  }
}