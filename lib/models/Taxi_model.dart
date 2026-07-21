import 'package:flutter/cupertino.dart';

class TaxiModel{
  final String taxiId;
  final String conductorUid;
  final String route;
  final int totalSeats;
  int currentPassengers;
  double currentPrice;
  bool isMoving;
  final double currentLat;
  final double currentLng;
  final int spatialIndex;  //for calculating the spatial grid
  final bool isOnline;

  TaxiModel({
    required this.taxiId,
    required this.conductorUid,
    required this.route,
    this.totalSeats = 14,
    this.currentPassengers = 0,
    required this.currentPrice,
    this.isMoving = false,
    required this.currentLat,
    required this.currentLng,
    required this.spatialIndex,
    required this.isOnline,
});
  //toMap function
Map<String,dynamic>ToMap(){
  return{
    'taxiId':taxiId,
    'conductorUid':conductorUid,
    'route':route,
    'totalSeats':totalSeats,
    'currentPassengers':currentPassengers,
    'currentPrice':currentPrice,
    'isMoving':isMoving,
    'currentLat':currentLat,
    'currentLng':currentLng,
    'spatialIndex':spatialIndex,
    'isOnline':isOnline,
  };
 // factory TaxiModel.fromMap(Map<String,dynamic>map)
}
  factory TaxiModel.fromMap(Map<String,dynamic>map){
  return TaxiModel(
      taxiId: map['taxiId'] ?? '',
      conductorUid: map['conductorUid'] ?? '',
      route: map['route'],
      currentPrice: (map['currentPrice'] as num?)?.toDouble() ?? 0.0,
      currentLat: (map['currentLat'] as num?)?.toDouble() ?? 0.0,
      currentLng: (map['currentLng'] as num?)?.toDouble() ?? 0.0,
      spatialIndex: map['spatialIndex'] ?? '',
      isOnline: map['isOnline'] ?? '',
  );

  }
  }
