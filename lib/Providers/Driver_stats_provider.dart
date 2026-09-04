import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DriverStatsState {
  final bool isLoading;
  final String busyHours;
  final String hotStages;
  final String? errorMessage;

  const DriverStatsState({
    this.isLoading = false,
    this.busyHours = 'N/A',
    this.hotStages = 'N/A',
    this.errorMessage,
  });

  DriverStatsState copyWith({
    bool? isLoading,
    String? busyHours,
    String? hotStages,
    String? errorMessage,
  }) {
    return DriverStatsState(
      isLoading: isLoading ?? this.isLoading,
      busyHours: busyHours ?? this.busyHours,
      hotStages: hotStages ?? this.hotStages,
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
      final snapshot = await _firestore
          .collection('search_history')
          .orderBy('search_time', descending: true)
          .limit(100)
          .get();

      final searches = snapshot.docs.map((doc) => doc.data()).toList();

      final now = DateTime.now();
      final hourCount = <int, int>{};
      final destinationCount = <String, int>{};

      for (final search in searches) {
        final searchTime = search['search_time'];
        final destination = search['destination'] as String? ?? 'Unknown';

        destinationCount[destination] =
            (destinationCount[destination] ?? 0) + 1;

        if (searchTime != null) {
          final time = (searchTime as dynamic).toDate() as DateTime;
          if (time.year == now.year &&
              time.month == now.month &&
              time.day == now.day) {
            hourCount[time.hour] = (hourCount[time.hour] ?? 0) + 1;
          }
        }
      }

      final sortedHours = hourCount.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      final topHours = sortedHours.take(3).map((e) => '${e.key}:00').join(', ');

      final sortedDest = destinationCount.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      final topDestinations =
      sortedDest.take(3).map((e) => e.key).join(', ');

      state = state.copyWith(
        isLoading: false,
        busyHours: topHours.isEmpty ? 'N/A' : topHours,
        hotStages: topDestinations.isEmpty ? 'N/A' : topDestinations,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load demand data: $e',
      );
    }
  }
}