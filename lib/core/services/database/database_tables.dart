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

  /// Initialize dummy tables if none exist
  // Future<void> initializeDummyTables(String hotelId) async {
  //   try {
  //     final snapshot = await tablesRef.get();
  //     if (snapshot.value != null) return;

  //     final dummyTables = [
  //       TableEntity(
  //         hotelId: hotelId,
  //         id: 't1',
  //         name: 'Window Table 1',
  //         tableCode: 'T1',
  //         maxCapacity: 4,
  //         status: TableStatus.available,
  //       ),
  //       TableEntity(
  //         hotelId: hotelId,
  //         id: 't2',
  //         name: 'Window Table 2',
  //         tableCode: 'T2',
  //         maxCapacity: 4,
  //         status: TableStatus.occupied,
  //       ),
  //       TableEntity(
  //         hotelId: hotelId,
  //         id: 't3',
  //         name: 'Center Table 3',
  //         tableCode: 'T3',
  //         maxCapacity: 6,
  //         status: TableStatus.reserved,
  //       ),
  //       TableEntity(
  //         hotelId: hotelId,
  //         id: 'b1',
  //         name: 'Bar Counter 1',
  //         tableCode: 'B1',
  //         maxCapacity: 1,
  //         status: TableStatus.available,
  //         isBarTable: true,
  //       ),
  //     ];

  //     for (final table in dummyTables) {
  //       await saveTable(table);
  //     }
  //   } catch (e) {
  //     debugPrint('Error initializing dummy tables: $e');
  //   }
  // }
}
