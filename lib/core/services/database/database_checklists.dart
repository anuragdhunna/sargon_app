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
}
