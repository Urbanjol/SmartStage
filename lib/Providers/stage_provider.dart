import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:smart_stage/Repositories/stage_repository.dart';
import '../models/Stage_model.dart';

//this is the antennae of the repository in the
final stageRepositoryProvider = Provider<StageRepository>((ref) {
  return StageRepository();
});
 //we first create a class for our stage provider
//This will fetch all stages and find the nearest stage to the passenger
class stageProvider with ChangeNotifier {
  //create the variables that are private _
  //private variables
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  List<StageModel> _allStages = [];
  StageModel? _nearestStage;
  bool _isLoading = false;

// we are allowing them to access the data but not to touch it
  //getters
  List<StageModel> get allStages => _allStages;

  StageModel? get nearestStage => _nearestStage;

  bool get isLoading => _isLoading;

  //Fetch stages from Firebase
  Future<void> fetchStages() async {
    _isLoading = true;
    notifyListeners();

    try {
      var snapshot = await _db.collection('stages').get();
      _allStages =
          snapshot.docs.map((doc) => StageModel.fromFirestore(doc)).toList();// FIRESTORE METHOD
    } catch (e) {
      print("Error fetching stages: $e");
    }
    _isLoading = false;
    notifyListeners();
  }

//2.Logic to find the nearest stage to the passenger
  void findNearestStage(double userLat, double userLng) {
    if (_allStages.isEmpty) return;
    double minDistance = double.infinity;
    StageModel? closest;
    for (var stage in _allStages) {
      double distance = Geolocator.distanceBetween(
          userLat, userLng, stage.lat, stage.lng);
      if (distance < minDistance) {
        minDistance = distance;
        closest = stage;
      }
    }
    _nearestStage = closest;
    notifyListeners();
  }
}
//This is acting as the bipartite theorem where the nearest stage acts as
//the primary node a passenger is connected to.
//In places like the old taxi park, there
//many stages very close to each other
//we have to update findNearestStage to return more than 3 stages....