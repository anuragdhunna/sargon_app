import 'base_entity.dart';

/// Notification types
enum NotificationType {
  info,
  warning,
  error,
  success,
  inventory,
  order,
  billing,
  booking,
  system,
}

/// Notification model for the global notification system
/// This model is synced with Firebase Realtime Database.
class NotificationModel extends BaseEntity {
  final String title;
  final String body;
  final NotificationType type;
  final bool isRead;
  final String? targetRoute;
  final Map<String, dynamic>? metadata;

  const NotificationModel({
    required super.id,
    required super.hotelId,
    required this.title,
    required this.body,
    required this.type,
    this.isRead = false,
    this.targetRoute,
    this.metadata,
    super.createdBy,
    super.createdOn,
    super.updatedBy,
    super.updatedOn,
    super.isDeleted,
  });

  /// Getter for backward compatibility
  DateTime get createdAt => createdOn ?? DateTime.now();

  NotificationModel copyWith({
    String? id,
    String? hotelId,
    String? title,
    String? body,
    NotificationType? type,
    bool? isRead,
    String? targetRoute,
    Map<String, dynamic>? metadata,
    String? createdBy,
    DateTime? createdOn,
    String? updatedBy,
    DateTime? updatedOn,
    bool? isDeleted,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      hotelId: hotelId ?? this.hotelId,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
      targetRoute: targetRoute ?? this.targetRoute,
      metadata: metadata ?? this.metadata,
      createdBy: createdBy ?? this.createdBy,
      createdOn: createdOn ?? this.createdOn,
      updatedBy: updatedBy ?? this.updatedBy,
      updatedOn: updatedOn ?? this.updatedOn,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  @override
  List<Object?> get props => [
    ...super.props,
    title,
    body,
    type,
    isRead,
    targetRoute,
    metadata,
  ];

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toAuditJson(),
      'title': title,
      'body': body,
      'type': type.name,
      'isRead': isRead,
      'targetRoute': targetRoute,
      'metadata': metadata,
    };
  }

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as String,
      hotelId: json['hotelId'] as String? ?? 'default',
      title: json['title'] as String,
      body: json['body'] as String,
      type: NotificationType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => NotificationType.info,
      ),
      isRead: json['isRead'] as bool? ?? false,
      targetRoute: json['targetRoute'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      createdBy: json['createdBy'] as String?,
      createdOn: BaseEntity.parseDateTime(
        json['createdOn'] ?? json['createdAt'],
      ),
      updatedBy: json['updatedBy'] as String?,
      updatedOn: BaseEntity.parseDateTime(json['updatedOn']),
      isDeleted: json['isDeleted'] ?? false,
    );
  }
}
