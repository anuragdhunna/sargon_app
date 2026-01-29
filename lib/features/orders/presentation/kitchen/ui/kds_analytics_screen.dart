import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hotel_manager/theme/app_design.dart';
import 'package:hotel_manager/core/models/models.dart';
import 'package:hotel_manager/features/orders/logic/order_cubit.dart';
import '../widgets/analytics_widgets.dart';

class KdsAnalyticsScreen extends StatelessWidget {
  const KdsAnalyticsScreen({super.key});

  static const String routeName = '/kds-analytics';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppDesign.neutral50,
      appBar: AppBar(
        title: const Text('KDS Performance Analytics'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: BlocBuilder<OrderCubit, OrderState>(
        builder: (context, state) {
          if (state is OrderLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is OrderError) {
            return Center(child: Text('Error: ${state.message}'));
          }
          if (state is OrderLoaded) {
            final allOrders = state.orders;
            final analytics = _calculateAnalytics(allOrders);

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PerformanceHeader(analytics: analytics),
                  const SizedBox(height: 24),
                  const Text(
                    'Efficiency by Category',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  CategoryPerformanceGrid(analytics: analytics),
                  const SizedBox(height: 24),
                  const Text(
                    'Prep Time Distribution',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  TimeDistributionChart(analytics: analytics),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  KdsMetrics _calculateAnalytics(List<Order> orders) {
    int totalItems = 0;
    int onTimeItems = 0;
    double totalPrepTime = 0;
    Map<CourseType, CategoryMetrics> categoryStats = {};

    for (var order in orders) {
      for (var item in order.items) {
        if (item.firedAt != null && item.kdsStatus == KdsStatus.served) {
          totalItems++;
          // Mocking final served at for analytics if not present
          final servedAt = order.updatedAt ?? DateTime.now();
          final prepTime = servedAt.difference(item.firedAt!).inMinutes;

          totalPrepTime += prepTime;
          if (prepTime <= item.expectedPrepTimeMinutes) {
            onTimeItems++;
          }

          final cat = item.course;
          categoryStats.putIfAbsent(cat, () => CategoryMetrics(cat));
          categoryStats[cat]!.addItem(
            prepTime,
            prepTime <= item.expectedPrepTimeMinutes,
          );
        }
      }
    }

    return KdsMetrics(
      totalItemsServed: totalItems,
      avgPrepTime: totalItems > 0 ? (totalPrepTime / totalItems) : 0,
      onTimePercentage: totalItems > 0 ? (onTimeItems / totalItems * 100) : 0,
      categoryStats: categoryStats,
    );
  }
}
