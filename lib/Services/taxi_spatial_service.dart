import 'package:h3_flutter/h3_flutter.dart'; //using the standard h3 wrapper
import 'package:cloud_firestore/cloud_firestore.dart';

class TaxiSpatialService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final H3 _h3 = const H3Factory().load(); //Prevent instantiation.
   //resolution 7 is the ideal for taxi dispatching
static const int h3Resolution = 7;
//ingests driver locations and converts them to an h3 index
Future<void>updateDriverLocation({required String driverId,required double lat,required double lng}) async{
  //convert GPS coordinates to h3 index
  try{
    final coordinate = GeoCoord(lat: lat, lon: lng);
    //get the 64-bit integer to h3_Intindex
    final h3_index = _h3.geoToCell(coordinate, h3Resolution);
    //save as a standard lowercase hexadecimal for easy space optimization in firestore
    final h3HexString = h3_index.toRadixString(16).toLowerCase();
    //update the driver's location bucket in firestore
    await _db.collection('drivers').doc(driverId).update({
      'currentLat':lat,
      'currentLng':lng,
      'currentH3index':h3HexString,
      'lastUpdated':FieldValue.serverTimestamp(),
    });

  }catch(e){
    throw Exception('Spatial Ingestion failed for driver $driverId: $e');
  }
}
//finds only passengers within a given passenger's cell and its surrounding rings.
//ring[radius] of 0 = only passenger's cell. 1= immediately adjacent 6 cells, etc
Future<List<String>>findAllNearByDrivers({required passengerLat,required passengerLng,int ringRadius = 1})async{
  try{
    //get the passenger coords
    final passengerCoord = GeoCoord(lat: passengerLat, lon: passengerLng);
    final centerH3Int = _h3.geoToCell(passengerCoord, h3Resolution);
    //Get the neighboring h3 rings includes the center cell
    final localRingIndices = _h3.gridDisk(centerH3Int,ringRadius).toList(); //gridDisk and kRing
    //Convert all matching ring integers to hex strings
    final List<String>targetH3HexStrings = localRingIndices
        .map((idx) => idx.toRadixString(16).toLowerCase())
        .toList();
    //Firestore limits 'whereIn queries to 10 items
    //A ring radius of 1 exactly yields 7 cells (center + 6 neighbors) which fits perfectly
    if(targetH3HexStrings.length > 10){
      throw Exception('H3 radius query exceeds Firestore 10 limits');
    }
    //query database for online drivers sitting inside these exact spatial token buckets
    final querySnapshot = await _db
    .collection('drivers')
    .where('isOnline',isEqualTo: true)
    .where('currentIndex',whereIn: targetH3HexStrings)
    .get();
    //Extract driverIds who are in close proximity
    return querySnapshot.docs.map((doc) => doc.id).toList();
  }catch (e){
    throw Exception('Failed to query proximity rings: $e');
  }

}
}