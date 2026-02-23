part of '../database_service.dart';

extension DatabaseAudit on DatabaseService {
  CollectionReference _auditLogsRef() => firestore.collection('audit_logs');

  /// Stream audit logs for a specific hotel
  Stream<List<AuditLog>> streamAuditLogs(String hotelId) {
    return _auditLogsRef()
        .where('hotelId', isEqualTo: hotelId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return AuditLog.fromJson(data);
          }).toList();
        });
  }

  /// Stream all audit logs (for Super Admin)
  Stream<List<AuditLog>> streamAllAuditLogs() {
    return _auditLogsRef()
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return AuditLog.fromJson(data);
          }).toList();
        });
  }

  /// Save an audit log
  Future<void> saveAuditLog(AuditLog log) async {
    await _auditLogsRef().doc(log.id).set(log.toJson());
  }
}
