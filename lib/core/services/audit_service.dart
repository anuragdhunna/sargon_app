import 'package:hotel_manager/core/models/audit_log.dart';
import 'package:uuid/uuid.dart';

/// Service for managing audit logs
/// Logs are stored locally and synced to backend (Firestore)
class AuditService {
  static final AuditService _instance = AuditService._internal();
  factory AuditService() => _instance;
  AuditService._internal();

  final _uuid = const Uuid();
  final List<AuditLog> _localLogs = [
    AuditLog(
      id: 'log_1',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      userId: 'user_123',
      userName: 'John Manager',
      userRole: 'manager',
      action: AuditAction.checkIn,
      entity: 'booking',
      entityId: 'bk_101',
      description: 'Checked in guest Mr. Smith to Room 101',
    ),
    AuditLog(
      id: 'log_2',
      timestamp: DateTime.now().subtract(const Duration(hours: 5)),
      userId: 'user_456',
      userName: 'Alice Housekeeping',
      userRole: 'housekeeping',
      action: AuditAction.update,
      entity: 'room',
      entityId: 'rm_102',
      description: 'Marked Room 102 as Cleaned',
    ),
    AuditLog(
      id: 'log_3',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      userId: 'user_789',
      userName: 'Chef Gordon',
      userRole: 'chef',
      action: AuditAction.update,
      entity: 'inventory',
      entityId: 'inv_55',
      description: 'Updated stock for Tomato Sauce: -2 bottles',
    ),
    AuditLog(
      id: 'log_4',
      timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
      userId: 'system',
      userName: 'System',
      userRole: 'system',
      action: AuditAction.create,
      entity: 'checklist',
      entityId: 'chk_999',
      description: 'Auto-created cleaning task for Room 105',
    ),
  ];

  /// Log an action with automatic timestamp
  Future<void> log({
    required String userId,
    required String userName,
    required String userRole,
    required AuditAction action,
    required String entity,
    required String entityId,
    required String description,
    Map<String, dynamic>? metadata,
  }) async {
    final log = AuditLog(
      id: _uuid.v4(),
      timestamp: DateTime.now(),
      userId: userId,
      userName: userName,
      userRole: userRole,
      action: action,
      entity: entity,
      entityId: entityId,
      description: description,
      metadata: metadata,
    );

    // Store locally
    _localLogs.add(log);

    // TODO: Sync to Firestore
    // await FirebaseFirestore.instance
    //     .collection('audit_logs')
    //     .doc(log.id)
    //     .set(log.toJson());

    print('AUDIT LOG: ${log.description}');
  }

  /// Get all logs (for admin view)
  List<AuditLog> getAllLogs() {
    return List.unmodifiable(_localLogs);
  }

  /// Get logs filtered by entity
  List<AuditLog> getLogsByEntity(String entity) {
    return _localLogs.where((log) => log.entity == entity).toList();
  }

  /// Get logs filtered by user
  List<AuditLog> getLogsByUser(String userId) {
    return _localLogs.where((log) => log.userId == userId).toList();
  }

  /// Get logs filtered by date range
  List<AuditLog> getLogsByDateRange(DateTime start, DateTime end) {
    return _localLogs
        .where((log) =>
            log.timestamp.isAfter(start) && log.timestamp.isBefore(end))
        .toList();
  }

  /// Clear local cache (use with caution)
  void clearLocalCache() {
    _localLogs.clear();
  }
}
