import 'package:flutter/foundation.dart';
import '../../models/user_model.dart';
import '../storage/secure_storage_service.dart';

/// Manages the active user session and provides global access to current user info
class SessionService {
  final SecureStorageService _storageService;
  User? _currentUser;

  SessionService({required SecureStorageService storageService})
    : _storageService = storageService;

  /// Currently logged in user
  User? get currentUser => _currentUser;

  /// Check if a session is active
  bool get hasActiveSession => _currentUser != null;

  /// Initialize session from local storage
  Future<void> initialize() async {
    _currentUser = await _storageService.getUserProfile();
    if (_currentUser != null) {
      debugPrint('✅ Session initialized for: ${_currentUser?.name}');
    }
  }

  /// Set the current user session
  Future<void> setSession(User user) async {
    _currentUser = user;
    await _storageService.saveUserProfile(user);
    debugPrint('✅ Session started for: ${user.name}');
  }

  /// Clear the current user session
  Future<void> clearSession() async {
    _currentUser = null;
    await _storageService.deleteUserProfile();
    debugPrint('✅ Session cleared');
  }

  /// Refresh the current user profile
  void updateCurrentUser(User user) {
    _currentUser = user;
    _storageService.saveUserProfile(user);
  }
}
