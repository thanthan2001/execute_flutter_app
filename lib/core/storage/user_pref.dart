// lib/core/storage/user_pref.dart
import 'dart:convert';
import 'package:my_clean_app/core/storage/pref_manager.dart';
import 'package:my_clean_app/features/auth/data/models/user_model.dart';

/// Quản lý thông tin người dùng trong SharedPreferences
class UserPref {
  static const String _userKey = 'USER';
  static const String _tokenKey = 'TOKEN';

  /// 🔹 Lưu UserModel
  static Future<void> saveUser(UserModel user) async {
    final jsonString = jsonEncode(user.toJson());
    await PrefManager.setString(_userKey, jsonString);
  }

  /// 🔹 Lấy UserModel (nếu có)
  static UserModel? getUser() {
    final jsonString = PrefManager.getString(_userKey);
    if (jsonString == null) return null;
    return UserModel.fromJson(jsonDecode(jsonString));
  }

  /// 🔹 Xóa User
  static Future<void> clearUser() async {
    await PrefManager.remove(_userKey);
  }

  /// 🔹 Token
  static Future<void> saveToken(String token) async {
    await PrefManager.setString(_tokenKey, token);
  }

  static String? getToken() {
    return PrefManager.getString(_tokenKey);
  }

  static Future<void> clearToken() async {
    await PrefManager.remove(_tokenKey);
  }

  /// 🔹 Kiểm tra trạng thái đăng nhập
  static bool isLoggedIn() {
    return getUser() != null;
  }
}
