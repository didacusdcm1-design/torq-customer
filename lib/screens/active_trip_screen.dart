import 'dart:async';
import 'package:flutter/material.dart';
import '../services/api_service.dart';

class ActiveTripScreen extends StatefulWidget {
  final Map<String, dynamic> initialTrip;

  const ActiveTripScreen({super.key, required this.initialTrip});

  @override
  State<ActiveTripScreen> createState() => _ActiveTripScreenState();
}

class _ActiveTripScreenState extends State<ActiveTripScreen> {
  Map<String, dynamic>? _trip;
  Timer? _pollingTimer;
  bool _isLoading = false;

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
    final updatedTrip = await ApiService.getCustomerActiveTrip();
    if (mounted) {
      if (updatedTrip != null) {
        setState(() => _trip = updatedTrip);
      } else {
        // Trip is completed or cancelled
        _pollingTimer?.cancel();
        Navigator.pushReplacementNamed(context, '/home');
      }
    }
  }

  Future<void> _cancelTrip() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text("Cancel Trip?", style: TextStyle(color: Colors.white)),
        content: const Text("Are you sure you want to cancel this ride?", style: TextStyle(color: Colors.grey)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("No", style: TextStyle(color: Colors.grey))),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Yes, Cancel", style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _isLoading = true);
      await ApiService.cancelTrip(_trip!['id'], 'CUSTOMER', 'Customer requested cancellation', '');
      if (mounted) {
        _pollingTimer?.cancel();
        Navigator.pushReplacementNamed(context, '/home');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_trip == null) return const Scaffold(backgroundColor: Color(0xFF0A0A0A), body: Center(child: CircularProgressIndicator()));

    final status = _trip!['status'];
    final rider = _trip!['rider']; // Can be null if no rider accepted yet
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
                  if (status != 'IN_PROGRESS_DEST' && status != 'COMPLETED')
                    TextButton(
                      onPressed: _isLoading ? null : _cancelTrip,
                      child: const Text("Cancel", style: TextStyle(color: Colors.redAccent)),
                    )
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

            // Searching for rider animation
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

            // Trip Details (Only shows if rider is assigned)
            if (rider != null)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      _buildTimelineStep("Pickup", "Lat: ${_trip!['pickupLat']}, Lng: ${_trip!['pickupLng']}", true),
                      _buildTimelineLine(),
                      _buildTimelineStep("Destination", "Lat: ${_trip!['dropoffLat']}, Lng: ${_trip!['dropoffLng']}", false),
                      const Spacer(),
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
        height: 40,
        width: 2,
        color: Colors.grey[800],
      ),
    );
  }
}