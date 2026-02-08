part of '../database_service.dart';

extension DatabaseMenu on DatabaseService {
  DatabaseReference get menuRef => _ref('menu_items');

  /// Stream all menu items
  Stream<List<MenuItem>> streamMenuItems() {
    return menuRef.onValue.map((event) {
      if (event.snapshot.value == null) return [];
      final data = _toMap(event.snapshot.value);
      return data.entries
          .map((e) => MenuItem.fromJson(_toMap(e.value)))
          .where((item) => item.isAvailable)
          .toList();
    });
  }

  /// Get all menu items (one-time)
  Future<List<MenuItem>> getMenuItems() async {
    final snapshot = await menuRef.get();
    if (snapshot.value == null) return [];
    final data = _toMap(snapshot.value);
    return data.entries.map((e) => MenuItem.fromJson(_toMap(e.value))).toList();
  }

  /// Get single menu item
  Future<MenuItem?> getMenuItem(String id) async {
    final snapshot = await menuRef.child(id).get();
    if (snapshot.value == null) return null;
    return MenuItem.fromJson(_toMap(snapshot.value));
  }

  /// Save or Update Menu Item
  Future<void> saveMenuItem(MenuItem item) async {
    await menuRef.child(item.id).set(item.toJson());
  }

  /// Delete Menu Item
  Future<void> deleteMenuItem(String id) async {
    await menuRef.child(id).remove();
  }
}
