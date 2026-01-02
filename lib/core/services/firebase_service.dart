import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import '../../../firebase_options.dart';

/// Firebase initialization service
///
/// Handles Firebase initialization and provides access to Firebase instance.
class FirebaseService {
  static bool _initialized = false;

  /// Check if Firebase is initialized
  static bool get isInitialized => _initialized;

  /// Initialize Firebase
  ///
  /// This should be called once at app startup, before any Firebase services
  /// are used. It handles platform-specific configuration automatically.
  static Future<void> initialize() async {
    if (_initialized) {
      debugPrint('Firebase already initialized, skipping...');
      return;
    }

    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      _initialized = true;
      debugPrint('✅ Firebase initialized successfully');
    } catch (e) {
      debugPrint('❌ Firebase initialization error: $e');
      // In development, we might want to continue without Firebase
      if (kDebugMode) {
        debugPrint('⚠️  Continuing in debug mode without Firebase...');
      } else {
        rethrow;
      }
    }
  }

  /// Check if Firebase is available (for graceful degradation)
  static bool get isAvailable {
    try {
      Firebase.app();
      return true;
    } catch (e) {
      return false;
    }
  }
}
