import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DriverStatsState {
  final bool isLoading;
  final double todayEarnings;
  final int todayTrips;
  final int totalTrips;
  final double averageFare;
  final double averagePassengers;
  final String topRoute;
  final String topEarningRoute;
  final String? errorMessage;

  const DriverStatsState({
    this.isLoading = false,
    this.todayEarnings = 0,
    this.todayTrips = 0,
    this.totalTrips = 0,
    this.averageFare = 0,
    this.averagePassengers = 0.0,
    this.topRoute = 'N/A',
    this.topEarningRoute = 'N/A',
    this.errorMessage,
  });

  DriverStatsState copyWith({
    bool? isLoading,
    double? todayEarnings,
    int? todayTrips,
    int? totalTrips,
    double? averageFare,
    double? averagePassengers,
    String? topRoute,
    String? topEarningRoute,
    String? errorMessage,
  }) {
    return DriverStatsState(
      isLoading: isLoading ?? this.isLoading,
      todayEarnings: todayEarnings ?? this.todayEarnings,
      todayTrips: todayTrips ?? this.todayTrips,
      totalTrips: totalTrips ?? this.totalTrips,
      averageFare: averageFare ?? this.averageFare,
      averagePassengers: averagePassengers ?? this.averagePassengers,
      topRoute: topRoute ?? this.topRoute,
      topEarningRoute: topEarningRoute ?? this.topEarningRoute,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

final driverStatsProvider =
NotifierProvider<DriverStatsNotifier, DriverStatsState>(() {
  return DriverStatsNotifier();
});

class DriverStatsNotifier extends Notifier<DriverStatsState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  DriverStatsState build() {
    return const DriverStatsState();
  }

  Future<void> loadStats(String taxiId) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final snapshot = await _firestore
          .collection('bookings')
          .where('taxiId', isEqualTo: taxiId)
          .get();

      final bookings = snapshot.docs.map((doc) => doc.data()).toList();

      final now = DateTime.now();
      double todayEarnings = 0;
      int todayTrips = 0;
      double totalFare = 0;
      int totalPassengers = 0;

      final routeCount = <String, int>{};
      final routeEarnings = <String, double>{};

      for (final booking in bookings) {
        final fare = (booking['fareAmount'] as num?)?.toDouble() ?? 0;
        final passengers = (booking['passengerCount'] as num?)?.toInt() ?? 1;
        final bookingTimeStr = booking['bookingTime'] as String?;
        final route = booking['destinationAddress'] as String? ?? 'Unknown';

        totalFare += fare;
        totalPassengers += passengers;

        routeCount[route] = (routeCount[route] ?? 0) + 1;
        routeEarnings[route] = (routeEarnings[route] ?? 0) + fare;

        if (bookingTimeStr != null) {
          final bookingTime = DateTime.tryParse(bookingTimeStr);
          if (bookingTime != null &&
              bookingTime.year == now.year &&
              bookingTime.month == now.month &&
              bookingTime.day == now.day) {
            todayEarnings += fare;
            todayTrips += 1;
          }
        }
      }

      final totalTrips = bookings.length;
      final averageFare = totalTrips > 0 ? totalFare / totalTrips : 0.0;
      final averagePassengers =
      totalTrips > 0 ? totalPassengers / totalTrips : 0.0;

      String topRoute = 'N/A';
      int topRouteCount = 0;

      routeCount.forEach((route, count) {
        if (count > topRouteCount) {
          topRoute = route;
          topRouteCount = count;
        }
      });

      String topEarningRoute = 'N/A';
      double topEarning = 0;

      routeEarnings.forEach((route, earnings) {
        if (earnings > topEarning) {
          topEarningRoute = route;
          topEarning = earnings;
        }
      });

      state = state.copyWith(
        isLoading: false,
        todayEarnings: todayEarnings,
        todayTrips: todayTrips,
        totalTrips: totalTrips,
        averageFare: averageFare,
        averagePassengers: averagePassengers,
        topRoute: topRoute,
        topEarningRoute: topEarningRoute,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load stats: $e',
      );
    }
  }
}