import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TaxiVehicle {
  final String id;
  final String plate;
  final String vehicleType;
  final double lat;
  final double lng;
  final String status;
  final String seatState;
  final int seatsAvailable;
  final List<String> route;

  TaxiVehicle({
    required this.id,
    required this.plate,
    required this.vehicleType,
    required this.lat,
    required this.lng,
    required this.status,
    required this.seatState,
    required this.seatsAvailable,
    required this.route,
  });

  factory TaxiVehicle.fromMap(Map<String, dynamic> map, String id) {
    final location = map['current_location'];

    double lat = 0.3136;
    double lng = 32.5811;

    if (location != null) {
      lat = location['_latitude'] ?? location['lat'] ?? 0.3136;
      lng = location['_longitude'] ?? location['lng'] ?? 32.5811;
    }

    return TaxiVehicle(
      id: id,
      plate: map['plate'] ?? 'Unknown',
      vehicleType: map['vehicle_type'] ?? 'taxi',
      lat: lat.toDouble(),
      lng: lng.toDouble(),
      status: map['status'] ?? 'LOADING',
      seatState: map['seat_state'] ?? 'space_available',
      seatsAvailable: (map['seats_available'] as num?)?.toInt() ?? 0,
      route: List<String>.from(map['route'] ?? []),
    );
  }

  String get icon {
    switch (vehicleType) {
      case 'e_bus':
        return '🚌';
      case 'bus':
        return '🚍';
      case 'taxi':
      default:
        return '🚐';
    }
  }

  String get destination {
    if (route.isNotEmpty) {
      return route.last;
    }
    return 'Unknown';
  }
}

final taxiStreamProvider = StreamProvider<List<TaxiVehicle>>((ref) {
  return FirebaseFirestore.instance
      .collection('taxis')
      .where('status', whereIn: ['LOADING', 'EN_ROUTE'])
      .snapshots()
      .map((snapshot) {
    return snapshot.docs
        .map((doc) => TaxiVehicle.fromMap(
      doc.data() as Map<String, dynamic>,
      doc.id,
    ))
        .toList();
  });
});