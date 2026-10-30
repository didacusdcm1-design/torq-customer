import 'package:flutter/material.dart';

class TripsScreen extends StatelessWidget {
  const TripsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(title: const Text("My Trips", style: TextStyle(color: Colors.white)), backgroundColor: const Color(0xFF1E1E1E)),
      body: const Center(child: Text("Trip History (Coming soon)", style: TextStyle(color: Colors.grey))),
    );
  }
}