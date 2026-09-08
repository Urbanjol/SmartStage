import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import '../Config/theme.dart';
import 'driver_parcel_request.dart';
import 'driver_request_screen.dart';
import 'notification_screen.dart';
import '../Providers/Driver_stats_provider.dart';
import '../Providers/fuel_data_provider.dart';
import '../Widgets/driver_cards.dart';
import '../Providers/market_data_provider.dart';
import '../Services/traffic_service.dart';

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
  String _status = 'LOADING';
  int _seatsAvailable = 14;
  bool _isOnline = true;
  int _parcelRequestCount = 0;
  int _bookingRequestCount = 0;
  bool _isBalanceVisible = true;
  double _balance = 0;
  double _balanceChange = 0;
  String _trafficCondition = 'Unknown';
  int _trafficDelay = 0;
  String _trafficSummary = '';

  @override
  void initState() {
    super.initState();
    _loadDriverData();
    _loadBalance();
    _loadTraffic();
    Future.microtask(() {
      ref.read(driverStatsProvider.notifier).loadDemandData();
    });
    _loadParcelRequestCount();
    _loadBookingRequestCount();
  }

  Future<void> _loadTraffic() async {
    if (widget.route.isEmpty) return;

    final traffic = await TrafficService.getTraffic(widget.route);

    if (mounted) {
      setState(() {
        _trafficCondition = traffic['condition'] ?? 'Unknown';
        _trafficDelay = (traffic['estimated_delay_minutes'] as num?)?.toInt() ?? 0;
        _trafficSummary = traffic['summary'] ?? '';
      });
    }
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
          _status = data['status'] ?? 'LOADING';
          _seatsAvailable = (data['seats_available'] as num?)?.toInt() ?? 14;
        });
      }
    } catch (e) {
      // Silently fail
    }
  }

  Future<void> _loadBalance() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('driver_balances')
          .doc(widget.matatuId)
          .get();

      if (doc.exists) {
        final data = doc.data()!;
        setState(() {
          _balance = (data['balance'] as num?)?.toDouble() ?? 0;
          _balanceChange = (data['today_change'] as num?)?.toDouble() ?? 0;
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
    setState(() => _seatState = newState);

    try {
      final callable =
      FirebaseFunctions.instance.httpsCallable('updateSeatStatus');
      await callable.call({
        'matatu_id': widget.matatuId,
        'seat_state': newState,
      });
    } catch (e) {
      // Silently fail
    }
  }

  Future<void> _toggleOnline() async {
    setState(() => _isOnline = !_isOnline);

    try {
      final newStatus = _isOnline ? 'LOADING' : 'OFF_DUTY';
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
    } catch (e) {
      // Silently fail
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final stats = ref.watch(driverStatsProvider);
    final fuelAsync = ref.watch(fuelDataProvider);
    final fuelData = fuelAsync.value;
    final marketAsync = ref.watch(marketDataProvider);
    final marketData = marketAsync.value;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Row(
          children: [
            GestureDetector(
              onTap: () {
                setState(() {
                  _isBalanceVisible = !_isBalanceVisible;
                });
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Balance',
                    style: TextStyle(fontSize: 10, color: Colors.white70),
                  ),
                  Row(
                    children: [
                      Text(
                        _isBalanceVisible
                            ? 'UGX ${_balance.toStringAsFixed(0)}'
                            : '••••••',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.visibility_outlined,
                        size: 14,
                        color: Colors.white70,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Spacer(),
            const Icon(Icons.person_outline, color: Colors.white),
          ],
        ),
        backgroundColor: const Color(0xFF1E293B),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            BalanceChangeCard(
              balance: _balance,
              change: _balanceChange,
              isVisible: _isBalanceVisible,
              onToggle: () {
                setState(() {
                  _isBalanceVisible = !_isBalanceVisible;
                });
              },
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                LiveStatCard(
                  label: 'Seats',
                  value: '$_seatsAvailable',
                  change: 'Live',
                  isPositive: true,
                ),
                const SizedBox(width: 8),
                LiveStatCard(
                  label: 'Searches',
                  value: '${stats.todaySearches}',
                  change: '${stats.searchesChange.toStringAsFixed(1)}%',
                  isPositive: stats.searchesChange >= 0,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                LiveStatCard(
                  label: 'Earnings',
                  value: 'UGX ${_balance.toStringAsFixed(0)}',
                  change: '${stats.earningsChange.toStringAsFixed(1)}%',
                  isPositive: stats.earningsChange >= 0,
                ),
                const SizedBox(width: 8),
                LiveStatCard(
                  label: 'Status',
                  value: _isOnline ? 'ONLINE' : 'OFFLINE',
                  change: _isOnline ? 'Active' : 'Hidden',
                  isPositive: _isOnline,
                ),
              ],
            ),
            const SizedBox(height: 12),
            ActiveRouteCard(
              routeText: widget.routeNames.isNotEmpty
                  ? widget.routeNames.join(' → ')
                  : 'No active route',
              onEndRoute: () {
                // End route logic
              },
            ),
            const SizedBox(height: 12),
            ActiveRouteTrafficCard(
              condition: _trafficCondition,
              delayMinutes: _trafficDelay,
              summary: _trafficSummary,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                QuickActionButton(
                  text: 'ONLINE',
                  icon: _isOnline ? Icons.toggle_on : Icons.toggle_off,
                  color: _isOnline ? const Color(0xFF10B981) : Colors.grey,
                  onTap: _toggleOnline,
                ),
                const SizedBox(width: 8),
                QuickActionButton(
                  text: 'SEATS',
                  icon: Icons.event_seat,
                  color: const Color(0xFF2563EB),
                  onTap: () {
                    // Show seat picker
                  },
                ),
                const SizedBox(width: 8),
                QuickActionButton(
                  text: 'FUEL',
                  icon: Icons.local_gas_station,
                  color: const Color(0xFFFFB800),
                  onTap: () {
                    // Show fuel prices
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            DemandPulseCard(
              busyHours: stats.busyHours,
              hotStages: stats.hotStages,
            ),
            const SizedBox(height: 12),
            FuelPricesCard(prices: marketData?.fuel ?? []),
            const SizedBox(height: 12),
            TrafficCard(traffic: marketData?.traffic ?? []),
            const SizedBox(height: 12),
            FuelNewsCard(news: marketData?.news ?? []),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: GlowButton(
                    text: 'BOOKING (${_bookingRequestCount})',
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
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: GlowButton(
                    text: 'PARCEL (${_parcelRequestCount})',
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
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}