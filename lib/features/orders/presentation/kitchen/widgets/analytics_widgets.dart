import 'package:flutter/material.dart';
import 'package:hotel_manager/theme/app_design.dart';
import 'package:hotel_manager/core/models/models.dart';
import 'package:hotel_manager/component/cards/app_card.dart';

class KdsMetrics {
  final int totalItemsServed;
  final double avgPrepTime;
  final double onTimePercentage;
  final Map<CourseType, CategoryMetrics> categoryStats;

  KdsMetrics({
    required this.totalItemsServed,
    required this.avgPrepTime,
    required this.onTimePercentage,
    required this.categoryStats,
  });
}

class CategoryMetrics {
  final CourseType category;
  int count = 0;
  double totalTime = 0;
  int onTimeCount = 0;

  CategoryMetrics(this.category);

  void addItem(int time, bool onTime) {
    count++;
    totalTime += time;
    if (onTime) onTimeCount++;
  }

  double get avgTime => count > 0 ? totalTime / count : 0;
  double get onTimeRate => count > 0 ? (onTimeCount / count * 100) : 0;
}

class PerformanceHeader extends StatelessWidget {
  final KdsMetrics analytics;
  const PerformanceHeader({super.key, required this.analytics});

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

class CategoryPerformanceGrid extends StatelessWidget {
  final KdsMetrics analytics;
  const CategoryPerformanceGrid({super.key, required this.analytics});

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
        final stat = analytics.categoryStats[course] ?? CategoryMetrics(course);

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

class TimeDistributionChart extends StatelessWidget {
  final KdsMetrics analytics;
  const TimeDistributionChart({super.key, required this.analytics});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: const [
          _ChartBar(
            label: '< 10 mins',
            count: 12,
            total: 20,
            color: Colors.green,
          ),
          SizedBox(height: 12),
          _ChartBar(
            label: '10-20 mins',
            count: 5,
            total: 20,
            color: Colors.blue,
          ),
          SizedBox(height: 12),
          _ChartBar(
            label: '20-30 mins',
            count: 2,
            total: 20,
            color: Colors.orange,
          ),
          SizedBox(height: 12),
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
