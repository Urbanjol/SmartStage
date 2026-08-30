import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import '../Config/theme.dart';
import 'driver_parcel_request.dart';
import 'driver_request_screen.dart';
//import 'driver_parcel_requests_screen.dart';
import 'notification_screen.dart';

class DriverHomeScreen extends ConsumerStatefulWidget {
  final String userId;
  final String matatuId;
  final String matatuPlate;
  final List<String> route;
  final List<String> routeNames;

  const DriverHomeScreen({
    Key? key,
    required this.userId,
    required this.matatuId,
    required this.matatuPlate,
    required this.route,
    required this.routeNames,
  }) : super(key: key);

  @override
  ConsumerState<DriverHomeScreen> createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends ConsumerState<DriverHomeScreen> {
  String _seatState = 'space_available';
  String _status = 'EN_ROUTE';
  int _seatsAvailable = 14;
  int _earningsToday = 0;
  bool _isUpdating = false;
  bool _isOnline = true;
  int _parcelRequestCount = 0;
  int _bookingRequestCount = 0;

  @override
  void initState() {
    super.initState();
    _loadDriverData();
    _loadParcelRequestCount();
    _loadBookingRequestCount();
  }

  Future<void> _loadDriverData() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('taxis')
          .doc(widget.matatuId)
          .get();

      if (doc.exists) {
        final data = doc.data()!;
        setState(() {
          _seatState = data['seat_state'] ?? 'space_available';
          _status = data['status'] ?? 'EN_ROUTE';
          _seatsAvailable = (data['seats_available'] as num?)?.toInt() ?? 14;
        });
      }
    } catch (e) {
      // Silently fail
    }
  }

  Future<void> _loadParcelRequestCount() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('parcels')
          .where('status', isEqualTo: 'created')
          .get();

      if (mounted) {
        setState(() {
          _parcelRequestCount = snapshot.docs.length;
        });
      }
    } catch (e) {
      // Silently fail
    }
  }

  Future<void> _loadBookingRequestCount() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('bookings')
          .where('status', isEqualTo: 'searching')
          .get();

      if (mounted) {
        setState(() {
          _bookingRequestCount = snapshot.docs.length;
        });
      }
    } catch (e) {
      // Silently fail
    }
  }

  Future<void> _updateSeatState(String newState) async {
    setState(() => _isUpdating = true);

    try {
      final callable =
      FirebaseFunctions.instance.httpsCallable('updateSeatStatus');
      await callable.call({
        'matatu_id': widget.matatuId,
        'seat_state': newState,
      });

      setState(() {
        _seatState = newState;
        _isUpdating = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Seat status updated'),
          backgroundColor: SmartStageColors.electricGreen,
        ),
      );
    } catch (e) {
      setState(() => _isUpdating = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update: $e'),
          backgroundColor: SmartStageColors.red,
        ),
      );
    }
  }

  Future<void> _toggleOnline() async {
    setState(() => _isUpdating = true);

    try {
      final newStatus = _isOnline ? 'OFF_DUTY' : 'EN_ROUTE';
      final callable =
      FirebaseFunctions.instance.httpsCallable('updateMatatuLocation');
      await callable.call({
        'matatu_id': widget.matatuId,
        'location': {
          'lat': 0.3136,
          'lng': 32.5811,
        },
        'status': newStatus,
      });

      setState(() {
        _isOnline = !_isOnline;
        _status = newStatus;
        _isUpdating = false;
      });
    } catch (e) {
      setState(() => _isUpdating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0A192F) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(widget.matatuPlate),
        backgroundColor: isDark ? const Color(0xFF0A192F) : Colors.white,
        foregroundColor: isDark ? Colors.white : const Color(0xFF1E293B),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NotificationsScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? const [
              Color(0xFF0A192F),
              Color(0xFF1E3A8A),
            ]
                : const [
              Color(0xFF2563EB),
              Color(0xFFB197FC),
              Color(0xFFF8FAFC),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: isDark ? null : const [0.0, 0.3, 1.0],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Online Toggle
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: _isOnline
                        ? [
                      const Color(0xFF2563EB),
                      const Color(0xFF1D4ED8),
                    ]
                        : [
                      SmartStageColors.greyDark.withOpacity(0.5),
                      const Color(0xFF64748B),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: (_isOnline
                          ? const Color(0xFF2563EB)
                          : SmartStageColors.greyDark)
                          .withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _isOnline
                            ? Colors.white
                            : SmartStageColors.greyDark,
                        boxShadow: _isOnline
                            ? [
                          BoxShadow(
                            color: Colors.white.withOpacity(0.5),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ]
                            : null,
                      ),
                      child: Icon(
                        _isOnline ? Icons.check : Icons.close,
                        color: _isOnline
                            ? const Color(0xFF2563EB)
                            : Colors.white,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _isOnline ? 'ONLINE' : 'OFFLINE',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            _isOnline
                                ? 'Passengers can see you'
                                : 'You are hidden from passengers',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: _isOnline,
                      onChanged: (_) => _toggleOnline(),
                      activeColor: Colors.white,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Stats Row
              Row(
                children: [
                  _buildStatCard(
                    context,
                    label: 'EARNINGS',
                    value: 'UGX ${_earningsToday.toString()}',
                    icon: Icons.payments_outlined,
                    color: const Color(0xFFFFB800),
                  ),
                  const SizedBox(width: 10),
                  _buildStatCard(
                    context,
                    label: 'SEATS LEFT',
                    value: _seatsAvailable.toString(),
                    icon: Icons.event_seat,
                    color: const Color(0xFF10B981),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Seat State
              Text(
                'SEAT STATUS',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isDark
                      ? SmartStageColors.greyMid
                      : SmartStageColors.greyDark,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  _buildSeatButton(
                    context,
                    label: 'SPACE',
                    color: SmartStageColors.electricGreen,
                    isSelected: _seatState == 'space_available',
                    onTap: () => _updateSeatState('space_available'),
                  ),
                  const SizedBox(width: 8),
                  _buildSeatButton(
                    context,
                    label: 'FILLING',
                    color: SmartStageColors.orange,
                    isSelected: _seatState == 'filling_up',
                    onTap: () => _updateSeatState('filling_up'),
                  ),
                  const SizedBox(width: 8),
                  _buildSeatButton(
                    context,
                    label: 'FULL',
                    color: SmartStageColors.red,
                    isSelected: _seatState == 'full',
                    onTap: () => _updateSeatState('full'),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Route
              Text(
                'ROUTE',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isDark
                      ? SmartStageColors.greyMid
                      : SmartStageColors.greyDark,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark
                      ? SmartStageColors.navyCard
                      : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? Colors.white10 : SmartStageColors.greyLight,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: widget.routeNames.map((stage) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFF2563EB),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF2563EB).withOpacity(0.5),
                                  blurRadius: 6,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            stage,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: isDark
                                  ? SmartStageColors.white
                                  : SmartStageColors.deepNavy,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 20),

              // Booking Requests with badge
              Stack(
                children: [
                  GlowButton(
                    text: 'BOOKING REQUESTS',
                    color: const Color(0xFFFFB800),
                    glowColor: const Color(0xFFFFB800).withOpacity(0.4),
                    icon: Icons.inbox_outlined,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const DriverRequestsScreen(),
                        ),
                      ).then((_) => _loadBookingRequestCount());
                    },
                  ),
                  if (_bookingRequestCount > 0)
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: Text(
                          '$_bookingRequestCount',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 10),

              // Parcel Requests with badge
              Stack(
                children: [
                  GlowButton(
                    text: 'PARCEL REQUESTS',
                    color: const Color(0xFF7B2FF7),
                    glowColor: const Color(0xFF7B2FF7).withOpacity(0.4),
                    icon: Icons.inventory_2_outlined,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const DriverParcelRequestsScreen(),
                        ),
                      ).then((_) => _loadParcelRequestCount());
                    },
                  ),
                  if (_parcelRequestCount > 0)
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: Text(
                          '$_parcelRequestCount',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
      BuildContext context, {
        required String label,
        required String value,
        required IconData icon,
        required Color color,
      }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? SmartStageColors.navyCard : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? Colors.white10 : SmartStageColors.greyLight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark
                    ? SmartStageColors.white
                    : SmartStageColors.deepNavy,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.bold,
                color: isDark
                    ? SmartStageColors.greyMid
                    : SmartStageColors.greyDark,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSeatButton(
      BuildContext context, {
        required String label,
        required Color color,
        required bool isSelected,
        required VoidCallback onTap,
      }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isSelected
                ? color
                : isDark
                ? SmartStageColors.navyCard
                : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? color
                  : (isDark ? Colors.white10 : SmartStageColors.greyLight),
            ),
            boxShadow: isSelected
                ? [
              BoxShadow(
                color: color.withOpacity(0.4),
                blurRadius: 12,
                spreadRadius: 1,
              ),
            ]
                : null,
          ),
          child: Column(
            children: [
              Icon(
                Icons.event_seat,
                color: isSelected ? Colors.white : color,
                size: 22,
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: isSelected
                      ? Colors.white
                      : isDark
                      ? SmartStageColors.greyMid
                      : SmartStageColors.greyDark,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}