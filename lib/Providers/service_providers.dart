// lib/providers/service_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// 1. The low-level SharedPreferences instance provider (overridden in main.dart)
final sharedPreferencesInstanceProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError("Initialize SharedPreferences inside main() first");
});

// 2. Your custom service class handling local data persistence
class LocalStorageService {
  final SharedPreferences _prefs; // ThemeProvider accesses this directly via _storage._prefs

  LocalStorageService(this._prefs);

  // Optional: Add clean helper methods here
  String? getUserPhone() => _prefs.getString("user_phone");
//}
//get theme mode helper
 String? getThemeMode() {
  return _prefs.getString("user_theme_mode");
 }
 Future<void>catchThemeMode(String mode) async{
   await _prefs.setString("user_theme_mode", mode);
 }
 }
// 3. The service provider consumed by your ThemeModeNotifier
final localStorageServiceProvider = Provider<LocalStorageService>((ref) {
  final sharedPrefs = ref.watch(sharedPreferencesInstanceProvider);
  return LocalStorageService(sharedPrefs);
});