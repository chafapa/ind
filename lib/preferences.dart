import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class AppPreferences {
  static late SharedPreferences _prefs;
  static const _firstTimeKey = 'is_first_time';
  static const _topPicksKey = 'top_picks';
  
  // NEW: Location storage keys
  static const _locationLatKey = 'location_latitude';
  static const _locationLngKey = 'location_longitude';

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static bool isFirstTime() => _prefs.getBool(_firstTimeKey) ?? true;
  static Future<void> setFirstTimeDone() async => _prefs.setBool(_firstTimeKey, false);
  static Future<void> resetFirstTimeFlag() async => _prefs.remove(_firstTimeKey);

  /// Save a list of the top-3 restaurant names
  static Future<void> saveTopPicks(List<String> names) async {
    await _prefs.setStringList(_topPicksKey, names);
  }

  /// Retrieve that list (empty if none saved)
  static List<String> getTopPicks() {
    return _prefs.getStringList(_topPicksKey) ?? [];
  }

  // NEW: Save location coordinates
  static Future<void> setLocation(double latitude, double longitude) async {
    await _prefs.setDouble(_locationLatKey, latitude);
    await _prefs.setDouble(_locationLngKey, longitude);
  }

  // NEW: Get saved location (returns null if not set)
  static LatLng? getLocation() {
    final lat = _prefs.getDouble(_locationLatKey);
    final lng = _prefs.getDouble(_locationLngKey);
    return (lat != null && lng != null) ? LatLng(lat, lng) : null;
  }

  // NEW: Clear saved location
  static Future<void> clearLocation() async {
    await _prefs.remove(_locationLatKey);
    await _prefs.remove(_locationLngKey);
  }
}