part of '../database_service.dart';

extension DatabaseChecklists on DatabaseService {
  CollectionReference _checklistsRef(String hotelId) =>
      _hotelDoc(hotelId).collection('checklists');

  /// Stream all checklists (real-time)
  Stream<List<Checklist>> streamChecklists(String hotelId) {
    return _checklistsRef(hotelId).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Checklist.fromJson(data);
      }).toList();
    });
  }

  /// Stream checklists by role
  Stream<List<Checklist>> streamChecklistsByRole(
    String hotelId,
    UserRole role,
  ) {
    return streamChecklists(hotelId).map(
      (checklists) => checklists.where((c) => c.assignedRole == role).toList(),
    );
  }

  /// Save checklist
  Future<void> saveChecklist(Checklist checklist) async {
    await _checklistsRef(
      checklist.hotelId,
    ).doc(checklist.id).set(checklist.toJson());
  }

  /// Create a cleaning checklist for a table
  Future<void> createTableCleaningChecklist(
    String tableId,
    String tableCode,
    String hotelId,
  ) async {
    final id =
        'clean_table_${tableId}_${DateTime.now().millisecondsSinceEpoch}';
    final checklist = Checklist(
      hotelId: hotelId,
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
    String hotelId,
  ) async {
    final id = 'clean_room_${roomId}_${DateTime.now().millisecondsSinceEpoch}';
    final checklist = Checklist(
      hotelId: hotelId,
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
