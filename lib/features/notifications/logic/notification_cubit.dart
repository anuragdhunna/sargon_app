import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/models/models.dart';
import '../data/repositories/notification_repository.dart';
import 'notification_state.dart';

class NotificationCubit extends Cubit<NotificationState> {
  final INotificationRepository _notificationRepository;
  StreamSubscription? _subscription;
  static const int _pageSize = 10;

  NotificationCubit({INotificationRepository? notificationRepository})
    : _notificationRepository =
          notificationRepository ?? NotificationRepository(),
      super(NotificationInitial());

  Future<void> fetchNotifications(
    String hotelId, {
    bool refresh = false,
  }) async {
    _startListening(hotelId);
  }

  void _startListening(String hotelId) {
    emit(NotificationLoading());
    _subscription?.cancel();
    _subscription = _notificationRepository
        .streamNotifications(hotelId, limit: _pageSize)
        .listen(
          (notifications) {
            final unreadCount = notifications.where((n) => !n.isRead).length;
            emit(
              NotificationLoaded(
                notifications: notifications,
                unreadCount: unreadCount,
                hasMore: notifications.length >= _pageSize,
              ),
            );
          },
          onError: (e) {
            emit(
              NotificationError(
                'Failed to load notifications: ${e.toString()}',
              ),
            );
          },
        );
  }

  Future<void> loadMore() async {
    if (state is! NotificationLoaded || state.isLoadingMore || !state.hasMore) {
      return;
    }

    final currentState = state as NotificationLoaded;
    emit(currentState.copyWith(isLoadingMore: true));

    try {
      final lastNotification = currentState.notifications.last;
      final moreNotifications = await _notificationRepository.getNotifications(
        lastNotification.hotelId,
        limit: _pageSize,
        before: lastNotification.createdAt,
      );

      emit(
        currentState.copyWith(
          notifications: [...currentState.notifications, ...moreNotifications],
          isLoadingMore: false,
          hasMore: moreNotifications.length >= _pageSize,
        ),
      );
    } catch (e) {
      emit(
        NotificationError(
          'Failed to load more: ${e.toString()}',
          notifications: currentState.notifications,
        ),
      );
    }
  }

  Future<void> markAsRead(String hotelId, String id) async {
    try {
      await _notificationRepository.markAsRead(hotelId, id);
    } catch (e) {
      // Log error but don't disrupt UI
    }
  }

  Future<void> markAllAsRead(String hotelId) async {
    if (state is! NotificationLoaded) return;
    final unreadIds = state.notifications
        .where((n) => !n.isRead)
        .map((n) => n.id)
        .toList();

    if (unreadIds.isEmpty) return;

    try {
      await _notificationRepository.markAllAsRead(hotelId, unreadIds);
    } catch (e) {
      // Log error
    }
  }

  Future<void> sendNotification({
    required String title,
    required String body,
    required NotificationType type,
    String? targetRoute,
    Map<String, dynamic>? metadata,
    required String hotelId,
  }) async {
    final notification = NotificationModel(
      hotelId: hotelId,
      id: const Uuid().v4(),
      title: title,
      body: body,
      type: type,
      createdOn: DateTime.now(),
      targetRoute: targetRoute,
      metadata: metadata,
    );
    await _notificationRepository.addNotification(hotelId, notification);
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
