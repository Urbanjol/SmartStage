//this is the repo for users
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/User_model.dart';

class UserRepository {
final FirebaseFirestore _db = FirebaseFirestore.instance;
//Fetch a specific user profile by their Unique Id
Future<UserModel?>getUserProfile(String userId) async {
  try{
    final doc = await _db.collection('users').doc(userId).get();
    //check if it exists
    if(!doc.exists) return null;
    return UserModel.fromMap(doc.data()!..['userId'] = doc.id);

  } catch (e){
    throw Exception('Failed to fetch user profile: $e');
  }
}
//creating or update a userProfile entry
Future<void>saveUserProfile(UserModel user) async {
  try{
    await _db.collection('users').doc(user.uid).set(user.toJson(),SetOptions(merge: true));
  }catch(e){
    throw Exception('Failed to save userProfile');
  }
}
}