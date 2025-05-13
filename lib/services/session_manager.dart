import 'package:shared_preferences/shared_preferences.dart';

class Session {
  final String token;
  final int expiry;
  final String name;
  final String phone;
  final String? photo;
  final int? userId;

  Session({
    required this.token,
    required this.expiry,
    required this.name,
    required this.phone,
    this.photo,
    this.userId,
  });
}

class SessionManager {
  static const _keyToken = 'session_token';
  static const _keyExpiry = 'session_expiry';
  static const _keyName = 'session_name';
  static const _keyPhone = 'session_phone';
  static const _keyPhoto = 'session_photo';
  static const _keyUserId = 'session_userId';

  static Future<void> saveSession({
    required String token,
    required int expiry,
    required String name,
    required String phone,
    String? photo,
    int? userId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyToken, token);
    await prefs.setInt(_keyExpiry, expiry);
    await prefs.setString(_keyName, name);
    await prefs.setString(_keyPhone, phone);
    if (photo != null) {
      await prefs.setString(_keyPhoto, photo);
    }
    if (userId != null) {
      await prefs.setInt(_keyUserId, userId);
    }
  }

  static Future<Session?> loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_keyToken);
    final expiry = prefs.getInt(_keyExpiry);
    if (token == null || expiry == null) return null;
    final name = prefs.getString(_keyName) ?? '';
    final phone = prefs.getString(_keyPhone) ?? '';
    final photo = prefs.getString(_keyPhoto);
    final userId = prefs.getInt(_keyUserId);
    return Session(
      token: token,
      expiry: expiry,
      name: name,
      phone: phone,
      photo: photo,
      userId: userId,
    );
  }

  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyToken);
    await prefs.remove(_keyExpiry);
    await prefs.remove(_keyName);
    await prefs.remove(_keyPhone);
    await prefs.remove(_keyPhoto);
    await prefs.remove(_keyUserId);
  }
}
