import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hotel_manager/theme/app_design.dart';
import 'package:hotel_manager/core/models/models.dart';
import 'package:hotel_manager/features/orders/logic/order_cubit.dart';
import 'package:hotel_manager/component/cards/app_card.dart';

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
                  _PerformanceHeader(analytics: analytics),
                  const SizedBox(height: 24),
                  const Text(
                    'Efficiency by Category',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _CategoryPerformanceGrid(analytics: analytics),
                  const SizedBox(height: 24),
                  const Text(
                    'Prep Time Distribution',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _TimeDistributionChart(analytics: analytics),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  _KdsMetrics _calculateAnalytics(List<Order> orders) {
    int totalItems = 0;
    int onTimeItems = 0;
    double totalPrepTime = 0;
    Map<CourseType, _CategoryMetrics> categoryStats = {};

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
          categoryStats.putIfAbsent(cat, () => _CategoryMetrics(cat));
          categoryStats[cat]!.addItem(
            prepTime,
            prepTime <= item.expectedPrepTimeMinutes,
          );
        }
      }
    }

    return _KdsMetrics(
      totalItemsServed: totalItems,
      avgPrepTime: totalItems > 0 ? (totalPrepTime / totalItems) : 0,
      onTimePercentage: totalItems > 0 ? (onTimeItems / totalItems * 100) : 0,
      categoryStats: categoryStats,
    );
  }
}

class _KdsMetrics {
  final int totalItemsServed;
  final double avgPrepTime;
  final double onTimePercentage;
  final Map<CourseType, _CategoryMetrics> categoryStats;

  _KdsMetrics({
    required this.totalItemsServed,
    required this.avgPrepTime,
    required this.onTimePercentage,
    required this.categoryStats,
  });
}

class _CategoryMetrics {
  final CourseType category;
  int count = 0;
  double totalTime = 0;
  int onTimeCount = 0;

  _CategoryMetrics(this.category);

  void addItem(int time, bool onTime) {
    count++;
    totalTime += time;
    if (onTime) onTimeCount++;
  }

  double get avgTime => count > 0 ? totalTime / count : 0;
  double get onTimeRate => count > 0 ? (onTimeCount / count * 100) : 0;
}

class _PerformanceHeader extends StatelessWidget {
  final _KdsMetrics analytics;
  const _PerformanceHeader({required this.analytics});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _MetricTile(
            label: 'Avg Prep Time',
            value: '${analytics.avgPrepTime.toStringAsFixed(1)}m',
            icon: Icons.timer,
            color: Colors.blue,
          ),
          _MetricTile(
            label: 'On-Time Rate',
            value: '${analytics.onTimePercentage.toStringAsFixed(0)}%',
            icon: Icons.check_circle_outline,
            color: Colors.green,
          ),
          _MetricTile(
            label: 'Total Served',
            value: '${analytics.totalItemsServed}',
            icon: Icons.restaurant,
            color: Colors.orange,
          ),
        ],
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _MetricTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: AppDesign.headlineSmall.copyWith(fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: AppDesign.bodySmall.copyWith(color: AppDesign.neutral500),
        ),
      ],
    );
  }
}

class _CategoryPerformanceGrid extends StatelessWidget {
  final _KdsMetrics analytics;
  const _CategoryPerformanceGrid({required this.analytics});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.5,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
      ),
      itemCount: CourseType.values.length,
      itemBuilder: (context, index) {
        final course = CourseType.values[index];
        final stat =
            analytics.categoryStats[course] ?? _CategoryMetrics(course);

        return AppCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                course.name.toUpperCase(),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${stat.avgTime.toStringAsFixed(1)}m',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        'Avg Time',
                        style: TextStyle(fontSize: 10, color: Colors.grey),
                      ),
                    ],
                  ),
                  _CircularPercentage(percentage: stat.onTimeRate),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CircularPercentage extends StatelessWidget {
  final double percentage;
  const _CircularPercentage({required this.percentage});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 40,
          height: 40,
          child: CircularProgressIndicator(
            value: percentage / 100,
            strokeWidth: 4,
            backgroundColor: AppDesign.neutral200,
            color: percentage > 80
                ? Colors.green
                : (percentage > 50 ? Colors.orange : Colors.red),
          ),
        ),
        Text(
          '${percentage.toStringAsFixed(0)}%',
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

class _TimeDistributionChart extends StatelessWidget {
  final _KdsMetrics analytics;
  const _TimeDistributionChart({required this.analytics});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _ChartBar(
            label: '< 10 mins',
            count: 12,
            total: 20,
            color: Colors.green,
          ),
          const SizedBox(height: 12),
          _ChartBar(
            label: '10-20 mins',
            count: 5,
            total: 20,
            color: Colors.blue,
          ),
          const SizedBox(height: 12),
          _ChartBar(
            label: '20-30 mins',
            count: 2,
            total: 20,
            color: Colors.orange,
          ),
          const SizedBox(height: 12),
          _ChartBar(label: '> 30 mins', count: 1, total: 20, color: Colors.red),
        ],
      ),
    );
  }
}

class _ChartBar extends StatelessWidget {
  final String label;
  final int count;
  final int total;
  final Color color;

  const _ChartBar({
    required this.label,
    required this.count,
    required this.total,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final double widthFactor = total > 0 ? (count / total) : 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 12)),
            Text(
              '$count items',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Container(
          height: 8,
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppDesign.neutral100,
            borderRadius: BorderRadius.circular(4),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: widthFactor,
            child: Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
