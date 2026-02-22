import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../logic/notification_cubit.dart';
import '../logic/notification_state.dart';
import '../../../features/auth/logic/auth_cubit.dart';
import '../../../features/auth/logic/auth_state.dart';
import '../../../core/models/notification_model.dart';
import '../../../theme/app_design.dart';
import '../../../component/states/empty_state.dart';
import '../../../component/cards/app_card.dart';

class NotificationScreen extends StatefulWidget {
  static const String routeName = '/notifications';

  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<NotificationCubit>().loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all),
            tooltip: 'Mark all as read',
            onPressed: () {
              final authState = context.read<AuthCubit>().state;
              if (authState is AuthVerified) {
                context.read<NotificationCubit>().markAllAsRead(
                  authState.hotelId,
                );
              }
            },
          ),
        ],
      ),
      body: BlocBuilder<NotificationCubit, NotificationState>(
        builder: (context, state) {
          if (state is NotificationInitial ||
              (state is NotificationLoading && state.notifications.isEmpty)) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is NotificationError && state.notifications.isEmpty) {
            return Center(child: Text(state.message));
          }

          final notifications = state.notifications;

          if (notifications.isEmpty) {
            return const EmptyState(
              icon: Icons.notifications_none,
              title: 'No Notifications',
              message: 'When you get notifications, they will appear here.',
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              final authState = context.read<AuthCubit>().state;
              if (authState is AuthVerified) {
                await context.read<NotificationCubit>().fetchNotifications(
                  authState.hotelId,
                  refresh: true,
                );
              }
            },
            child: ListView.separated(
              controller: _scrollController,
              padding: const EdgeInsets.all(AppDesign.space4),
              itemCount: notifications.length + (state.hasMore ? 1 : 0),
              separatorBuilder: (context, index) =>
                  const SizedBox(height: AppDesign.space2),
              itemBuilder: (context, index) {
                if (index == notifications.length) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: AppDesign.space4),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                final notification = notifications[index];
                return _NotificationItem(notification: notification);
              },
            ),
          );
        },
      ),
    );
  }
}

class _NotificationItem extends StatelessWidget {
  final NotificationModel notification;

  const _NotificationItem({required this.notification});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isUnread = !notification.isRead;

    return AppCard(
      onTap: () {
        final authState = context.read<AuthCubit>().state;
        if (authState is AuthVerified) {
          context.read<NotificationCubit>().markAsRead(
            authState.hotelId,
            notification.id,
          );
        }
        if (notification.targetRoute != null) {
          // Navigator.pushNamed(context, notification.targetRoute!);
          // Using GoRouter or similar if available, or basic Navigator
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDesign.space4,
          vertical: AppDesign.space3,
        ),
        decoration: BoxDecoration(
          border: isUnread
              ? Border(
                  left: BorderSide(color: AppDesign.primaryStart, width: 4),
                )
              : null,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(AppDesign.space2),
              decoration: BoxDecoration(
                color: _getIconColor(notification.type).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getIcon(notification.type),
                color: _getIconColor(notification.type),
                size: 20,
              ),
            ),
            const SizedBox(width: AppDesign.space4),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: isUnread
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                      Text(
                        DateFormat('HH:mm').format(notification.createdAt),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppDesign.neutral500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDesign.space1),
                  Text(
                    notification.body,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isUnread
                          ? AppDesign.neutral900
                          : AppDesign.neutral600,
                    ),
                  ),
                  const SizedBox(height: AppDesign.space2),
                  Text(
                    DateFormat('dd MMM yyyy').format(notification.createdAt),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppDesign.neutral400,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIcon(NotificationType type) {
    switch (type) {
      case NotificationType.inventory:
        return Icons.inventory_2;
      case NotificationType.billing:
        return Icons.receipt_long;
      case NotificationType.booking:
        return Icons.hotel;
      case NotificationType.system:
        return Icons.settings;
      case NotificationType.info:
        return Icons.info;
      case NotificationType.warning:
        return Icons.warning;
      case NotificationType.error:
        return Icons.error;
      case NotificationType.success:
        return Icons.check_circle;
      case NotificationType.order:
        return Icons.shopping_cart;
    }
  }

  Color _getIconColor(NotificationType type) {
    switch (type) {
      case NotificationType.inventory:
        return AppDesign.warning;
      case NotificationType.billing:
        return AppDesign.success;
      case NotificationType.booking:
        return AppDesign.primaryStart;
      case NotificationType.system:
        return AppDesign.neutral600;
      case NotificationType.info:
        return AppDesign.info;
      case NotificationType.warning:
        return AppDesign.warning;
      case NotificationType.error:
        return AppDesign.error;
      case NotificationType.success:
        return AppDesign.success;
      case NotificationType.order:
        return AppDesign.primaryStart;
    }
  }
}
