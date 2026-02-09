import 'package:equatable/equatable.dart';

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
class NotificationModel extends Equatable {
  final String id;
  final String title;
  final String body;
  final NotificationType type;
  final DateTime createdAt;
  final bool isRead;
  final String? targetRoute;
  final Map<String, dynamic>? metadata;

  const NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.createdAt,
    this.isRead = false,
    this.targetRoute,
    this.metadata,
  });

  NotificationModel copyWith({bool? isRead}) {
    return NotificationModel(
      id: id,
      title: title,
      body: body,
      type: type,
      createdAt: createdAt,
      isRead: isRead ?? this.isRead,
      targetRoute: targetRoute,
      metadata: metadata,
    );
  }

  @override
  List<Object?> get props => [
    id,
    title,
    body,
    type,
    createdAt,
    isRead,
    targetRoute,
    metadata,
  ];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'type': type.name,
      'createdAt': createdAt.toIso8601String(),
      'isRead': isRead,
      'targetRoute': targetRoute,
      'metadata': metadata,
    };
  }

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      type: NotificationType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => NotificationType.info,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      isRead: json['isRead'] as bool? ?? false,
      targetRoute: json['targetRoute'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }
}
