import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hotel_manager/core/models/models.dart';
import 'package:hotel_manager/core/models/notification_model.dart';
import 'package:hotel_manager/core/services/database_service.dart';

class NotificationService {
  final DatabaseService _databaseService;

  NotificationService({DatabaseService? databaseService})
    : _databaseService = databaseService ?? DatabaseService();

  /// Get notifications reference

  CollectionReference _notificationsRef(String hotelId) =>
      _databaseService.hotelDoc(hotelId).collection('notifications');

  /// Add a new notification
  Future<void> addNotification(
    String hotelId,
    NotificationModel notification,
  ) async {
    await _notificationsRef(
      hotelId,
    ).doc(notification.id).set(notification.toJson());
  }

  /// Mark notification as read
  Future<void> markAsRead(String hotelId, String id) async {
    await _notificationsRef(hotelId).doc(id).update({'isRead': true});
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead(String hotelId, List<String> ids) async {
    final batch = _databaseService.firestore.batch();
    for (var id in ids) {
      batch.update(_notificationsRef(hotelId).doc(id), {'isRead': true});
    }
    await batch.commit();
  }

  /// Stream notifications
  Stream<List<NotificationModel>> streamNotifications(
    String hotelId, {
    int limit = 20,
  }) {
    return _notificationsRef(
      hotelId,
    ).orderBy('createdAt', descending: true).limit(limit).snapshots().map((
      snapshot,
    ) {
      return snapshot.docs.map((doc) {
        return NotificationModel.fromJson(doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }

  /// Get more notifications (pagination)
  Future<List<NotificationModel>> getNotifications(
    String hotelId, {
    int limit = 10,
    DateTime? before,
  }) async {
    var query = _notificationsRef(
      hotelId,
    ).orderBy('createdAt', descending: true);

    if (before != null) {
      query = query.startAfter([before.toIso8601String()]).limit(limit);
    } else {
      query = query.limit(limit);
    }

    final snapshot = await query.get();
    return snapshot.docs.map((doc) {
      return NotificationModel.fromJson(doc.data() as Map<String, dynamic>);
    }).toList();
  }
}
