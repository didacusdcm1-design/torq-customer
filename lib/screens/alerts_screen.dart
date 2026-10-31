import 'package:flutter/material.dart';

class AlertsScreen extends StatelessWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        title: const Text("Alerts", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF0A0A0A),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildAlertCard("Promotion", "Get 20% off your next ride!", "Use code TORQ20. Valid until Sunday.", Icons.local_offer, const Color(0xFFFCD34D)),
          _buildAlertCard("Trip Update", "Your rider is arriving.", "John Doe is 2 minutes away.", Icons.directions_bike, Colors.green),
          _buildAlertCard("Safety", "New Safety Features", "You can now share your trip with trusted contacts.", Icons.shield, Colors.blue),
        ],
      ),
    );
  }

  Widget _buildAlertCard(String type, String title, String body, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
        border: Border(left: BorderSide(color: color, width: 4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(type, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(body, style: const TextStyle(color: Colors.grey, fontSize: 14)),
              ],
            ),
          )
        ],
      ),
    );
  }
}