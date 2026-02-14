import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../theme/app_design.dart';
import '../../../../component/cards/app_card.dart';
import '../../logic/event_cubit.dart';
import '../../../../core/models/event_models.dart';

class EventReportingScreen extends StatelessWidget {
  const EventReportingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppDesign.neutral50,
      appBar: AppBar(title: const Text('Event Reports')),
      body: BlocBuilder<EventCubit, EventState>(
        builder: (context, state) {
          final billedEvents = state.events
              .where(
                (e) =>
                    e.status == EventStatus.billed ||
                    e.status == EventStatus.closed,
              )
              .toList();

          double totalRevenue = 0;
          for (var e in billedEvents) {
            totalRevenue += e.pricing.basePrice;
            for (var a in e.pricing.addOns) {
              totalRevenue += a.price;
            }
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildStatsGrid(totalRevenue, billedEvents.length),
              const SizedBox(height: 24),
              _buildRevenueChartCard(),
              const SizedBox(height: 24),
              _buildOperationalStats(state.halls, state.events),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatsGrid(double revenue, int count) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard(
          'Total Revenue',
          '₹ ${revenue.toStringAsFixed(0)}',
          Icons.payments,
          Colors.green,
        ),
        _buildStatCard(
          'Events Hosted',
          count.toString(),
          Icons.event_available,
          Colors.blue,
        ),
        _buildStatCard('Upcoming', '5', Icons.upcoming, Colors.orange), // Mock
        _buildStatCard(
          'Profit Margin',
          '65%',
          Icons.trending_up,
          Colors.purple,
        ), // Mock
      ],
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return AppCard(
      color: color.withOpacity(0.05),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppDesign.titleLarge.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(label, style: AppDesign.bodySmall),
        ],
      ),
    );
  }

  Widget _buildRevenueChartCard() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Revenue Trend',
            style: AppDesign.titleMedium.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(
            height: 100,
            child: Center(child: Text('Chart Placeholder')),
          ),
        ],
      ),
    );
  }

  Widget _buildOperationalStats(List<Hall> halls, List<PrivateEvent> events) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hall Utilization',
            style: AppDesign.titleMedium.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ...halls.map((h) {
            final hallEvents = events
                .where((e) => e.hallIds.contains(h.id))
                .length;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Text(h.name),
                  const Spacer(),
                  Text('$hallEvents events', style: AppDesign.bodySmall),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
