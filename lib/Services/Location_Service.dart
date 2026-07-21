import 'package:geolocator/geolocator.dart';


class LocationService {
  /// Checks and requests GPS tracking device permissions automatically.
  /// Returns true if permissions are granted and location services are active.
  Future<bool> handlePermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if device hardware GPS toggle is turned on
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return false;

    // Check application level tracking permissions
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return false;
    }

    if (permission == LocationPermission.deniedForever) return false;
    return true;
  }

  /// Gets a one-off rapid hardware reading of the handset's current position.
  Future<Position?> getCurrentLocation() async {
    final hasPermission = await handlePermission();
    if (!hasPermission) return null;

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
      //locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );
  }

  /// Streams real-time position changes continuously as a vehicle moves.
  /// Excellent for updating driver locations inside your TaxiSpatialService.
  Stream<Position> getLiveLocationStream() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // Triggers stream update only every 10 meters moved
      ),
    );
  }
}