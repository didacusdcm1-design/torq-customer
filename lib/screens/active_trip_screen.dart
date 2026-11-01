import 'dart:async';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'chat_screen.dart';

class ActiveTripScreen extends StatefulWidget {
  final Map<String, dynamic> initialTrip;

  const ActiveTripScreen({super.key, required this.initialTrip});

  @override
  State<ActiveTripScreen> createState() => _ActiveTripScreenState();
}

class _ActiveTripScreenState extends State<ActiveTripScreen> {
  Map<String, dynamic>? _trip;
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    _trip = widget.initialTrip;
    // Poll every 5 seconds for status updates
    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _fetchTripStatus();
    });
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchTripStatus() async {
    try {
      final updatedTrip = await ApiService.getCustomerActiveTrip();
      if (mounted) {
        if (updatedTrip != null) {
          setState(() => _trip = updatedTrip);
        } else {
          // If backend returns null, the trip might be completed.
          // We will only navigate away if we are sure it's done.
          // For now, let's just keep the current trip to prevent UI glitching.
        }
      }
    } catch (e) {
      // Ignore network errors during polling to prevent screen from crashing
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_trip == null) return const Scaffold(backgroundColor: Color(0xFF0A0A0A), body: Center(child: CircularProgressIndicator()));

    final status = _trip!['status'] ?? 'REQUESTED';
    final rider = _trip!['rider'];
    final riderProfile = rider != null ? rider['riderProfile'] : null;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: SafeArea(
        child: Column(
          children: [
            // Top Status Bar
            Container(
              padding: const EdgeInsets.all(20),
              color: const Color(0xFF1E1E1E),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _getStatusText(status),
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),

            // Driver Info Card (Only shows if rider is assigned)
            if (rider != null)
              Container(
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFFCD34D), width: 1),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: const Color(0xFFFCD34D),
                      child: Text(
                        riderProfile?['fullName']?.substring(0, 1) ?? 'R',
                        style: const TextStyle(color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(riderProfile?['fullName'] ?? 'Your Rider', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                          Text("${riderProfile?['bikeMake'] ?? ''} ${riderProfile?['bikeModel'] ?? ''} • ${riderProfile?['bikeReg'] ?? ''}", style: const TextStyle(color: Colors.grey, fontSize: 14)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFCD34D),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _trip!['pickupPin'] ?? '----',
                        style: const TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 2),
                      ),
                    )
                  ],
                ),
              ),

            // Searching for rider animation (Only shows if no rider yet)
            if (rider == null)
              const Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: Color(0xFFFCD34D)),
                      SizedBox(height: 24),
                      Text("Finding a rider near you...", style: TextStyle(color: Colors.white, fontSize: 18)),
                    ],
                  ),
                ),
              ),

            // Action Buttons & Trip Details (Only shows if rider is assigned)
            if (rider != null)
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      // ACTION BUTTONS GRID
                      Row(
                        children: [
                          Expanded(
                            child: _buildActionButton(
                              icon: Icons.chat_bubble_outline,
                              label: "Chat Driver",
                              color: const Color(0xFFFCD34D),
                              onTap: () {
                                if (rider != null && riderProfile != null) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ChatScreen(
                                        tripId: _trip!['id'],
                                        senderId: _trip!['customerId'],
                                        receiverId: rider['id'],
                                        driverName: riderProfile['fullName'] ?? 'Driver',
                                      ),
                                    ),
                                  );
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildActionButton(
                              icon: Icons.phone_outlined,
                              label: "Call Driver",
                              color: const Color(0xFFFCD34D),
                              onTap: () {},
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildActionButton(
                              icon: Icons.share_outlined,
                              label: "Share Trip",
                              color: const Color(0xFFFCD34D),
                              onTap: () {},
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildActionButton(
                              icon: Icons.emergency,
                              label: "SOS Emergency",
                              color: Colors.red,
                              isSOS: true,
                              onTap: () {},
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Timeline
                      _buildTimelineStep("Pickup", "Lat: ${_trip!['pickupLat']}, Lng: ${_trip!['pickupLng']}", true),
                      _buildTimelineLine(),
                      _buildTimelineStep("Destination", "Lat: ${_trip!['dropoffLat']}, Lng: ${_trip!['dropoffLng']}", false),
                      const SizedBox(height: 24),

                      // Fare
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFCD34D).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Total Fare", style: TextStyle(color: Colors.grey, fontSize: 16)),
                            Text("KES ${_trip!['estimatedFare']}", style: const TextStyle(color: Color(0xFFFCD34D), fontSize: 24, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'REQUESTED': return "Finding a rider...";
      case 'ACCEPTED': return "Rider is on the way";
      case 'IN_PROGRESS': return "Rider is arriving";
      case 'ARRIVED_AT_PICKUP': return "Rider has arrived";
      case 'IN_PROGRESS_DEST': return "On the way to destination";
      default: return "Trip Status";
    }
  }

  Widget _buildTimelineStep(String title, String subtitle, bool isPickup) {
    return Row(
      children: [
        Icon(isPickup ? Icons.location_on : Icons.flag, color: isPickup ? Colors.green : Colors.red, size: 24),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        )
      ],
    );
  }

  Widget _buildTimelineLine() {
    return Padding(
      padding: const EdgeInsets.only(left: 11),
      child: Container(
        height: 30,
        width: 2,
        color: Colors.grey[800],
      ),
    );
  }

  Widget _buildActionButton({required IconData icon, required String label, required Color color, required VoidCallback onTap, bool isSOS = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: isSOS ? color.withOpacity(0.2) : const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isSOS ? color : Colors.grey.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: isSOS ? color : const Color(0xFFFCD34D), size: 28),
            const SizedBox(height: 8),
            Text(label, style: TextStyle(color: isSOS ? color : Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
          ],
        ),
      ),
    );
  }
}