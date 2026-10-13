part of '../database_service.dart';

extension DatabaseTables on DatabaseService {
  CollectionReference _tablesRef(String hotelId) =>
      _hotelDoc(hotelId).collection('tables');

  /// Stream all tables
  Stream<List<TableEntity>> streamTables(String hotelId) {
    return _tablesRef(hotelId).snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return TableEntity.fromJson(data);
          })
          .where((t) => t.isActive)
          .toList();
    });
  }

  /// Get all tables (one-time)
  Future<List<TableEntity>> getTables(String hotelId) async {
    final snapshot = await _tablesRef(hotelId).get();
    return snapshot.docs
        .map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return TableEntity.fromJson(data);
        })
        .where((t) => t.isActive)
        .toList();
  }

  /// Save or Update Table
  Future<void> saveTable(TableEntity table) async {
    await _tablesRef(table.hotelId).doc(table.id).set(table.toJson());
  }

  /// Delete Table (mark inactive)
  Future<void> deleteTable(String hotelId, String tableId) async {
    await _tablesRef(hotelId).doc(tableId).update({'isActive': false});
  }

  /// Update Table Status
  Future<void> updateTableStatus(
    String hotelId,
    String tableId,
    TableStatus status,
  ) async {
    await _tablesRef(hotelId).doc(tableId).update({
      'status': status.name,
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

}
