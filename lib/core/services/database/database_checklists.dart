part of '../database_service.dart';

extension DatabaseChecklists on DatabaseService {
  DatabaseReference get checklistsRef => _ref('checklists');

  /// Stream all checklists (real-time)
  Stream<List<Checklist>> streamChecklists() {
    return checklistsRef.onValue.map((event) {
      if (event.snapshot.value == null) return <Checklist>[];
      final dynamic value = event.snapshot.value;
      if (value == null) return <Checklist>[];
      final Map<dynamic, dynamic> data = (value is Map)
          ? value
          : (value is List ? value.asMap() : {});

      return data.entries.map((e) {
        final checklistData = _toMap(e.value);
        return Checklist.fromJson(checklistData);
      }).toList();
    });
  }

  /// Stream checklists by role
  Stream<List<Checklist>> streamChecklistsByRole(UserRole role) {
    return streamChecklists().map(
      (checklists) => checklists.where((c) => c.assignedRole == role).toList(),
    );
  }

  /// Save checklist
  Future<void> saveChecklist(Checklist checklist) async {
    await checklistsRef.child(checklist.id).set(checklist.toJson());
  }

  /// Create a cleaning checklist for a table
  Future<void> createTableCleaningChecklist(
    String tableId,
    String tableCode,
  ) async {
    final id =
        'clean_table_${tableId}_${DateTime.now().millisecondsSinceEpoch}';
    final checklist = Checklist(
      id: id,
      title: 'Clean Table $tableCode',
      description: 'Standard cleaning protocol for Table $tableCode',
      type: ChecklistType.housekeeping,
      status: ChecklistStatus.pending,
      assignedRole: UserRole.housekeeping,
      dueDate: DateTime.now().add(const Duration(minutes: 15)),
      items: const [
        ChecklistItem(id: '1', task: 'Clear dishes and leftovers'),
        ChecklistItem(id: '2', task: 'Sanitize table surface'),
        ChecklistItem(id: '3', task: 'Reset cutlery and napkins'),
      ],
      metadata: {'tableId': tableId},
    );
    await saveChecklist(checklist);
  }

  /// Create a cleaning checklist for a room
  Future<void> createRoomCleaningChecklist(
    String roomId,
    String roomNumber,
  ) async {
    final id = 'clean_room_${roomId}_${DateTime.now().millisecondsSinceEpoch}';
    final checklist = Checklist(
      id: id,
      title: 'Clean Room $roomNumber',
      description: 'Standard cleaning protocol for Room $roomNumber',
      type: ChecklistType.housekeeping,
      status: ChecklistStatus.pending,
      assignedRole: UserRole.housekeeping,
      dueDate: DateTime.now().add(const Duration(minutes: 45)),
      items: const [
        ChecklistItem(id: '1', task: 'Change Bed Linens'),
        ChecklistItem(id: '2', task: 'Vacuum Floor'),
        ChecklistItem(id: '3', task: 'Sanitize Bathroom'),
        ChecklistItem(id: '4', task: 'Restock Amenities'),
      ],
      metadata: {'roomId': roomId},
    );
    await saveChecklist(checklist);
  }
}
