//this model represents the physical "sinks" where demand
//accumulates
import 'package:cloud_firestore/cloud_firestore.dart';

class StageModel {
  final String stageId;
  final String stageName;
  final double lat; //x axis
  final double lng; //y axis
  final List<String> routesServed; //eg.,["Kira-Kampala","Kira-Namugongo"] Q[a b]
//Real time fluid data
  int waitingPassengers;
  double entropyLevel;
  String currentLoadingTaxiId; //the taxi currently "at the front"

  StageModel({
    required this.stageId,
    required this.stageName,
    required this.lat, //x-axis
    required this.lng, //y-axis
    required this.routesServed, //edges
    this.waitingPassengers = 0,
    this.entropyLevel = 1.0, // this is for the traffic in the city
    this.currentLoadingTaxiId = '',
  });

//to firestore
  Map<String, dynamic> toFirestore() {
    return {
      'stageId': stageId,
      'stageName': stageName,
      'lat': lat, //a
      'lng': lng, //b
      'routesServed': routesServed,
      'waitingPassengers': waitingPassengers,
      'entropyLevel': entropyLevel,
      'currentLoadingTaxiId': currentLoadingTaxiId,
    };
  }

//fromFirestore
  factory StageModel.fromFirestore(DocumentSnapshot doc){
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return StageModel(

      stageId: doc.id,
      //Extracts the whole firestore document
      stageName: data['stageName'] ?? '',
      lat: data['lat'] ?? '',
      lng: data['lng'] ?? '',
      routesServed: data['routesServed'] ?? '',
    );
  }
}