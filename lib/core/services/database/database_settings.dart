part of '../database_service.dart';

extension DatabaseSettings on DatabaseService {
  CollectionReference _settingsRef(String hotelId) =>
      _hotelDoc(hotelId).collection('settings');

  /// Get global app settings
  Future<AppSettings> getAppSettings(String hotelId) async {
    final doc = await _settingsRef(hotelId).doc('config').get();
    if (!doc.exists) {
      return AppSettings(id: 'config', hotelId: hotelId);
    }
    return AppSettings.fromJson(doc.data() as Map<String, dynamic>);
  }

  /// Stream global app settings
  Stream<AppSettings> streamAppSettings(String hotelId) {
    return _settingsRef(hotelId).doc('config').snapshots().map((snapshot) {
      if (!snapshot.exists) {
        return AppSettings(id: 'config', hotelId: hotelId);
      }
      return AppSettings.fromJson(snapshot.data() as Map<String, dynamic>);
    });
  }

  /// Update global app settings
  Future<void> updateAppSettings(AppSettings settings) async {
    await _settingsRef(settings.hotelId).doc('config').set(settings.toJson());
  }
}
