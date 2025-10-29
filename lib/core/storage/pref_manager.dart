// lib/core/storage/pref_manager.dart
import 'package:shared_preferences/shared_preferences.dart';

/// Lớp quản lý SharedPreferences — Singleton.
/// Dùng cho các thao tác cơ bản (string, bool, clear, remove...).
class PrefManager {
  static SharedPreferences? _prefs;

  /// Gọi trong AppBinding.init()
  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  // --------------------------
  // 🔹 Generic helpers
  // --------------------------

  static Future<void> setString(String key, String value) async {
    await _prefs?.setString(key, value);
  }

  static String? getString(String key) {
    return _prefs?.getString(key);
  }

  static Future<void> setBool(String key, bool value) async {
    await _prefs?.setBool(key, value);
  }

  static bool? getBool(String key) {
    return _prefs?.getBool(key);
  }

  static Future<void> remove(String key) async {
    await _prefs?.remove(key);
  }

  static Future<void> clear() async {
    await _prefs?.clear();
  }
}
