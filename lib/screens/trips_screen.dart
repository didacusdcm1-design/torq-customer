import 'package:flutter/material.dart';
import '../services/api_service.dart';

class TripsScreen extends StatefulWidget {
  const TripsScreen({super.key});

  @override
  State<TripsScreen> createState() => _TripsScreenState();
}

class _TripsScreenState extends State<TripsScreen> {
  List<dynamic> _trips = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() => _isLoading = true);
    final trips = await ApiService.getCustomerHistory();
    if (mounted) {
      setState(() {
        _trips = trips;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        title: const Text("My Trips", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF0A0A0A),
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.refresh, color: Color(0xFFFCD34D)), onPressed: _loadHistory)
        ],
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: Color(0xFFFCD34D)))
        : _trips.isEmpty 
          ? const Center(child: Text("No trips yet.", style: TextStyle(color: Colors.grey)))
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: _trips.length,
              itemBuilder: (context, index) {
                final trip = _trips[index];
                final isCompleted = trip['status'] == 'COMPLETED';
                
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
                          Text("TRQ-${trip['id'].substring(0, 4)}", style: const TextStyle(color: Colors.grey, fontSize: 12)),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: isCompleted ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              trip['status'],
                              style: TextStyle(color: isCompleted ? Colors.green : Colors.red, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          )
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(children: [
                        const Icon(Icons.location_on, color: Colors.green, size: 16),
                        const SizedBox(width: 8),
                        Text("Lat: ${trip['pickupLat']}, Lng: ${trip['pickupLng']}", style: const TextStyle(color: Colors.white, fontSize: 14)),
                      ]),
                      const SizedBox(height: 8),
                      Row(children: [
                        const Icon(Icons.flag, color: Colors.red, size: 16),
                        const SizedBox(width: 8),
                        Text("Lat: ${trip['dropoffLat']}, Lng: ${trip['dropoffLng']}", style: const TextStyle(color: Colors.white, fontSize: 14)),
                      ]),
                      const SizedBox(height: 16),
                      const Divider(color: Colors.grey, height: 1),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("KES ${trip['estimatedFare']}", style: const TextStyle(color: Color(0xFFFCD34D), fontSize: 18, fontWeight: FontWeight.bold)),
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
              },
            ),
    );
  }
}