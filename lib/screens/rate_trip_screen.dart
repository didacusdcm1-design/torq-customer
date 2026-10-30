import 'package:flutter/material.dart';
import '../services/api_service.dart';

class RateTripScreen extends StatefulWidget {
  final String tripId;
  final String driverName;
  final double fare;

  const RateTripScreen({super.key, required this.tripId, required this.driverName, required this.fare});

  @override
  State<RateTripScreen> createState() => _RateTripScreenState();
}

class _RateTripScreenState extends State<RateTripScreen> {
  int _rating = 0;
  bool _isSubmitting = false;

  void _submitRating() async {
    if (_rating == 0) return;
    setState(() => _isSubmitting = true);

    final result = await ApiService.rateTrip(widget.tripId, _rating);

    if (mounted) {
      setState(() => _isSubmitting = false);
      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Thank you for your feedback!"), backgroundColor: Colors.green),
        );
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${result['message']}"), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 80),
              const SizedBox(height: 24),
              const Text("YOUR TORQ RIDE IS COMPLETE", textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text("Fare: KES ${widget.fare.toStringAsFixed(2)}", textAlign: TextAlign.center, style: const TextStyle(color: Color(0xFFFCD34D), fontSize: 20, fontWeight: FontWeight.bold)),
              
              const SizedBox(height: 48),
              const Text("How was your ride with ${widget.driverName}?", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontSize: 16)),
              const SizedBox(height: 24),
              
              // Star Rating
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return IconButton(
                    icon: Icon(
                      index < _rating ? Icons.star : Icons.star_border,
                      color: const Color(0xFFFCD34D),
                      size: 48,
                    ),
                    onPressed: () => setState(() => _rating = index + 1),
                  );
                }),
              ),
              
              const Spacer(),
              ElevatedButton(
                onPressed: _rating == 0 || _isSubmitting ? null : _submitRating,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFCD34D),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isSubmitting 
                  ? const CircularProgressIndicator(color: Colors.black)
                  : const Text("SUBMIT RATING", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}