import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:math';
import '../Config/theme.dart';
import '../Widgets/destination_card.dart';
import '../Widgets/nearby_driver_card.dart';

class PrivateHireScreen extends ConsumerStatefulWidget {
  const PrivateHireScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<PrivateHireScreen> createState() => _PrivateHireScreenState();
}

class _PrivateHireScreenState extends ConsumerState<PrivateHireScreen> {
  final TextEditingController _destinationController = TextEditingController();
  List<Map<String, dynamic>> _places = [];
  List<Map<String, dynamic>> _drivers = [];
  bool _isSearching = false;
  String? _errorMessage;

  static const double _originLat = 0.3136;
  static const double _originLng = 32.5811;

  @override
  void initState() {
    super.initState();
    _loadDrivers();
  }

  @override
  void dispose() {
    _destinationController.dispose();
    super.dispose();
  }

  double _calculateDistance(double lat1, double lng1, double lat2, double lng2) {
    const R = 6371;
    final dLat = _toRadians(lat2 - lat1);
    final dLng = _toRadians(lng2 - lng1);

    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) *
            cos(_toRadians(lat2)) *
            sin(dLng / 2) *
            sin(dLng / 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c;
  }

  double _toRadians(double degree) {
    return degree * pi / 180;
  }

  int _calculateFare(double distanceKm) {
    // Base fare 3000 UGX + 500 UGX per km
    return (3000 + (distanceKm * 500)).round();
  }

  Future<void> _loadDrivers() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('taxis')
          .where('status', whereIn: ['LOADING', 'EN_ROUTE'])
          .limit(10)
          .get();

      if (mounted) {
        setState(() {
          _drivers = snapshot.docs.map((doc) {
            final data = doc.data();
            return {
              'id': doc.id,
              'plate': data['plate'] ?? 'Unknown',
              'name': data['driver_name'] ?? 'Driver',
              'phone': data['driver_phone'] ?? '',
              'destination': (data['route'] as List?)?.isNotEmpty == true
                  ? data['route'].last
                  : 'Unknown',
            };
          }).toList();
        });
      }
    } catch (e) {
      // Silently fail
    }
  }

  Future<void> _searchPlaces(String query) async {
    if (query.trim().isEmpty) {
      setState(() => _errorMessage = 'Please enter a destination');
      return;
    }

    setState(() {
      _isSearching = true;
      _errorMessage = null;
      _places = [];
    });

    try {
      final callable =
      FirebaseFunctions.instance.httpsCallable('searchPlaces');
      final result = await callable.call({
        'query': query.trim(),
      });

      final data = result.data as Map<String, dynamic>;
      final places = data['places'] as List<dynamic>? ?? [];

      setState(() {
        _places = places
            .map((p) => Map<String, dynamic>.from(p as Map))
            .toList();
        _isSearching = false;

        if (_places.isEmpty) {
          _errorMessage = 'No places found for "$query"';
        }
      });
    } catch (e) {
      setState(() {
        _isSearching = false;
        _errorMessage = 'Search failed: $e';
      });
    }
  }

  Future<void> _bookDestination(Map<String, dynamic> place) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please login to book'),
          backgroundColor: SmartStageColors.red,
        ),
      );
      return;
    }

    final distance = _calculateDistance(
      _originLat,
      _originLng,
      (place['lat'] as num).toDouble(),
      (place['lng'] as num).toDouble(),
    );

    final fare = _calculateFare(distance);
    final destinationName = place['name'] ?? 'Unknown';

    try {
      final bookingRef =
      FirebaseFirestore.instance.collection('bookings').doc();

      await bookingRef.set({
        'bookingId': bookingRef.id,
        'passengerUid': user.uid,
        'pickUpAddress': 'Current Location',
        'destinationAddress': destinationName,
        'pickUph3': 'origin_h3',
        'destinationH3': 'destination_h3',
        'fareAmount': fare,
        'passengerCount': 1,
        'eventType': 'other',
        'status': 'searching',
        'paymentStatus': 'UNPAID',
        'bookingTime': DateTime.now().toIso8601String(),
        'created_at': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Text(
              'BOOKING SENT!',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: SmartStageColors.primaryBlue,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Your booking request has been sent to nearby drivers.',
                ),
                const SizedBox(height: 12),
                Text(
                  'Destination: $destinationName',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Estimated fare: UGX $fare',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF10B981),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'OK',
                  style: TextStyle(
                    color: SmartStageColors.primaryBlue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Booking failed: $e'),
            backgroundColor: SmartStageColors.red,
          ),
        );
      }
    }
  }

  Future<void> _callDriver(String phone) async {
    if (phone.isEmpty) return;

    final url = Uri.parse('tel:$phone');

    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  Future<void> _messageDriver(String phone) async {
    if (phone.isEmpty) return;

    final url = Uri.parse('sms:$phone');

    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('PRIVATE HIRE'),
        backgroundColor: const Color(0xFF1E293B),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _destinationController,
                decoration: const InputDecoration(
                  hintText: 'Where do you want to go?',
                  border: InputBorder.none,
                  prefixIcon: Icon(Icons.search),
                ),
                onSubmitted: _searchPlaces,
              ),
            ),
            const SizedBox(height: 8),

            // Error
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(
                    color: SmartStageColors.red,
                    fontSize: 13,
                  ),
                ),
              ),

            // Loading
            if (_isSearching)
              const Padding(
                padding: EdgeInsets.all(20),
                child: Center(
                  child: CircularProgressIndicator(
                    color: SmartStageColors.primaryBlue,
                  ),
                ),
              ),

            // Places Grid
            if (_places.isNotEmpty)
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.72,
                ),
                itemCount: _places.length,
                itemBuilder: (context, index) {
                  final place = _places[index];

                  final distance = _calculateDistance(
                    _originLat,
                    _originLng,
                    (place['lat'] as num).toDouble(),
                    (place['lng'] as num).toDouble(),
                  );

                  final fare = _calculateFare(distance);

                  return DestinationCard(
                    name: place['name'] ?? 'Unknown',
                    address: place['address'] ?? '',
                    rating: (place['rating'] as num?)?.toDouble() ?? 0,
                    imageUrl: place['photoUrl'] ?? '',
                    fare: fare,
                    onBook: () => _bookDestination(place),
                  );
                },
              ),

            const SizedBox(height: 20),

            // Nearby Drivers
            const Text(
              'NEARBY DRIVERS',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 8),
            if (_drivers.isEmpty)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Text(
                    'No nearby drivers',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              )
            else
              ..._drivers.map((driver) {
                return NearbyDriverCard(
                  plate: driver['plate'],
                  driverName: driver['name'],
                  phone: driver['phone'],
                  destination: driver['destination'],
                  onMessage: () => _messageDriver(driver['phone']),
                  onCall: () => _callDriver(driver['phone']),
                );
              }).toList(),
          ],
        ),
      ),
    );
  }
}