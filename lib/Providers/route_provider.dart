//This is where we are going to implement
// our bipartite connections...
// plus the matching logic of the bipartite
//we are going to use the flutter_polyline_points to color our edges
//This provider handles the "Digital Wave" filtering, matching destination, capacity, and direction.

import 'package:flutter/material.dart';
import 'package:riverpod/riverpod.dart';
import '../Repositories/route_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

//this is the antenna of the routeRepository
final routeRepositoryProvider = Provider<RouteRepository>((ref){
  return RouteRepository();
});
//create the class
class RouteProvider with ChangeNotifier{
  //create the private variables
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  Set<Polyline> _polylines = {};
  List<String> _matchingTaxiIds = [];
  Set<Polyline> get polyline => _polylines;
  List<String> get matchingTaxiIds => _matchingTaxiIds;
  //Draw route on the map
void drawRouteLine(List<LatLng> points){
  _polylines.add(
  Polyline(
    polylineId: const PolylineId("route_path"),
    points: points,
    color: Colors.blue,
    width: 5,

  ),
  );
  notifyListeners();
}

//Find matching taxis for a wave, this is where we implement the
//bipartite matching filter
Future<void> FindAvailableTaxisForRoute(String destinationStageId) async{
  _matchingTaxiIds.clear();
  //we query Firestore for taxis that:
  //1.Have atleast one seat
  //2.Are currently active
  var snapshot = await _db.collection('taxis')
  .where('availableSeats',isGreaterThan: 0)
  .where('status',isEqualTo: 'on-road')
  .get();
  for(var doc in snapshot.docs){
    List<dynamic> taxiRouteStages = doc.data()['routestages'] ?? [];
    //filter:Only include the taxis that pass the passenger's destination
    if(taxiRouteStages.contains(destinationStageId)){
      _matchingTaxiIds.add(doc.id);
    }
  }
  notifyListeners();
}
}
// Implementing the "Bipartite Edge"
// When _matchingTaxiIds is populated, the graph has found potential Edges.
//
//     Passenger Node: The person who tapped "Wave."
//     Taxi Node: Any ID in the _matchingTaxiIds list.
//     The Match: When the conductor in one of those taxis clicks "Accept," the BookingModel status changes to matched, finalizing the edge in your graph