import 'package:flutter/material.dart';
import 'services/auth_service.dart';
import 'services/trip_service.dart';

void main() { runApp(const TorqApp()); }

class TorqApp extends StatelessWidget {
  const TorqApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TORQ Customer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1E3A8A), primary: const Color(0xFF1E3A8A)),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}
class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E3A8A),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.directions_car, size: 100, color: Colors.white),
            const SizedBox(height: 20),
            const Text('TORQ', style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 8)),
            const SizedBox(height: 20),
            const CircularProgressIndicator(color: Colors.white),
          ],
        ),
      ),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}
class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;

  void _handleLogin() async {
    setState(() => _isLoading = true);
    final token = await _authService.login(_emailController.text, _passwordController.text);
    setState(() => _isLoading = false);
    if (token != null && mounted) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MainNavigation(token: token)));
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invalid email or password'), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.local_taxi, size: 80, color: Color(0xFF1E3A8A)),
              const SizedBox(height: 20),
              const Text('Welcome Back', textAlign: TextAlign.center, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 40),
              TextField(controller: _emailController, decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email)), keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 16),
              TextField(controller: _passwordController, decoration: const InputDecoration(labelText: 'Password', prefixIcon: Icon(Icons.lock)), obscureText: true),
              const SizedBox(height: 30),
              _isLoading ? const Center(child: CircularProgressIndicator()) : ElevatedButton(onPressed: _handleLogin, child: const Text('Login', style: TextStyle(fontSize: 18))),
            ],
          ),
        ),
      ),
    );
  }
}

class MainNavigation extends StatefulWidget {
  final String token;
  const MainNavigation({super.key, required this.token});
  @override
  State<MainNavigation> createState() => _MainNavigationState();
}
class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;
  @override
  Widget build(BuildContext context) {
    final screens = [HomeTab(token: widget.token), const HistoryTab(), const ProfileTab()];
    return Scaffold(
      body: screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.history), label: 'History'),
          NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

class HomeTab extends StatefulWidget {
  final String token;
  const HomeTab({super.key, required this.token});
  @override
  State<HomeTab> createState() => _HomeTabState();
}
class _HomeTabState extends State<HomeTab> {
  final _tripService = TripService();
  List<dynamic> _trips = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTrips();
  }

  void _loadTrips() async {
    setState(() => _isLoading = true);
    final trips = await _tripService.getTripHistory(widget.token);
    setState(() {
      _trips = trips;
      _isLoading = false;
    });
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'REQUESTED': return Colors.orange;
      case 'ACCEPTED': return Colors.blue;
      case 'ARRIVED': return Colors.purple;
      case 'IN_PROGRESS': return Colors.teal;
      case 'COMPLETED': return Colors.green;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard', style: TextStyle(fontWeight: FontWeight.bold)), backgroundColor: Colors.white, elevation: 0),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(context, MaterialPageRoute(builder: (context) => CreateTripScreen(token: widget.token)));
          _loadTrips();
        },
        icon: const Icon(Icons.add), label: const Text('Request Trip'), backgroundColor: const Color(0xFF1E3A8A), foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(padding: const EdgeInsets.all(16.0), child: Text('Recent Activity', style: Theme.of(context).textTheme.titleLarge)),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _trips.isEmpty
                    ? const Center(child: Text('No trips requested yet.', style: TextStyle(color: Colors.grey)))
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _trips.length,
                        itemBuilder: (context, index) {
                          final trip = _trips[index];
                          final fare = double.tryParse(trip['estimatedFare']?.toString() ?? '0.0') ?? 0.0;
                          final status = trip['status'] ?? 'REQUESTED';
                          
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            elevation: 2,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(16),
                              leading: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(color: _getStatusColor(status).withOpacity(0.1), shape: BoxShape.circle),
                                child: Icon(Icons.directions_car, color: _getStatusColor(status)),
                              ),
                              title: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Trip #${trip['id'].toString().substring(0, 8)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(color: _getStatusColor(status).withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                                    child: Text(status, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: _getStatusColor(status))),
                                  ),
                                ],
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('📍 ${trip['pickupLat'].toString()}, ${trip['pickupLng'].toString()}'),
                                    Text('🏁 ${trip['dropoffLat'].toString()}, ${trip['dropoffLng'].toString()}'),
                                    const SizedBox(height: 4),
                                    Text('Fare: KES ${fare.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

class HistoryTab extends StatelessWidget { const HistoryTab({super.key}); @override Widget build(BuildContext context) { return Scaffold(appBar: AppBar(title: const Text('Full History')), body: const Center(child: Text('All past trips will appear here.'))); } }
class ProfileTab extends StatelessWidget { const ProfileTab({super.key}); @override Widget build(BuildContext context) { return Scaffold(appBar: AppBar(title: const Text('Profile')), body: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [const CircleAvatar(radius: 50, backgroundColor: Color(0xFF1E3A8A), child: Icon(Icons.person, size: 50, color: Colors.white)), const SizedBox(height: 20), const Text('Chad', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)), const SizedBox(height: 8), const Text('chad@torq.com', style: TextStyle(color: Colors.grey)), const SizedBox(height: 40), OutlinedButton(onPressed: () => Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const LoginScreen()), (route) => false), child: const Text('Log Out', style: TextStyle(color: Colors.red)))]))); } }

class CreateTripScreen extends StatefulWidget {
  final String token;
  const CreateTripScreen({super.key, required this.token});
  @override
  State<CreateTripScreen> createState() => _CreateTripScreenState();
}
class _CreateTripScreenState extends State<CreateTripScreen> {
  final _pickupLatController = TextEditingController(text: '-1.286389');
  final _pickupLngController = TextEditingController(text: '36.817223');
  final _dropoffLatController = TextEditingController(text: '-1.292066');
  final _dropoffLngController = TextEditingController(text: '36.821945');
  final _tripService = TripService();
  bool _isLoading = false;

  void _submitTrip() async {
    setState(() => _isLoading = true);
    final success = await _tripService.requestTrip(widget.token, double.parse(_pickupLatController.text), double.parse(_pickupLngController.text), double.parse(_dropoffLatController.text), double.parse(_dropoffLngController.text));
    setState(() => _isLoading = false);
    if (success && mounted) {
      Navigator.pop(context);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to request trip.'), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Where to?')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Pickup Location', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            Row(children: [Expanded(child: TextField(controller: _pickupLatController, decoration: const InputDecoration(labelText: 'Latitude'))), const SizedBox(width: 12), Expanded(child: TextField(controller: _pickupLngController, decoration: const InputDecoration(labelText: 'Longitude')))]),
            const SizedBox(height: 24),
            const Text('Dropoff Location', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            Row(children: [Expanded(child: TextField(controller: _dropoffLatController, decoration: const InputDecoration(labelText: 'Latitude'))), const SizedBox(width: 12), Expanded(child: TextField(controller: _dropoffLngController, decoration: const InputDecoration(labelText: 'Longitude')))]),
            const SizedBox(height: 40),
            _isLoading ? const Center(child: CircularProgressIndicator()) : ElevatedButton(onPressed: _submitTrip, child: const Text('Confirm Ride', style: TextStyle(fontSize: 18))),
          ],
        ),
      ),
    );
  }
}
