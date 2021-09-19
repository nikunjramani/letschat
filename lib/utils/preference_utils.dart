import 'package:shared_preferences/shared_preferences.dart';

class PreferenceUtils {
  static Future<void> setString(String key, String value) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return await preferences.setString(key, value);
  }

  static Future<void> setBoolean(String key, bool value) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return await preferences.setBool(key, value);
  }

  static Future<void> setInteger(String key, int value) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return await preferences.setInt(key, value);
  }

  static Future<String> getString(String key) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.getString(key);
  }

  static Future<bool> getBool(String key) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.getBool(key);
  }

  static Future<int> getInt(String key) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.getInt(key);
  }
}
