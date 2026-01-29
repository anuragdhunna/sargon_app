part of '../database_service.dart';

extension DatabaseMenu on DatabaseService {
  DatabaseReference get menuItemsRef => _ref('menuItems');

  /// Stream all menu items (real-time)
  Stream<List<MenuItem>> streamMenuItems() {
    return menuItemsRef.onValue.map((event) {
      if (event.snapshot.value == null) return <MenuItem>[];
      final dynamic value = event.snapshot.value;
      if (value == null) return <MenuItem>[];
      final Map<dynamic, dynamic> data = (value is Map)
          ? value
          : (value is List ? value.asMap() : {});

      return data.entries.map((e) {
        final menuData = _toMap(e.value);
        return MenuItem.fromJson(menuData);
      }).toList();
    });
  }

  /// Stream available menu items
  Stream<List<MenuItem>> streamAvailableMenuItems() {
    return streamMenuItems().map(
      (items) => items.where((item) => item.isAvailable).toList(),
    );
  }

  /// Save menu item
  Future<void> saveMenuItem(MenuItem item) async {
    await menuItemsRef.child(item.id).set(item.toJson());
  }

  /// Get menu item by ID
  Future<MenuItem?> getMenuItem(String id) async {
    final snapshot = await menuItemsRef.child(id).get();
    if (!snapshot.exists || snapshot.value == null) return null;
    return MenuItem.fromJson(_toMap(snapshot.value));
  }
}
