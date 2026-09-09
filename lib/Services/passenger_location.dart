import 'package:geolocator/geolocator.dart';

class PassengerLocationService {
  static Future<Position?> getCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return null;
      }

      //return await Geolocator.getCurrentPosition(
        //locationSettings: const LocationSettings(
          //accuracy: LocationAccuracy.high,
        //),
      //);
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

    } catch (e) {
      return null;
    }
  }
}