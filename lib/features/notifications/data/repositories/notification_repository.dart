import '../../../../core/models/models.dart';
import '../../../../core/services/notification_service.dart';

abstract class INotificationRepository {
  Stream<List<NotificationModel>> streamNotifications(
    String hotelId, {
    int limit = 20,
  });
  Future<List<NotificationModel>> getNotifications(
    String hotelId, {
    int limit = 10,
    DateTime? before,
  });
  Future<void> addNotification(String hotelId, NotificationModel notification);
  Future<void> markAsRead(String hotelId, String id);
  Future<void> markAllAsRead(String hotelId, List<String> ids);
}

class NotificationRepository implements INotificationRepository {
  final NotificationService _service;

  NotificationRepository({NotificationService? service})
    : _service = service ?? NotificationService();

  @override
  Stream<List<NotificationModel>> streamNotifications(
    String hotelId, {
    int limit = 20,
  }) => _service.streamNotifications(hotelId, limit: limit);

  @override
  Future<List<NotificationModel>> getNotifications(
    String hotelId, {
    int limit = 10,
    DateTime? before,
  }) => _service.getNotifications(hotelId, limit: limit, before: before);

  @override
  Future<void> addNotification(
    String hotelId,
    NotificationModel notification,
  ) => _service.addNotification(hotelId, notification);

  @override
  Future<void> markAsRead(String hotelId, String id) =>
      _service.markAsRead(hotelId, id);

  @override
  Future<void> markAllAsRead(String hotelId, List<String> ids) =>
      _service.markAllAsRead(hotelId, ids);
}
