import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../Config/theme.dart';

class DriverSetupScreen extends ConsumerStatefulWidget {
  const DriverSetupScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<DriverSetupScreen> createState() => _DriverSetupScreenState();
}

class _DriverSetupScreenState extends ConsumerState<DriverSetupScreen> {
  final TextEditingController _destinationController = TextEditingController();
  final TextEditingController _plateController = TextEditingController();
  final TextEditingController _seatsController = TextEditingController();

  List<String> _route = [];
  bool _isLoading = false;
  bool _routeReady = false;

  Future<void> _generateRoute() async {
    final destination = _destinationController.text.trim();
    if (destination.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enter destination'),
          backgroundColor: SmartStageColors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final callable =
      FirebaseFunctions.instance.httpsCallable('autoFillRoute');
      final result = await callable.call({
        'origin': 'Old Taxi Park', // Will be replaced by GPS later
        'destination': destination,
      });

      final data = result.data as Map<String, dynamic>;
      final route = (data['route'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList();

      setState(() {
        _route = route;
        _routeReady = true;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed: $e'),
          backgroundColor: SmartStageColors.red,
        ),
      );
    }
  }

  Future<void> _confirmRoute() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final taxiRef =
      FirebaseFirestore.instance.collection('taxis').doc();

      await taxiRef.set({
        'plate': _plateController.text.trim(),
        'status': 'LOADING',
        'seat_state': 'space_available',
        'seats_available': int.tryParse(_seatsController.text.trim()) ?? 14,
        'capacity': int.tryParse(_seatsController.text.trim()) ?? 14,
        'vehicle_type': 'taxi',
        'route': _route,
        'current_location':
        const GeoPoint(0.3136, 32.5811),
        'driver_name': user.uid,
        'created_at': FieldValue.serverTimestamp(),
      });

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({
        'assigned_vehicle': taxiRef.id,
      });

      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('DRIVER SETUP'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E293B),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Set Up Your Taxi',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _plateController,
              decoration: const InputDecoration(
                labelText: 'Taxi Plate (e.g. UBA 123X)',
                prefixIcon: Icon(Icons.directions_bus),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _seatsController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Number of Seats',
                prefixIcon: Icon(Icons.event_seat),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _destinationController,
              decoration: const InputDecoration(
                labelText: 'Destination (e.g. Mukono)',
                prefixIcon: Icon(Icons.flag),
              ),
            ),
            const SizedBox(height: 20),
            GlowButton(
              text: 'GENERATE ROUTE',
              color: SmartStageColors.primaryBlue,
              glowColor: SmartStageColors.primaryBlue.withOpacity(0.4),
              onPressed: _generateRoute,
            ),
            if (_routeReady) ...[
              const SizedBox(height: 20),
              const Text(
                'Suggested Route:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: SmartStageColors.primaryBlue.withOpacity(0.2),
                  ),
                ),
                child: Column(
                  children: _route.map((stage) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.place,
                            size: 18,
                            color: SmartStageColors.primaryBlue,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            stage,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 20),
              GlowButton(
                text: 'CONFIRM ROUTE',
                color: const Color(0xFF10B981),
                glowColor: const Color(0xFF10B981).withOpacity(0.4),
                onPressed: _confirmRoute,
              ),
            ],
          ],
        ),
      ),
    );
  }
}