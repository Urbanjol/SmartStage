import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:math';
import '../Config/app_config.dart';
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
        SnackBar(
          content: Text(
            'Please login to book',
            style: AppText.body.copyWith(color: Colors.white),
          ),
          backgroundColor: const Color(0xFFEF4444),
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
            title: Text(
              'BOOKING SENT',
              style: AppText.header.copyWith(
                fontSize: 16,
                color: const Color(0xFF2563EB),
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Your booking request has been sent to nearby drivers.',
                  style: AppText.body,
                ),
                const SizedBox(height: 12),
                Text(
                  'Destination: $destinationName',
                  style: AppText.body.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  'Estimated fare: UGX $fare',
                  style: AppText.number.copyWith(
                    fontSize: 14,
                    color: const Color(0xFF10B981),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'OK',
                  style: AppText.body.copyWith(
                    color: const Color(0xFF2563EB),
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
            content: Text(
              'Booking failed: $e',
              style: AppText.body.copyWith(color: Colors.white),
            ),
            backgroundColor: const Color(0xFFEF4444),
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
        title: Text(
          'PRIVATE HIRE',
          style: AppText.header.copyWith(fontSize: 16, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF1E293B),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                controller: _destinationController,
                style: AppText.body,
                decoration: InputDecoration(
                  hintText: 'Where do you want to go?',
                  hintStyle: AppText.caption,
                  border: InputBorder.none,
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Color(0xFF2563EB),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onSubmitted: _searchPlaces,
              ),
            ),
            const SizedBox(height: 12),

            // Error
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  _errorMessage!,
                  style: AppText.body.copyWith(
                    color: const Color(0xFFEF4444),
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
                    color: Color(0xFF2563EB),
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
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.65,
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

            const SizedBox(height: 24),

            // Nearby Drivers
            Text(
              'NEARBY DRIVERS',
              style: AppText.caption.copyWith(letterSpacing: 1.5),
            ),
            const SizedBox(height: 10),
            if (_drivers.isEmpty)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    'No nearby drivers',
                    style: AppText.caption,
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