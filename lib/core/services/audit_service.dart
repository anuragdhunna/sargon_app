import 'package:hotel_manager/core/models/models.dart';
import 'package:hotel_manager/core/services/database_service.dart';
import 'package:uuid/uuid.dart';

abstract class IAuditService {
  Future<void> log({
    required String hotelId,
    required String userId,
    required String userName,
    required String userRole,
    required AuditAction action,
    required String entity,
    required String entityId,
    required String description,
    Map<String, dynamic>? metadata,
  });
  Stream<List<AuditLog>> streamAuditLogs(String hotelId);
}

/// Service for managing audit logs
/// Logs are stored in Firebase Realtime Database
class AuditService implements IAuditService {
  static AuditService? _instance;
  final DatabaseService _databaseService;
  final _uuid = const Uuid();

  AuditService._internal({required DatabaseService databaseService})
    : _databaseService = databaseService;

  static void init(DatabaseService databaseService) {
    _instance = AuditService._internal(databaseService: databaseService);
  }

  factory AuditService() {
    _instance ??= AuditService._internal(databaseService: DatabaseService());
    return _instance!;
  }

  /// Log an action with automatic timestamp
  @override
  Future<void> log({
    required String hotelId,
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
      hotelId: hotelId,
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
  }

  /// Stream all logs (for admin view)
  @override
  Stream<List<AuditLog>> streamAuditLogs(String hotelId) {
    return _databaseService.streamAuditLogs(hotelId);
  }

  /// Legacy method for backward compatibility - use streamAllLogs instead
  List<AuditLog> getAllLogs() {
    return []; // Return empty list as logs are now reactive
  }
}
