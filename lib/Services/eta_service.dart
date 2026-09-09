import 'dart:math';

class EtaService {
  static double calculateETA({
    required double distanceKm,
    required double speedKmh,
    int trafficDelayMinutes = 0,
  }) {
    if (speedKmh <= 0) return 999;

    double baseMinutes = (distanceKm / speedKmh) * 60;
    return baseMinutes + trafficDelayMinutes;
  }

  static double distanceInKm({
    required double lat1,
    required double lng1,
    required double lat2,
    required double lng2,
  }) {
    const R = 6371;

    double dLat = _toRadians(lat2 - lat1);
    double dLng = _toRadians(lng2 - lng1);

    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) *
            cos(_toRadians(lat2)) *
            sin(dLng / 2) *
            sin(dLng / 2);

    double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return R * c;
  }

  static double _toRadians(double degree) {
    return degree * pi / 180;
  }
}