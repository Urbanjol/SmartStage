import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DriverStatsState {
  final bool isLoading;
  final String busyHours;
  final String hotStages;
  final double searchesChange;
  final double earningsChange;
  final int todaySearches;
  final String? errorMessage;

  const DriverStatsState({
    this.isLoading = false,
    this.busyHours = 'N/A',
    this.hotStages = 'N/A',
    this.searchesChange = 0,
    this.earningsChange = 0,
    this.todaySearches = 0,
    this.errorMessage,
  });

  DriverStatsState copyWith({
    bool? isLoading,
    String? busyHours,
    String? hotStages,
    double? searchesChange,
    double? earningsChange,
    int? todaySearches,
    String? errorMessage,
  }) {
    return DriverStatsState(
      isLoading: isLoading ?? this.isLoading,
      busyHours: busyHours ?? this.busyHours,
      hotStages: hotStages ?? this.hotStages,
      searchesChange: searchesChange ?? this.searchesChange,
      earningsChange: earningsChange ?? this.earningsChange,
      todaySearches: todaySearches ?? this.todaySearches,
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

  Future<void> loadDemandData() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day);
      final yesterdayStart = todayStart.subtract(const Duration(days: 1));

      final todaySnapshot = await _firestore
          .collection('search_history')
          .where('search_time', isGreaterThanOrEqualTo: todayStart)
          .get();

      final yesterdaySnapshot = await _firestore
          .collection('search_history')
          .where('search_time', isGreaterThanOrEqualTo: yesterdayStart)
          .where('search_time', isLessThan: todayStart)
          .get();

      final todaySearches = todaySnapshot.docs.length;
      final yesterdaySearches = yesterdaySnapshot.docs.length;

      double searchesChange = 0;

      if (yesterdaySearches > 0) {
        searchesChange = ((todaySearches - yesterdaySearches) / yesterdaySearches) * 100;
      } else if (todaySearches > 0) {
        searchesChange = 100;
      }

      // Hour and destination counts for today
      final hourCount = <int, int>{};
      final destinationCount = <String, int>{};

      for (final doc in todaySnapshot.docs) {
        final data = doc.data();
        final searchTime = data['search_time'];
        final destination = data['destination'] as String? ?? 'Unknown';

        destinationCount[destination] =
            (destinationCount[destination] ?? 0) + 1;

        if (searchTime != null) {
          final time = (searchTime as dynamic).toDate() as DateTime;
          hourCount[time.hour] = (hourCount[time.hour] ?? 0) + 1;
        }
      }

      final sortedHours = hourCount.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      final topHours = sortedHours.take(3).map((e) => '${e.key}:00').join(', ');

      final sortedDest = destinationCount.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      final topDestinations =
      sortedDest.take(3).map((e) => e.key).join(', ');

      // Earnings change
      final todayBookingsSnapshot = await _firestore
          .collection('bookings')
          .where('bookingTime', isGreaterThanOrEqualTo: todayStart.toIso8601String())
          .get();

      final yesterdayBookingsSnapshot = await _firestore
          .collection('bookings')
          .where('bookingTime', isGreaterThanOrEqualTo: yesterdayStart.toIso8601String())
          .where('bookingTime', isLessThan: todayStart.toIso8601String())
          .get();

      double todayEarnings = 0;
      double yesterdayEarnings = 0;

      for (final doc in todayBookingsSnapshot.docs) {
        final data = doc.data();
        todayEarnings += (data['fareAmount'] as num?)?.toDouble() ?? 0;
      }

      for (final doc in yesterdayBookingsSnapshot.docs) {
        final data = doc.data();
        yesterdayEarnings += (data['fareAmount'] as num?)?.toDouble() ?? 0;
      }

      double earningsChange = 0;

      if (yesterdayEarnings > 0) {
        earningsChange = ((todayEarnings - yesterdayEarnings) / yesterdayEarnings) * 100;
      } else if (todayEarnings > 0) {
        earningsChange = 100;
      }

      state = state.copyWith(
        isLoading: false,
        busyHours: topHours.isEmpty ? 'N/A' : topHours,
        hotStages: topDestinations.isEmpty ? 'N/A' : topDestinations,
        searchesChange: searchesChange,
        earningsChange: earningsChange,
        todaySearches: todaySearches,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load demand data: $e',
      );
    }
  }
}