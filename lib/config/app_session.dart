import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend_dilaundry/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSession {
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  static Future<UserModel?> getUser() async {
    final pref = await SharedPreferences.getInstance();
    String? userString = pref.getString('user');
    if (userString == null) return null;

    var userMap = jsonDecode(userString);
    return UserModel.fromJson(userMap);
  }

  static Future<bool> setUser(Map userMap) async {
    final pref = await SharedPreferences.getInstance();
    String userString = jsonEncode(userMap);
    bool success = await pref.setString('user', userString);
    return success;
  }

  static Future<bool> removeUser() async {
    final pref = await SharedPreferences.getInstance();
    bool success = await pref.remove('user');
    return success;
  }

  // Token Sanctum disimpan di penyimpanan aman platform, bukan di
  // SharedPreferences, karena token adalah kredensial masuk pengguna.
  static Future<String?> getBearerToken() async {
    return _secureStorage.read(key: 'bearer_token');
  }

  static Future<bool> setBearerToken(String bearerToken) async {
    await _secureStorage.write(key: 'bearer_token', value: bearerToken);
    return true;
  }

  static Future<bool> removeBearerToken() async {
    await _secureStorage.delete(key: 'bearer_token');
    return true;
  }

  static Future<void> clear() async {
    await removeUser();
    await removeBearerToken();
  }
}
