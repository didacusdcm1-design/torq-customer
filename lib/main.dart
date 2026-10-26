import 'package:flutter/material.dart';
import 'services/auth_service.dart';
import 'services/trip_service.dart';

void main() { runApp(const TorqCustomerApp()); }

class TorqCustomerApp extends StatelessWidget {
  const TorqCustomerApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TORQ Customer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF8F9FA),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0B121B), primary: const Color(0xFF0B121B), secondary: const Color(0xFFFFBD19)),
        useMaterial3: true,
        fontFamily: 'Inter',
        elevatedButtonTheme: ElevatedButtonThemeData(style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFFBD19), foregroundColor: const Color(0xFF0B121B), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.symmetric(vertical: 16), textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
        inputDecorationTheme: InputDecorationTheme(filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFFFBD19), width: 2))),
      ),
      home: const LoginScreen(),
    );
  }
}

class LoginScreen extends StatefulWidget { const LoginScreen({super.key}); @override State<LoginScreen> createState() => _LoginScreenState(); }
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
    return Scaffold(body: SafeArea(child: Padding(padding: const EdgeInsets.all(24.0), child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      const Icon(Icons.electric_bolt, size: 80, color: Color(0xFFFFBD19)),
      const SizedBox(height: 10),
      const Text('TORQ', textAlign: TextAlign.center, style: TextStyle(fontSize: 48, fontWeight: FontWeight.w900, color: Color(0xFF0B121B), letterSpacing: 2)),
      const SizedBox(height: 40),
      TextField(controller: _emailController, decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email)), keyboardType: TextInputType.emailAddress),
      const SizedBox(height: 16),
      TextField(controller: _passwordController, decoration: const InputDecoration(labelText: 'Password', prefixIcon: Icon(Icons.lock)), obscureText: true),
      const SizedBox(height: 30),
      _isLoading ? const Center(child: CircularProgressIndicator()) : ElevatedButton(onPressed: _handleLogin, child: const Text('Sign In')),
    ]))));
  }
}

class MainNavigation extends StatefulWidget {
  final String token;
  const MainNavigation({super.key, required this.token});
  @override State<MainNavigation> createState() => _MainNavigationState();
}
class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;
  @override
  Widget build(BuildContext context) {
    final screens = [HomeTab(token: widget.token), const HistoryTab(), ProfileTab(token: widget.token)];
    return Scaffold(
      body: screens[_currentIndex],
      bottomNavigationBar: NavigationBar(selectedIndex: _currentIndex, onDestinationSelected: (index) => setState(() => _currentIndex = index), backgroundColor: Colors.white, indicatorColor: const Color(0xFFFFBD19).withOpacity(0.3), destinations: const [
        NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
        NavigationDestination(icon: Icon(Icons.history), label: 'History'),
        NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
      ]),
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
    
    // CONNECT TO WEBSOCKET FOR LIVE UPDATES
    _tripService.connectWebSocket((newTripData) {
      setState(() {
        // Find the trip in the list and update it, or add it if it's new
        int index = _trips.indexWhere((t) => t['id'] == newTripData['id']);
        if (index != -1) {
          _trips[index] = newTripData;
        } else {
          _trips.insert(0, newTripData);
        }
      });
    });
  }

  @override
  void dispose() {
    _tripService.socket.disconnect();
    super.dispose();
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
      appBar: AppBar(title: const Text('TORQ Dashboard', style: TextStyle(fontWeight: FontWeight.bold)), backgroundColor: const Color(0xFF0B121B), foregroundColor: Colors.white),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(context, MaterialPageRoute(builder: (context) => CreateTripScreen(token: widget.token)));
          _loadTrips();
        },
        icon: const Icon(Icons.add), label: const Text('Request Trip'), backgroundColor: const Color(0xFFFFBD19), foregroundColor: const Color(0xFF0B121B),
      ),
      body: Column(children: [
        const Padding(padding: EdgeInsets.all(20.0), child: Text('Recent Activity', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
        Expanded(child: _isLoading ? const Center(child: CircularProgressIndicator()) : _trips.isEmpty ? const Center(child: Text('No trips requested yet.')) : ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16), itemCount: _trips.length, itemBuilder: (context, index) {
            final trip = _trips[index]; final fare = double.tryParse(trip['estimatedFare']?.toString() ?? '0.0') ?? 0.0; final status = trip['status'] ?? 'REQUESTED';
            return Card(margin: const EdgeInsets.only(bottom: 12), child: Padding(padding: const EdgeInsets.all(16.0), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [ Text('Trip #${trip['id'].toString().substring(0, 8)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)), Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: _getStatusColor(status).withOpacity(0.1), borderRadius: BorderRadius.circular(20)), child: Text(status, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: _getStatusColor(status)))) ]),
              const SizedBox(height: 12),
              Text('Fare: KSh ${fare.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 14)),
            ])));
          },
        )),
      ]),
    );
  }
}

class HistoryTab extends StatelessWidget { const HistoryTab({super.key}); @override Widget build(BuildContext context) { return Scaffold(appBar: AppBar(title: const Text('Full History')), body: const Center(child: Text('All past trips will appear here.'))); } }

// --- UPDATED PROFILE TAB WITH SUPPORT OPTIONS ---
class ProfileTab extends StatelessWidget {
  final String token;
  const ProfileTab({super.key, required this.token});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile'), backgroundColor: const Color(0xFF0B121B), foregroundColor: Colors.white),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Center(
            child: Column(
              children: [
                CircleAvatar(radius: 50, backgroundColor: Color(0xFF0B121B), child: Icon(Icons.person, size: 50, color: Color(0xFFFFBD19))),
                SizedBox(height: 16),
                Text('Chad', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                Text('chad@torq.com', style: TextStyle(color: Colors.grey)),
                SizedBox(height: 24),
              ],
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.support_agent, color: Color(0xFF0B121B)),
            title: const Text('Customer Care'),
            subtitle: const Text('Call +254 700 000 000'),
            trailing: const Icon(Icons.phone, color: Colors.green),
            onTap: () { /* Launch phone dialer */ },
          ),
          ListTile(
            leading: const Icon(Icons.feedback_outlined, color: Color(0xFF0B121B)),
            title: const Text('Suggestion Box'),
            subtitle: const Text('Tell us how we can improve'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () { /* Show feedback dialog */ },
          ),
          ListTile(
            leading: const Icon(Icons.shield_outlined, color: Color(0xFF0B121B)),
            title: const Text('Safety Center'),
            subtitle: const Text('Emergency and safety guidelines'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () { /* Open safety page */ },
          ),
          const Divider(),
          const SizedBox(height: 20),
          OutlinedButton(
            style: OutlinedButton.styleFrom(foregroundColor: Colors.red, side: const BorderSide(color: Colors.red)),
            onPressed: () => Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const LoginScreen()), (route) => false),
            child: const Text('Log Out'),
          ),
        ],
      ),
    );
  }
}

class CreateTripScreen extends StatefulWidget { final String token; const CreateTripScreen({super.key, required this.token}); @override State<CreateTripScreen> createState() => _CreateTripScreenState(); }
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
    if (success && mounted) { Navigator.pop(context); } else if (mounted) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to request trip.'), backgroundColor: Colors.red)); }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Where to?'), backgroundColor: const Color(0xFF0B121B), foregroundColor: Colors.white),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          const Text('Pickup Location', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          Row(children: [Expanded(child: TextField(controller: _pickupLatController, decoration: const InputDecoration(labelText: 'Latitude'))), const SizedBox(width: 12), Expanded(child: TextField(controller: _pickupLngController, decoration: const InputDecoration(labelText: 'Longitude')))]),
          const SizedBox(height: 24),
          const Text('Dropoff Location', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          Row(children: [Expanded(child: TextField(controller: _dropoffLatController, decoration: const InputDecoration(labelText: 'Latitude'))), const SizedBox(width: 12), Expanded(child: TextField(controller: _dropoffLngController, decoration: const InputDecoration(labelText: 'Longitude')))]),
          const SizedBox(height: 40),
          _isLoading ? const Center(child: CircularProgressIndicator()) : ElevatedButton(onPressed: _submitTrip, child: const Text('Confirm Ride')),
        ]),
      ),
    );
  }
}

