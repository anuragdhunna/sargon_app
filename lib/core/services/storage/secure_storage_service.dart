import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../models/user_model.dart';

/// Service for persisting sensitive data locally
class SecureStorageService {
  final FlutterSecureStorage _storage;

  SecureStorageService({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  static const _kUserKey = 'auth_user_profile';

  /// Save user profile to secure storage
  Future<void> saveUserProfile(User user) async {
    await _storage.write(key: _kUserKey, value: jsonEncode(user.toJson()));
  }

  /// Get user profile from secure storage
  Future<User?> getUserProfile() async {
    final data = await _storage.read(key: _kUserKey);
    if (data == null) return null;
    try {
      return User.fromJson(jsonDecode(data) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  /// Delete user profile
  Future<void> deleteUserProfile() async {
    await _storage.delete(key: _kUserKey);
  }

  /// Clear all stored data
  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
