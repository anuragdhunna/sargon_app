import 'package:equatable/equatable.dart';

/// Audit action types
enum AuditAction {
  create,
  update,
  delete,
  complete,
  regularize,
  approve,
  reject,
  login,
  logout,
  checkIn,
  checkOut,
  receive,
  createPO,
  cancelPO,
  roleChange,
  statusChange,
  hotelAssignment,
  other,
}

/// Industry-standard Audit Log entry
class AuditLog extends Equatable {
  final String id;
  final String actionType; // Equivalent to action.name
  final String performedBy; // User ID of the performer
  final String performedByRole;
  final String? targetUserId; // UID of the user affected (if applicable)
  final String? hotelId; // Target hotelId (if applicable)
  final Map<String, dynamic>? previousData;
  final Map<String, dynamic>? newData;
  final DateTime timestamp;
  final String description;

  const AuditLog({
    required this.id,
    required this.actionType,
    required this.performedBy,
    required this.performedByRole,
    this.targetUserId,
    this.hotelId,
    this.previousData,
    this.newData,
    required this.timestamp,
    required this.description,
  });

  // Compatibility getters for legacy code
  String get userId => performedBy;
  String get userRole => performedByRole;
  AuditAction get action => AuditAction.values.firstWhere(
    (e) => e.name == actionType,
    orElse: () => AuditAction.other,
  );
  String get entity => hotelId ?? 'system';
  String get entityId => targetUserId ?? 'none';
  Map<String, dynamic>? get metadata => newData ?? previousData;
  String get userName => 'User $performedBy'; // Placeholder

  @override
  List<Object?> get props => [
    id,
    actionType,
    performedBy,
    performedByRole,
    targetUserId,
    hotelId,
    previousData,
    newData,
    timestamp,
    description,
  ];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'actionType': actionType,
      'performedBy': performedBy,
      'performedByRole': performedByRole,
      'targetUserId': targetUserId,
      'hotelId': hotelId,
      'previousData': previousData,
      'newData': newData,
      'timestamp': timestamp.toIso8601String(),
      'description': description,
    };
  }

  factory AuditLog.fromJson(Map<String, dynamic> json) {
    return AuditLog(
      id: json['id'] as String,
      actionType: json['actionType'] as String,
      performedBy: json['performedBy'] as String,
      performedByRole: json['performedByRole'] as String? ?? 'unknown',
      targetUserId: json['targetUserId'] as String?,
      hotelId: json['hotelId'] as String?,
      previousData: json['previousData'] as Map<String, dynamic>?,
      newData: json['newData'] as Map<String, dynamic>?,
      timestamp: DateTime.parse(json['timestamp'] as String),
      description: json['description'] as String,
    );
  }
}
