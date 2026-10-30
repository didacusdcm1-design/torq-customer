import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'active_trip_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _destinationController = TextEditingController();
  bool _isRequesting = false;
  bool _showBookingSheet = false;
  double _estimatedFare = 0.0;

  void _calculateFare() {
    // Mock fare calculation: Base 50 + (Distance * 30). Assuming 10km.
    if (_destinationController.text.isNotEmpty) {
      setState(() {
        _estimatedFare = 50.0 + (10 * 30.0);
        _showBookingSheet = true;
      });
    }
  }

  Future<void> _requestRide() async {
    if (_destinationController.text.isEmpty) return;
    setState(() => _isRequesting = true);

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
        setState(() {
          _showBookingSheet = false;
          _destinationController.clear();
        });
        // Navigate to the Active Trip Screen
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ActiveTripScreen(initialTrip: result['trip'])),
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
          // 1. MAP BACKGROUND
          Positioned.fill(
            child: Image.asset(
              'assets/map_bg.jpg',
              fit: BoxFit.cover,
              color: Colors.black.withOpacity(0.1), // Subtle dark overlay for contrast
              colorBlendMode: BlendMode.darken,
            ),
          ),

          // 2. TOP FLOATING SEARCH BAR
          Positioned(
            top: 50,
            left: 20,
            right: 20,
            child: GestureDetector(
              onTap: () {
                setState(() => _showBookingSheet = true);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
                    Text("Where to?", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black)),
                  ],
                ),
              ),
            ),
          ),

          // 3. BOTTOM BOOKING SHEET (Shows when _showBookingSheet is true)
          if (_showBookingSheet)
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
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Enter Destination", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.grey),
                          onPressed: () => setState(() => _showBookingSheet = false),
                        )
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Search Input
                    TextField(
                      controller: _destinationController,
                      onChanged: (_) => _calculateFare(),
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
                    const SizedBox(height: 16),

                    // Saved Places
                    Row(
                      children: [
                        _buildSavedPlace(Icons.home, "Home", "Westlands"),
                        const SizedBox(width: 12),
                        _buildSavedPlace(Icons.work, "Work", "CBD"),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Fare Estimate (Shows when text is entered)
                    if (_estimatedFare > 0)
                      Container(
                        padding: const EdgeInsets.all(16),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFCD34D).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFFCD34D)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Estimated Fare:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                            Text("KES ${_estimatedFare.toStringAsFixed(2)}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
                          ],
                        ),
                      ),

                    // Request Button
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
                          : const Text("CONFIRM TORQ RIDE", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSavedPlace(IconData icon, String title, String subtitle) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          _destinationController.text = subtitle;
          _calculateFare();
        },
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(icon, color: Colors.grey[600], size: 20),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
