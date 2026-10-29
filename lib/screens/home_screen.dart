import 'package:flutter/material.dart';
import '../services/api_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _destinationController = TextEditingController();
  bool _isRequesting = false;

  void _requestRide() async {
    if (_destinationController.text.isEmpty) return;

    setState(() => _isRequesting = true);

    // Simulated coordinates for testing (Pickup: Westlands, Dropoff: JKIA)
    final result = await ApiService.requestTrip(
      pickupLat: -1.2635, 
      pickupLng: 36.8027,
      dropoffLat: -1.3192, 
      dropoffLng: 36.9276,
      distanceKm: 10,
      durationMins: 20
    );

    setState(() => _isRequesting = false);

    if (result['success']) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Ride Requested! PIN: ${result['pickupPin']}"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed: ${result['message']}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Stack(
        children: [
          // 1. MAP PLACEHOLDER
          Positioned.fill(
            child: Container(
              color: Colors.grey[300],
              child: const Center(
                child: Text(
                  "Interactive Map\n(Coming soon)",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, fontSize: 18),
                ),
              ),
            ),
          ),

          // 2. TOP BAR
          Positioned(
            top: 50,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: const Row(
                children: [
                  Icon(Icons.menu, color: Colors.black),
                  SizedBox(width: 16),
                  Text("Where to?", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
          ),

          // 3. BOTTOM BOOKING SHEET
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(color: Colors.black12, blurRadius: 20, offset: Offset(0, -5)),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text("Enter Destination", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _destinationController,
                    decoration: InputDecoration(
                      hintText: "e.g., JKIA Terminal 1A",
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon: const Icon(Icons.location_on, color: Color(0xFFFCD34D)),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _isRequesting ? null : _requestRide,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFCD34D),
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _isRequesting
                        ? const CircularProgressIndicator(color: Colors.black)
                        : const Text("Request TORQ", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}