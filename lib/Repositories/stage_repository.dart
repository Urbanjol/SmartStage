//stage model repository
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/Stage_model.dart';

//start the repository
class StageRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  //fetch all registered physical stages across the network
Future<List<StageModel>> getAllStages() async {
  try{
    final snapshot = await _db.collection('stages').get();
    return snapshot.docs.map((doc) => StageModel.fromFirestore(doc)).toList();
  }catch (e){
    throw Exception('Failed to pull transport stages : $e ');
  }
}
//streams real time stages if active vehicle numbers change
Stream<List<StageModel>>streamActiveStages(){
  return _db.collection('stages').snapshots().map((snapshot) {
    return snapshot.docs.map((doc) => StageModel.fromFirestore(doc)).toList();
  });
}
}