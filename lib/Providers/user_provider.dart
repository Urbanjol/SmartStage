//This will handle who is logged in
//a conductor,driver or a passenger and it will direct them to
//where they need to be
import 'package:flutter/material.dart';
import 'package:smart_stage/Repositories/user_repository.dart';
import 'package:riverpod/riverpod.dart';
import '../models/User_model.dart';

//repo antenna
final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository();
});
//we create a class
class UserProvider with ChangeNotifier{
UserModel? _user;
UserModel? get user => _user;

//set user after login
void setUser(UserModel user){
  _user = user;
  notifyListeners();
}
//check if current user is a conductor
bool get isConductor => _user?.role == 'conductor';
void clearUser(){
  _user = null;
  notifyListeners();
}
}