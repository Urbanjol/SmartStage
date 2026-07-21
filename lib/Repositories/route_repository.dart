//this is where the route kinda logic
//where the graph theorem will be activated
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/Route_model.dart';

class RouteRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  //fetch the configuration for active commuter fixed paths
Future<List<RouteModel>> getActiveRoutes() async {
  try{
    final snapshot = await _db.collection('routes').get();
    return snapshot.docs.map((doc) => RouteModel.fromFirestore(doc)).toList();
  }catch(e){
    throw Exception('Failed to fetch active route network configuration: $e');
  }
}
}