part of '../database_service.dart';

extension DatabaseTables on DatabaseService {
  DatabaseReference get tablesRef => _ref('tables');
  DatabaseReference get tableGroupsRef => _ref('tableGroups');

  Stream<List<TableEntity>> streamTables() {
    return tablesRef.onValue.map((event) {
      if (event.snapshot.value == null) return <TableEntity>[];
      final dynamic value = event.snapshot.value;
      Map<dynamic, dynamic> data = value is Map ? value : {};

      return data.entries.map((e) {
        return TableEntity.fromJson(_toMap(e.value));
      }).toList()..sort((a, b) => a.tableCode.compareTo(b.tableCode));
    });
  }

  Future<void> saveTable(TableEntity table) async {
    await tablesRef.child(table.id).set(table.toJson());
  }

  Future<void> updateTableStatus(String tableId, TableStatus status) async {
    await tablesRef.child(tableId).update({'status': status.name});

    // Auto-create cleaning checklist
    if (status == TableStatus.cleaning) {
      try {
        final tableSnap = await tablesRef.child(tableId).get();
        if (tableSnap.value != null) {
          final tableData = _toMap(tableSnap.value);
          final tableCode = tableData['tableCode'] ?? tableId;
          await createTableCleaningChecklist(tableId, tableCode);
        }
      } catch (e) {
        debugPrint('Error creating auto-checklist: $e');
      }
    }
  }

  Future<void> saveTableGroup(TableGroup group) async {
    await tableGroupsRef.child(group.id).set(group.toJson());
  }

  Stream<List<TableGroup>> streamTableGroups() {
    return tableGroupsRef.onValue.map((event) {
      if (event.snapshot.value == null) return <TableGroup>[];
      final dynamic value = event.snapshot.value;
      Map<dynamic, dynamic> data = value is Map ? value : {};

      return data.entries.map((e) {
        return TableGroup.fromJson(_toMap(e.value));
      }).toList();
    });
  }

  Future<void> initializeDummyTables() async {
    try {
      final snapshot = await tablesRef.get();
      if (snapshot.value != null) return;

      final tables = [
        const TableEntity(
          id: 't1',
          tableCode: 'T1',
          minCapacity: 2,
          maxCapacity: 4,
        ),
        const TableEntity(
          id: 't2',
          tableCode: 'T2',
          minCapacity: 2,
          maxCapacity: 4,
        ),
        const TableEntity(
          id: 't3',
          tableCode: 'T3',
          minCapacity: 4,
          maxCapacity: 6,
        ),
        const TableEntity(
          id: 't4',
          tableCode: 'T4',
          minCapacity: 4,
          maxCapacity: 6,
          joinableTableIds: ['t5'],
        ),
        const TableEntity(
          id: 't5',
          tableCode: 'T5',
          minCapacity: 4,
          maxCapacity: 6,
          joinableTableIds: ['t4'],
        ),
        const TableEntity(
          id: 'b1',
          tableCode: 'B1',
          minCapacity: 1,
          maxCapacity: 1,
          isBarTable: true,
        ),
        const TableEntity(
          id: 'b2',
          tableCode: 'B2',
          minCapacity: 1,
          maxCapacity: 1,
          isBarTable: true,
        ),
      ];

      for (var table in tables) {
        await saveTable(table);
      }
    } catch (e) {
      debugPrint('Error initializing dummy tables: $e');
    }
  }
}
