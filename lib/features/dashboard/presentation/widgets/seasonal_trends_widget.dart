import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hotel_manager/features/orders/logic/order_cubit.dart';
import 'package:hotel_manager/core/models/order_model.dart' as model;
import 'package:hotel_manager/theme/app_design.dart';
import 'package:hotel_manager/component/cards/app_card.dart';

class SeasonalTrendsWidget extends StatelessWidget {
  const SeasonalTrendsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OrderCubit, OrderState>(
      builder: (context, state) {
        if (state is OrderLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is OrderLoaded) {
          final trends = _calculateTrends(state.orders);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Seasonal Food Trends',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              if (trends.isEmpty)
                const AppCard(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Text('No order data available for trends'),
                    ),
                  ),
                )
              else
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 300,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 1.5,
                  ),
                  itemCount: trends.length,
                  itemBuilder: (context, index) {
                    final season = trends.keys.elementAt(index);
                    final topItems = trends[season]!;
                    return _SeasonCard(season: season, topItems: topItems);
                  },
                ),
            ],
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Map<String, List<MapEntry<String, int>>> _calculateTrends(
    List<model.Order> orders,
  ) {
    final Map<String, Map<String, int>> seasonMap = {
      'Winter': {},
      'Spring': {},
      'Summer': {},
      'Autumn': {},
    };

    for (var order in orders) {
      final season = _getSeason(order.timestamp);
      for (var item in order.items) {
        final itemName = item.name;
        seasonMap[season]![itemName] =
            (seasonMap[season]![itemName] ?? 0) + item.quantity;
      }
    }

    // Filter out seasons with no data and sort top 3 items
    final Map<String, List<MapEntry<String, int>>> result = {};
    seasonMap.forEach((season, items) {
      if (items.isNotEmpty) {
        final sorted = items.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));
        result[season] = sorted.take(3).toList();
      }
    });

    return result;
  }

  String _getSeason(DateTime date) {
    final month = date.month;
    if (month == 12 || month == 1 || month == 2) return 'Winter';
    if (month >= 3 && month <= 5) return 'Spring';
    if (month >= 6 && month <= 8) return 'Summer';
    return 'Autumn';
  }
}

class _SeasonCard extends StatelessWidget {
  final String season;
  final List<MapEntry<String, int>> topItems;

  const _SeasonCard({required this.season, required this.topItems});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(_getSeasonIcon(), color: _getSeasonColor(), size: 20),
              const SizedBox(width: 8),
              Text(
                season,
                style: AppDesign.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: topItems.length,
              itemBuilder: (context, index) {
                final entry = topItems[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          entry.key,
                          style: AppDesign.bodyMedium,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        'x${entry.value}',
                        style: AppDesign.bodySmall.copyWith(
                          color: AppDesign.neutral600,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  IconData _getSeasonIcon() {
    switch (season) {
      case 'Winter':
        return Icons.ac_unit;
      case 'Spring':
        return Icons.local_florist;
      case 'Summer':
        return Icons.wb_sunny;
      default:
        return Icons.eco;
    }
  }

  Color _getSeasonColor() {
    switch (season) {
      case 'Winter':
        return Colors.blue;
      case 'Spring':
        return Colors.pinkAccent;
      case 'Summer':
        return Colors.orange;
      default:
        return Colors.brown;
    }
  }
}
