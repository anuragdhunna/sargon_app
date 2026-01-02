part of '../database_service.dart';

extension DatabaseAudit on DatabaseService {
  DatabaseReference get auditLogsRef => _ref('auditLogs');

  /// Stream audit logs
  Stream<List<AuditLog>> streamAuditLogs() {
    return auditLogsRef.onValue.map((event) {
      if (event.snapshot.value == null) return [];
      final data = _toMap(event.snapshot.value);
      return data.entries
          .map((e) => AuditLog.fromJson(_toMap(e.value)))
          .toList();
    });
  }

  /// Save an audit log
  Future<void> saveAuditLog(AuditLog log) async {
    await auditLogsRef.child(log.id).set(log.toJson());
  }
}
