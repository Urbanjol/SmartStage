//storing the phone numbers and momo local balances on the phone
import 'package:shared_preferences/shared_preferences.dart';

//create our LocalStorage Class
class LocalStorageService {
  //name our variables
  static const _keyUserPhone = "user_momo_phone";
  static const _LastH3index ="Last_Known_index";
  static const _KeyIsDriver ="is_driver_account";
  final SharedPreferences _prefs;
  LocalStorageService(this._prefs);

  //phone number cache accessers
  Future<void>cacheUserPhone(String phoneNumber) async {
    await _prefs.setString(_keyUserPhone, phoneNumber);
  }
//get user phone
  String? getUserPhone(){
    return _prefs.getString(_keyUserPhone);
  }
//get last H3 index
  Future<void>cacheLastH3Index(String h3Index) async{
    await _prefs.setString(_LastH3index, h3Index);
  }
  String? getLastH3Index(){
    return _prefs.getString(_LastH3index);
  }
//get account getters
  Future<void>cacheAccountType({required bool isDriver}) async {
    await _prefs.setBool(_KeyIsDriver, isDriver);
  }
//GET account
  bool isDriverAccount(){
    return _prefs.getBool(_KeyIsDriver) ?? false;
  }
//wipe credentials cleanly on user logout
  Future<void>clearSession() async {
    await _prefs.clear();
  }
}
