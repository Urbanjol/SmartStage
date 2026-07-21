import 'package:/riverpod/riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:smart_stage/Providers/stage_provider.dart';
import '../Services/taxi_spatial_service.dart';

//provide a single instance of the spatial world to the rest of the application
final taxiSpatialServiceProvider = Provider<TaxiSpatialService>((ref){
  return TaxiSpatialService();
});
//A placeholder sateNotifierProvider that we will use to track the nearby driver Id's
//In real time as the passenger moves across different h3 cells
final nearByDriversProvider = StateNotifierProvider<NearByDriversNotifier,List<String>>((ref){
  final spatialService = ref.watch(taxiSpatialServiceProvider);
  return NearByDriversNotifier(spatialService);
});

class NearByDriversNotifier extends StateNotifier<List<String>>{
  final TaxiSpatialService _spatialService;
  //initialize this variable
NearByDriversNotifier(this._spatialService) : super([]);
Future<void> fetchNearbyDrivers(double lat,double lng) async{
  try{
  final driverIds = await _spatialService.findAllNearByDrivers(passengerLat: lat, passengerLng: lng,
      ringRadius: 1); // look at the immediate centre cell and its 6 neighbors
  state = driverIds;
}catch (e) {
    state = []; //handle errors elegantly
  }
}
}
