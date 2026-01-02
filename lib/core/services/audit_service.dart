import 'package:hotel_manager/core/models/models.dart';
import 'package:hotel_manager/core/services/database_service.dart';
import 'package:uuid/uuid.dart';

/// Service for managing audit logs
/// Logs are stored in Firebase Realtime Database
class AuditService {
  static AuditService? _instance;
  final DatabaseService _databaseService;
  final _uuid = const Uuid();

  AuditService._internal({required DatabaseService databaseService})
    : _databaseService = databaseService;

  static void init(DatabaseService databaseService) {
    _instance = AuditService._internal(databaseService: databaseService);
  }

  factory AuditService() {
    if (_instance == null) {
      // Return a temporary instance if not initialized (though it should be in main)
      // This is to avoid hard crashes during initialization if some cubit calls it too early
      return AuditService._internal(databaseService: DatabaseService());
    }
    return _instance!;
  }

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

    await _databaseService.saveAuditLog(log);
    print('AUDIT LOG: ${log.description}');
  }

  /// Stream all logs (for admin view)
  Stream<List<AuditLog>> streamAllLogs() {
    return _databaseService.streamAuditLogs();
  }

  /// Legacy method for backward compatibility - use streamAllLogs instead
  List<AuditLog> getAllLogs() {
    return []; // Return empty list as logs are now reactive
  }
}
