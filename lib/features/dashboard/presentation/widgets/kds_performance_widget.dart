import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hotel_manager/theme/app_design.dart';
import 'package:hotel_manager/core/models/models.dart';
import 'package:hotel_manager/features/orders/logic/order_cubit.dart';
import 'package:hotel_manager/component/cards/app_card.dart';
import 'package:go_router/go_router.dart';
import 'package:hotel_manager/features/orders/ui/kds_analytics_screen.dart';

class KdsPerformanceWidget extends StatelessWidget {
  const KdsPerformanceWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OrderCubit, OrderState>(
      builder: (context, state) {
        if (state is! OrderLoaded) {
          return const SizedBox(
            height: 100,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final analytics = _calculateBasicAnalytics(state.orders);

        return AppCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Kitchen Performance',
                    style: AppDesign.titleLarge.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () => context.push(KdsAnalyticsScreen.routeName),
                    icon: const Icon(Icons.analytics_outlined, size: 18),
                    label: const Text('Full View'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _MiniMetric(
                      label: 'Avg Prep',
                      value: '${analytics.$1.toStringAsFixed(1)}m',
                      color: Colors.blue,
                      icon: Icons.timer,
                    ),
                  ),
                  Expanded(
                    child: _MiniMetric(
                      label: 'On-Time',
                      value: '${analytics.$2.toStringAsFixed(0)}%',
                      color: Colors.green,
                      icon: Icons.check_circle,
                    ),
                  ),
                  Expanded(
                    child: _MiniMetric(
                      label: 'Served',
                      value: '${analytics.$3}',
                      color: Colors.orange,
                      icon: Icons.restaurant,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              LinearProgressIndicator(
                value: analytics.$2 / 100,
                backgroundColor: AppDesign.neutral100,
                color: analytics.$2 > 80 ? Colors.green : Colors.orange,
                minHeight: 8,
                borderRadius: BorderRadius.circular(4),
              ),
              const SizedBox(height: 8),
              Text(
                'Goal: 90% on-time delivery',
                style: AppDesign.labelSmall.copyWith(
                  color: AppDesign.neutral500,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  (double, double, int) _calculateBasicAnalytics(List<Order> orders) {
    int totalItems = 0;
    int onTimeItems = 0;
    double totalPrepTime = 0;

    for (var order in orders) {
      for (var item in order.items) {
        if (item.firedAt != null && item.kdsStatus == KdsStatus.served) {
          totalItems++;
          final servedAt = order.updatedAt ?? DateTime.now();
          final prepTime = servedAt.difference(item.firedAt!).inMinutes;
          totalPrepTime += prepTime;
          if (prepTime <= item.expectedPrepTimeMinutes) {
            onTimeItems++;
          }
        }
      }
    }

    final avgTime = totalItems > 0 ? (totalPrepTime / totalItems) : 0.0;
    final onTimeRate = totalItems > 0
        ? (onTimeItems / totalItems * 100.0)
        : 0.0;

    return (avgTime, onTimeRate, totalItems);
  }
}

class _MiniMetric extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _MiniMetric({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color.withOpacity(0.7), size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppDesign.titleMedium.copyWith(fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: AppDesign.labelSmall.copyWith(color: AppDesign.neutral500),
        ),
      ],
    );
  }
}
