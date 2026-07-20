import 'package:shared_preferences/shared_preferences.dart';

class SessionService {
  SessionService._();

  static const String _userIdKey = 'rentit_user_id';
  static const String _areaIdKey = 'rentit_area_id';

  // Backend auth is parked and APIs currently require explicit IDs.
  // These Postman test IDs keep the app usable until real auth is delivered.
  static const int defaultUserId = 11;
  static const int defaultAreaId = 1;

  static Future<int> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_userIdKey) ?? defaultUserId;
  }

  static Future<void> setUserId(int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_userIdKey, value);
  }

  static Future<int> getAreaId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_areaIdKey) ?? defaultAreaId;
  }

  static Future<void> setAreaId(int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_areaIdKey, value);
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userIdKey);
    await prefs.remove(_areaIdKey);
    await prefs.remove('auth_token');
  }
}
