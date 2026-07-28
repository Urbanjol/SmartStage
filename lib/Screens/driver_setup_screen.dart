import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DriverSetupScreen extends StatefulWidget {
  const DriverSetupScreen({Key? key}) : super(key: key);

  @override
  State<DriverSetupScreen> createState() => _DriverSetupScreenState();
}

class _DriverSetupScreenState extends State<DriverSetupScreen> {
  final _plateController = TextEditingController();
  final _capacityController = TextEditingController();
  final _routeController = TextEditingController();
  bool _isLoading = false;

  Future<void> _registerAsDriver() async {
    final plate = _plateController.text.trim();
    final capacity = int.tryParse(_capacityController.text.trim()) ?? 14;
    final routeInput = _routeController.text.trim();

    if (plate.isEmpty || routeInput.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser!;
      final route = routeInput.split(',').map((s) => s.trim()).toList();

      // Create matatu document
      final matatuRef =
      FirebaseFirestore.instance.collection('matatus').doc();
      await matatuRef.set({
        'plate': plate,
        'capacity': capacity,
        'seats_available': capacity,
        'route': route,
        'current_driver_id': user.uid,
        'status': 'IDLE',
        'seat_state': 'space_available',
        'owner_id': user.uid,
        'accepting_goods': false,
        'created_at': FieldValue.serverTimestamp(),
      });

      // Update user roles
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({
        'roles': FieldValue.arrayUnion(['driver', 'conductor']),
        'assigned_vehicle': matatuRef.id,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You are now a driver!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register as Driver')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(
              controller: _plateController,
              decoration: const InputDecoration(
                labelText: 'Vehicle Plate Number',
                hintText: 'e.g. UBA 123X',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _capacityController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Seat Capacity',
                hintText: 'e.g. 14',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _routeController,
              decoration: const InputDecoration(
                labelText: 'Route Stages (comma separated)',
                hintText: 'old_taxi_park, wandegeya, mukono',
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _registerAsDriver,
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('REGISTER AS DRIVER'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _plateController.dispose();
    _capacityController.dispose();
    _routeController.dispose();
    super.dispose();
  }
}