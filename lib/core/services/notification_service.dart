import 'package:firebase_database/firebase_database.dart';
import 'package:hotel_manager/core/models/models.dart';
import 'package:hotel_manager/core/services/database_service.dart';

class NotificationService {
  final DatabaseService _databaseService;

  NotificationService({DatabaseService? databaseService})
    : _databaseService = databaseService ?? DatabaseService();

  /// Get notifications reference
  String get _path => 'notifications';

  /// Add a new notification
  Future<void> addNotification(NotificationModel notification) async {
    final ref = _databaseService.settingsRef.root.child(_path);
    await ref.child(notification.id).set(notification.toJson());
  }

  /// Mark notification as read
  Future<void> markAsRead(String id) async {
    final ref = _databaseService.settingsRef.root.child(_path);
    await ref.child(id).update({'isRead': true});
  }

  /// Mark all notifications as read for a user (if we had user-specific paths)
  /// For now, global notifications.
  Future<void> markAllAsRead(List<String> ids) async {
    final ref = _databaseService.settingsRef.root.child(_path);
    final updates = <String, dynamic>{};
    for (var id in ids) {
      updates['$id/isRead'] = true;
    }
    await ref.update(updates);
  }

  /// Stream notifications with pagination
  /// In Firebase RTDB, we can use limitToLast
  Stream<List<NotificationModel>> streamNotifications({int limit = 20}) {
    final ref = _databaseService.settingsRef.root.child(_path);
    return ref.orderByChild('createdAt').limitToLast(limit).onValue.map((
      event,
    ) {
      if (event.snapshot.value == null) return <NotificationModel>[];
      final dynamic value = event.snapshot.value;
      final Map<dynamic, dynamic> data = (value is Map)
          ? value
          : (value is List ? value.asMap() : {});

      final notifications = data.entries.map((e) {
        final Map<String, dynamic> itemData = _databaseService.toMap(e.value);
        return NotificationModel.fromJson(itemData);
      }).toList();

      // Sort by newest first (limitToLast gives us the latest but not necessarily ordered descending)
      notifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return notifications;
    });
  }

  /// Get more notifications (pagination)
  Future<List<NotificationModel>> getNotifications({
    int limit = 10,
    DateTime? before,
  }) async {
    final ref = _databaseService.settingsRef.root.child(_path);
    Query query = ref.orderByChild('createdAt');

    if (before != null) {
      query = query.endAt(before.toIso8601String()).limitToLast(limit + 1);
    } else {
      query = query.limitToLast(limit);
    }

    final snapshot = await query.get();
    if (snapshot.value == null) return <NotificationModel>[];

    final dynamic value = snapshot.value;
    final Map<dynamic, dynamic> data = (value is Map)
        ? value
        : (value is List ? value.asMap() : {});

    var notifications = data.entries.map((e) {
      final Map<String, dynamic> itemData = _databaseService.toMap(e.value);
      return NotificationModel.fromJson(itemData);
    }).toList();

    notifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    // If we used endAt, it includes the item at 'before', so we skip it if it's the same
    if (before != null && notifications.isNotEmpty) {
      if (notifications.first.createdAt == before) {
        notifications.removeAt(0);
      }
    }

    return notifications;
  }
}
