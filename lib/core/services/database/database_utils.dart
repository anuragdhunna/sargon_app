part of '../database_service.dart';

extension DatabaseUtils on DatabaseService {
  /// Generate a new unique ID
  String generateKey(String collectionPath, {String? hotelId}) {
    if (hotelId != null) {
      return _hotelDoc(hotelId).collection(collectionPath).doc().id;
    }
    return _firestore.collection(collectionPath).doc().id;
  }

  /// Enable offline persistence
  void enableOfflinePersistence() {
    _firestore.settings = const Settings(persistenceEnabled: true);
    debugPrint('✅ Firestore offline persistence enabled');
  }

  /// Go offline (disconnect from server)
  void goOffline() {
    _firestore.disableNetwork();
    debugPrint('📴 Firestore offline');
  }

  /// Go online (reconnect to server)
  void goOnline() {
    _firestore.enableNetwork();
    debugPrint('📶 Firestore online');
  }

  /// Public helper to convert Firestore data to Map
  Map<String, dynamic> toMap(dynamic value) => _toMap(value);

  /// Helper to convert Firebase dynamic value to `Map<String, dynamic>` recursively
  /// Handles both Map and List (for numeric keys) and works across Web/Mobile
  Map<String, dynamic> _toMap(dynamic value) {
    if (value == null) return {};

    if (value is Map) {
      return value.map((k, v) {
        final key = k.toString();
        if (v is Map || v is List) {
          return MapEntry(key, _recursiveConvert(v));
        }
        return MapEntry(key, v);
      });
    }

    if (value is List) {
      return value.asMap().map((k, v) {
        final key = k.toString();
        if (v is Map || v is List) {
          return MapEntry(key, _recursiveConvert(v));
        }
        return MapEntry(key, v);
      });
    }

    return {};
  }

  dynamic _recursiveConvert(dynamic value) {
    if (value is Map) {
      return value.map((k, v) {
        final key = k.toString();
        if (v is Map || v is List) {
          return MapEntry(key, _recursiveConvert(v));
        }
        return MapEntry(key, v);
      });
    }
    if (value is List) {
      return value.map((item) {
        if (item is Map || item is List) {
          return _recursiveConvert(item);
        }
        return item;
      }).toList();
    }
    return value;
  }
}
