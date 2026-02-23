import 'package:hotel_manager/core/models/models.dart';
import 'package:hotel_manager/core/services/database_service.dart';
import 'package:hotel_manager/core/services/session/session_service.dart';
import 'package:uuid/uuid.dart';

abstract class IAuditService {
  Future<void> log({
    String? hotelId,
    String? userId,
    String? userName,
    String? userRole,
    String? entity,
    String? entityId,
    required AuditAction action,
    required String description,
    String? performedBy,
    String? performedByRole,
    String? targetUserId,
    Map<String, dynamic>? previousData,
    Map<String, dynamic>? newData,
    Map<String, dynamic>? metadata,
  });

  /// Simplified logging that extracts details from a User model
  Future<void> logUserAction({
    User? performer,
    required AuditAction action,
    required String description,
    String? targetUserId,
    String? hotelId,
    Map<String, dynamic>? previousData,
    Map<String, dynamic>? newData,
  });

  Stream<List<AuditLog>> streamAuditLogs(String hotelId);
}

/// Service for managing audit logs
/// Logs are stored in Firestore
class AuditService implements IAuditService {
  static AuditService? _instance;
  final DatabaseService _databaseService;
  final SessionService? _sessionService;
  final _uuid = const Uuid();

  AuditService._internal({
    required DatabaseService databaseService,
    SessionService? sessionService,
  }) : _databaseService = databaseService,
       _sessionService = sessionService;

  static void init(
    DatabaseService databaseService, {
    SessionService? sessionService,
  }) {
    _instance = AuditService._internal(
      databaseService: databaseService,
      sessionService: sessionService,
    );
  }

  factory AuditService() {
    return _instance!;
  }

  /// Log an action with automatic timestamp
  @override
  Future<void> log({
    String? hotelId,
    String? userId, // Legacy
    String? userName, // Legacy
    String? userRole, // Legacy
    String? entity, // Legacy
    String? entityId, // Legacy
    required AuditAction action,
    required String description,
    String? performedBy,
    String? performedByRole,
    String? targetUserId,
    Map<String, dynamic>? previousData,
    Map<String, dynamic>? newData,
    Map<String, dynamic>? metadata, // Legacy
  }) async {
    final log = AuditLog(
      id: _uuid.v4(),
      hotelId: hotelId,
      timestamp: DateTime.now(),
      actionType: action.name,
      performedBy: performedBy ?? userId ?? 'system',
      performedByRole: performedByRole ?? userRole ?? 'unknown',
      targetUserId: targetUserId ?? entityId,
      previousData: previousData,
      newData: newData ?? metadata,
      description: description,
    );

    await _databaseService.saveAuditLog(log);
  }

  @override
  Future<void> logUserAction({
    User? performer,
    required AuditAction action,
    required String description,
    String? targetUserId,
    String? hotelId,
    Map<String, dynamic>? previousData,
    Map<String, dynamic>? newData,
  }) async {
    final effectivePerformer = performer ?? _sessionService?.currentUser;

    if (effectivePerformer == null) {
      // Fallback to system log if no performer available
      return log(
        action: action,
        description: description,
        targetUserId: targetUserId,
        previousData: previousData,
        newData: newData,
      );
    }

    return log(
      hotelId: hotelId ?? effectivePerformer.hotelId,
      performedBy: effectivePerformer.id,
      performedByRole: effectivePerformer.role.name,
      action: action,
      description: description,
      targetUserId: targetUserId,
      previousData: previousData,
      newData: newData,
    );
  }

  /// Stream all logs for a hotel
  @override
  Stream<List<AuditLog>> streamAuditLogs(String hotelId) {
    return _databaseService.streamAuditLogs(hotelId);
  }

  /// Stream all logs globally (for Super Admin)
  Stream<List<AuditLog>> streamAllLogs() {
    return _databaseService.streamAllAuditLogs();
  }

  /// Legacy method for backward compatibility - use streamAllLogs instead
  List<AuditLog> getAllLogs() {
    return []; // Return empty list as logs are now reactive
  }
}
