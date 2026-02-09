import '../../../../core/models/models.dart';
import '../../../../core/services/notification_service.dart';

abstract class INotificationRepository {
  Stream<List<NotificationModel>> streamNotifications({int limit = 20});
  Future<List<NotificationModel>> getNotifications({
    int limit = 10,
    DateTime? before,
  });
  Future<void> addNotification(NotificationModel notification);
  Future<void> markAsRead(String id);
  Future<void> markAllAsRead(List<String> ids);
}

class NotificationRepository implements INotificationRepository {
  final NotificationService _service;

  NotificationRepository({NotificationService? service})
    : _service = service ?? NotificationService();

  @override
  Stream<List<NotificationModel>> streamNotifications({int limit = 20}) =>
      _service.streamNotifications(limit: limit);

  @override
  Future<List<NotificationModel>> getNotifications({
    int limit = 10,
    DateTime? before,
  }) => _service.getNotifications(limit: limit, before: before);

  @override
  Future<void> addNotification(NotificationModel notification) =>
      _service.addNotification(notification);

  @override
  Future<void> markAsRead(String id) => _service.markAsRead(id);

  @override
  Future<void> markAllAsRead(List<String> ids) => _service.markAllAsRead(ids);
}
