//here we are going to import features we have to use
// for location like the geolocator

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_stage/Services/local_storage_service.dart';
import '../Services/location_service.dart';

//create a class of location provider with a changeNotifier
//Antennae
//final LocalStorageServiceProvider = Provider<LocalStorageService>((ref){
 // final prefs= ref.watch(sharedPreferencesInstanceProvider); // pull it from the instance
  //return LocalStorageService(prefs);
//});
//throw an exception
//final sharedPreferencesInstanceProvider = Provider<SharedPreferences>((ref){
  //throw UnimplementedError("Initialize sharedPreferences inside main.dart");
//});
class LocationProvider with ChangeNotifier{
  //define variables
  LatLng? _currentLocation;
  bool _serviceEnabled = false;
  LocationPermission? _permission;

  LatLng? get currentLocation => _currentLocation;
  //Initialize and create permissions
  Future<void> determinePosition() async{
    _serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if(!_serviceEnabled) return Future.error('Location services are enabled');
    _permission = await Geolocator.checkPermission();
    if(_permission == LocationPermission.denied){
      _permission = await Geolocator.requestPermission();
      if(_permission == LocationPermission.denied) return Future.error('Permissions denied');
    }

    //Get Initial Position
    Position position = await Geolocator.getCurrentPosition();
    _currentLocation = LatLng(position.latitude, position.longitude);
    notifyListeners();
    //start Live tracking crucial for the conductor
    _startLocationStream();
  }
  void _startLocationStream(){
    Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, //Updates every 10 meters moved
      ),
    ).listen((Position position){
      _currentLocation = LatLng(position.latitude, position.longitude);
      notifyListeners();
      //we wil add code here to send this to Firebase
      //if the user role is conductor
    });
  }
}