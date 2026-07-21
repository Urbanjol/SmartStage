import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class RouteModel {
  final String routeId;
  final String routeName; // e.g., "Kansanga-Ggaba"
  final List<String> stagesOnRoute; // IDs of stages this taxi passes
  final double standardFare;

  RouteModel({
    required this.routeId,
    required this.routeName,
    required this.stagesOnRoute,
    required this.standardFare,
  });
  //Fromfirestore helper method
factory RouteModel.fromFirestore(DocumentSnapshot doc){
  final data = doc.data() as Map<String, dynamic>? ?? {};
  return RouteModel(
      routeId: doc.id,
      routeName: data['routeName'] ?? '',
      stagesOnRoute: data['stagesOnRoute'] ?? '',
      standardFare: (data['standardFare'] ?? 0.0).toDouble(),);
}
}
