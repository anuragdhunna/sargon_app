part of '../database_service.dart';

extension DatabaseMenu on DatabaseService {
  CollectionReference _menuItemsRef(String hotelId) =>
      _hotelDoc(hotelId).collection('menu_items');

  /// Stream all menu items
  Stream<List<MenuItem>> streamMenuItems(String hotelId) {
    return _menuItemsRef(hotelId).snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return MenuItem.fromJson(data);
          })
          .where((item) => item.isAvailable)
          .toList();
    });
  }

  /// Get all menu items (one-time)
  Future<List<MenuItem>> getMenuItems(String hotelId) async {
    final snapshot = await _menuItemsRef(hotelId).get();
    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return MenuItem.fromJson(data);
    }).toList();
  }

  /// Get single menu item
  Future<MenuItem?> getMenuItem(String hotelId, String id) async {
    final doc = await _menuItemsRef(hotelId).doc(id).get();
    if (!doc.exists) return null;
    return MenuItem.fromJson(doc.data() as Map<String, dynamic>);
  }

  /// Save or Update Menu Item
  Future<void> saveMenuItem(MenuItem item) async {
    await _menuItemsRef(item.hotelId).doc(item.id).set(item.toJson());
  }

  /// Delete Menu Item
  Future<void> deleteMenuItem(String hotelId, String id) async {
    await _menuItemsRef(hotelId).doc(id).delete();
  }
}
