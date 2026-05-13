import 'package:shared_preferences/shared_preferences.dart';

class TokenStorage {
  static const String _tokenKey = 'jwt_token';
  static const String _usernameKey = 'username';
  static const String _planKey = 'plan';
  static const String _storageUsedKey = 'storage_used';
  static const String _storageLimitKey = 'storage_limit';

  // Token
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  // User Info save karo
  static Future<void> saveUserInfo(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, data['token']);
    await prefs.setString(_usernameKey, data['username'] ?? '');
    await prefs.setString(_planKey, data['plan'] ?? 'FREE');
    await prefs.setString(_storageUsedKey, data['storageUsed'] ?? '0');
    await prefs.setString(_storageLimitKey, data['storageLimit'] ?? '0');
  }

  // Getters
  static Future<String?> getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_usernameKey);
  }

  static Future<String?> getPlan() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_planKey);
  }

  static Future<String?> getStorageUsed() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_storageUsedKey);
  }

  static Future<String?> getStorageLimit() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_storageLimitKey);
  }

  // Clear all
  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}