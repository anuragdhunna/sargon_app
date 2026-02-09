import 'package:equatable/equatable.dart';
import '../../../../core/models/models.dart';

abstract class NotificationState extends Equatable {
  final List<NotificationModel> notifications;
  final bool hasMore;
  final bool isLoadingMore;
  final int unreadCount;

  const NotificationState({
    this.notifications = const [],
    this.hasMore = true,
    this.isLoadingMore = false,
    this.unreadCount = 0,
  });

  @override
  List<Object?> get props => [
    notifications,
    hasMore,
    isLoadingMore,
    unreadCount,
  ];
}

class NotificationInitial extends NotificationState {}

class NotificationLoading extends NotificationState {}

class NotificationLoaded extends NotificationState {
  const NotificationLoaded({
    super.notifications,
    super.hasMore,
    super.isLoadingMore,
    super.unreadCount,
  });

  NotificationLoaded copyWith({
    List<NotificationModel>? notifications,
    bool? hasMore,
    bool? isLoadingMore,
    int? unreadCount,
  }) {
    return NotificationLoaded(
      notifications: notifications ?? this.notifications,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }
}

class NotificationError extends NotificationState {
  final String message;

  const NotificationError(this.message, {super.notifications});

  @override
  List<Object?> get props => [message, ...super.props];
}
