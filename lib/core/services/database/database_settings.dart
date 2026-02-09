part of '../database_service.dart';

extension DatabaseSettings on DatabaseService {
  DatabaseReference get settingsRef => _ref('settings');

  /// Get global app settings
  Future<AppSettings> getAppSettings() async {
    final snapshot = await settingsRef.child('app').get();
    if (snapshot.value == null) return const AppSettings();
    return AppSettings.fromJson(_toMap(snapshot.value));
  }

  /// Stream global app settings
  Stream<AppSettings> streamAppSettings() {
    return settingsRef.child('app').onValue.map((event) {
      if (event.snapshot.value == null) return const AppSettings();
      return AppSettings.fromJson(_toMap(event.snapshot.value));
    });
  }

  /// Update global app settings
  Future<void> updateAppSettings(AppSettings settings) async {
    await settingsRef.child('app').set(settings.toJson());
  }
}
