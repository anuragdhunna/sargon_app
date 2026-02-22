part of '../database_service.dart';

extension DatabaseAudit on DatabaseService {
  CollectionReference _auditLogsRef(String hotelId) =>
      _hotelDoc(hotelId).collection('audit_logs');

  /// Stream audit logs
  Stream<List<AuditLog>> streamAuditLogs(String hotelId) {
    return _auditLogsRef(
      hotelId,
    ).orderBy('timestamp', descending: true).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return AuditLog.fromJson(data);
      }).toList();
    });
  }

  /// Save an audit log
  Future<void> saveAuditLog(AuditLog log) async {
    await _auditLogsRef(log.hotelId).doc(log.id).set(log.toJson());
  }
}
