import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';

class DriverLocationService {
  static Stream<Position>? _positionStream;

  static Future<bool> startLocationUpdates(String taxiId) async {
    try {
      LocationPermission permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return false;
      }

      _positionStream = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 5,
        ),
      );

      _positionStream?.listen((position) async {
        try {
          await FirebaseFirestore.instance
              .collection('taxis')
              .doc(taxiId)
              .update({
            'current_location': GeoPoint(
              position.latitude,
              position.longitude,
            ),
            'speed': position.speed,
            'heading': position.heading,
            'last_updated': FieldValue.serverTimestamp(),
          });
        } catch (e) {
          // Silently fail
        }
      });

      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<void> stopLocationUpdates() async {
    _positionStream = null;
  }
}