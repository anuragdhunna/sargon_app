part of '../database_service.dart';

extension DatabaseUtils on DatabaseService {
  /// Generate a new push key (unique ID)
  String generateKey(String path) {
    return _ref(path).push().key ??
        DateTime.now().millisecondsSinceEpoch.toString();
  }

  /// Enable offline persistence
  void enableOfflinePersistence() {
    if (!kIsWeb) {
      _database.setPersistenceEnabled(true);
      debugPrint('✅ Offline persistence enabled');
    }
  }

  /// Go offline (disconnect from server)
  void goOffline() {
    _database.goOffline();
    debugPrint('📴 Database offline');
  }

  /// Go online (reconnect to server)
  void goOnline() {
    _database.goOnline();
    debugPrint('📶 Database online');
  }

  /// Public helper to convert Firebase data to Map
  Map<String, dynamic> toMap(dynamic value) => _toMap(value);

  /// Helper to convert Firebase dynamic value to Map<String, dynamic> recursively
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
