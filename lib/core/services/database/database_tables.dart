part of '../database_service.dart';

extension DatabaseTables on DatabaseService {
  DatabaseReference get tablesRef => _ref('tables');

  /// Stream all tables
  Stream<List<TableEntity>> streamTables() {
    return tablesRef.onValue.map((event) {
      if (event.snapshot.value == null) return [];
      final data = _toMap(event.snapshot.value);
      return data.entries
          .map((e) => TableEntity.fromJson(_toMap(e.value)))
          .where((t) => t.isActive)
          .toList();
    });
  }

  /// Get all tables (one-time)
  Future<List<TableEntity>> getTables() async {
    final snapshot = await tablesRef.get();
    if (snapshot.value == null) return [];
    final data = _toMap(snapshot.value);
    return data.entries
        .map((e) => TableEntity.fromJson(_toMap(e.value)))
        .where((t) => t.isActive)
        .toList();
  }

  /// Save or Update Table
  Future<void> saveTable(TableEntity table) async {
    await tablesRef.child(table.id).set(table.toJson());
  }

  /// Delete Table (mark inactive)
  Future<void> deleteTable(String tableId) async {
    await tablesRef.child(tableId).child('isActive').set(false);
  }

  /// Initialize dummy tables if none exist
  Future<void> initializeDummyTables() async {
    final snapshot = await tablesRef.get();
    if (snapshot.value != null) return;

    final dummyTables = [
      TableEntity(
        id: 't1',
        name: 'Window Table 1',
        tableCode: 'T1',
        maxCapacity: 4,
        status: TableStatus.available,
      ),
      TableEntity(
        id: 't2',
        name: 'Window Table 2',
        tableCode: 'T2',
        maxCapacity: 4,
        status: TableStatus.occupied,
      ),
      TableEntity(
        id: 't3',
        name: 'Center Table 3',
        tableCode: 'T3',
        maxCapacity: 6,
        status: TableStatus.reserved,
      ),
      TableEntity(
        id: 'b1',
        name: 'Bar Counter 1',
        tableCode: 'B1',
        maxCapacity: 1,
        status: TableStatus.available,
        isBarTable: true,
      ),
    ];

    for (final table in dummyTables) {
      await saveTable(table);
    }
  }

  /// Update Table Status
  Future<void> updateTableStatus(String tableId, TableStatus status) async {
    await tablesRef.child(tableId).child('status').set(status.name);
  }
}
