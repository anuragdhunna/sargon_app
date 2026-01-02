import 'package:equatable/equatable.dart';

/// Audit log entry for tracking all system actions
class AuditLog extends Equatable {
  final String id;
  final DateTime timestamp;
  final String userId;
  final String userName;
  final String userRole;
  final AuditAction action;
  final String entity; // 'checklist', 'attendance', 'room_booking', 'user'
  final String entityId;
  final String description;
  final Map<String, dynamic>? metadata;

  const AuditLog({
    required this.id,
    required this.timestamp,
    required this.userId,
    required this.userName,
    required this.userRole,
    required this.action,
    required this.entity,
    required this.entityId,
    required this.description,
    this.metadata,
  });

  @override
  List<Object?> get props => [
    id,
    timestamp,
    userId,
    userName,
    userRole,
    action,
    entity,
    entityId,
    description,
    metadata,
  ];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'userId': userId,
      'userName': userName,
      'userRole': userRole,
      'action': action.name,
      'entity': entity,
      'entityId': entityId,
      'description': description,
      if (metadata != null) 'metadata': metadata,
    };
  }

  factory AuditLog.fromJson(Map<String, dynamic> json) {
    return AuditLog(
      id: json['id'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      userId: json['userId'] as String,
      userName: json['userName'] as String,
      userRole: json['userRole'] as String,
      action: AuditAction.values.firstWhere((e) => e.name == json['action']),
      entity: json['entity'] as String,
      entityId: json['entityId'] as String,
      description: json['description'] as String,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }
}

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
}

extension AuditActionExtension on AuditAction {
  String get displayName {
    switch (this) {
      case AuditAction.create:
        return 'Created';
      case AuditAction.update:
        return 'Updated';
      case AuditAction.delete:
        return 'Deleted';
      case AuditAction.complete:
        return 'Completed';
      case AuditAction.regularize:
        return 'Regularized';
      case AuditAction.approve:
        return 'Approved';
      case AuditAction.reject:
        return 'Rejected';
      case AuditAction.login:
        return 'Logged In';
      case AuditAction.logout:
        return 'Logged Out';
      case AuditAction.checkIn:
        return 'Checked In';
      case AuditAction.checkOut:
        return 'Checked Out';
      case AuditAction.receive:
        return 'Received Goods';
      case AuditAction.createPO:
        return 'Created PO';
      case AuditAction.cancelPO:
        return 'Cancelled PO';
    }
  }
}
