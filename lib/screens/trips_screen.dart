import 'package:flutter/material.dart';

class TripsScreen extends StatelessWidget {
  const TripsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        title: const Text("My Trips", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF0A0A0A),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildTripCard("TRQ-8832", "Westlands", "JKIA Terminal 1A", "KES 1,500", "COMPLETED", true),
          _buildTripCard("TRQ-7712", "Karen", "CBD", "KES 450", "CANCELLED", false),
          _buildTripCard("TRQ-6651", "Kilimani", "Yaya Centre", "KES 300", "COMPLETED", true),
        ],
      ),
    );
  }

  Widget _buildTripCard(String id, String pickup, String dest, String fare, String status, bool isCompleted) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(id, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isCompleted ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  status,
                  style: TextStyle(color: isCompleted ? Colors.green : Colors.red, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              )
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.location_on, color: Colors.green, size: 16),
              const SizedBox(width: 8),
              Text(pickup, style: const TextStyle(color: Colors.white, fontSize: 14)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.flag, color: Colors.red, size: 16),
              const SizedBox(width: 8),
              Text(dest, style: const TextStyle(color: Colors.white, fontSize: 14)),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: Colors.grey, height: 1),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(fare, style: const TextStyle(color: Color(0xFFFCD34D), fontSize: 18, fontWeight: FontWeight.bold)),
              if (isCompleted)
                TextButton(
                  onPressed: () {},
                  child: const Text("Rate Trip", style: TextStyle(color: Colors.blueAccent, fontSize: 12)),
                )
            ],
          )
        ],
      ),
    );
  }
}