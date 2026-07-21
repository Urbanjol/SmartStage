import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../Services/location_service.dart';
import '../Services/Location_Service.dart';// Make sure this points to where locationServiceProvider lives


final locationServiceProvider = Provider<LocationService>((ref){
  return LocationService();
});

/// A global provider to read the user's latest physical position coordinates.
final userLocationProvider = AsyncNotifierProvider<UserLocationNotifier, Position?>(() {
  return UserLocationNotifier();
});

class UserLocationNotifier extends AsyncNotifier<Position?> {
  StreamSubscription<Position>? _positionSubscription;

  @override
  FutureOr<Position?> build() async {
    // Clean up any lingering hardware subscription lines if Riverpod rebuilds the provider
    ref.onDispose(() {
      _positionSubscription?.cancel();
    });

    // Automatically try to pull the initial coordinate position upon launch
    return _fetchInitialLocation();
  }

  /// Handles internal setup permissions and fetches the initial coordinate anchor point
  Future<Position?> _fetchInitialLocation() async {
    final locationService = ref.read(locationServiceProvider);

    // Request device hardware permissions
    final hasPermission = await locationService.handlePermission();
    if (!hasPermission) {
      throw Exception('GPS Location Tracking Permissions Denied');
    }

    return await locationService.getCurrentLocation();
  }

  /// Call this when the user clicks a "My Location" GPS crosshair icon to manually refresh
  Future<void> refreshLocation() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchInitialLocation());
  }

  /// Toggles continuous real-time spatial updates (Ideal for moving drivers or active riders)
  void startTrackingLiveMovement() {
    // Avoid opening duplicate hardware stream channels if already tracking
    _positionSubscription?.cancel();

    final locationService = ref.read(locationServiceProvider);

    _positionSubscription = locationService.getLiveLocationStream().listen(
          (Position position) {
        // Feed the fresh movement data directly into the Riverpod state graph
        state = AsyncValue.data(position);
      },
      onError: (error) {
        state = AsyncValue.error(error, StackTrace.current);
      },
    );
  }

  /// Safely spins down the hardware sensor updates when tracking is no longer needed
  void stopTrackingLiveMovement() {
    _positionSubscription?.cancel();
    _positionSubscription = null;
  }
}