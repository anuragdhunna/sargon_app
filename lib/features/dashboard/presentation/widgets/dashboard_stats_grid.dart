import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:hotel_manager/component/cards/stat_card.dart';
import 'package:hotel_manager/theme/app_theme.dart';
import 'package:hotel_manager/core/widgets/fade_in.dart';
import 'package:go_router/go_router.dart';
import 'package:hotel_manager/features/billing/ui/discount_report_screen.dart';

/// A reusable grid that displays the dashboard statistic cards.
class DashboardStatsGrid extends StatelessWidget {
  const DashboardStatsGrid({
    super.key,
    required this.isDesktop,
    required this.isTablet,
  });

  final bool isDesktop;
  final bool isTablet;

  @override
  Widget build(BuildContext context) {
    return StaggeredGrid.count(
      crossAxisCount: isDesktop ? 4 : (isTablet ? 2 : 1),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      children: [
        // Revenue
        StaggeredGridTile.count(
          crossAxisCellCount: 1,
          mainAxisCellCount: 1,
          child: FadeIn(
            child: StatCard(
              title: 'Revenue',
              value: '₹1.2L',
              icon: Icons.currency_rupee,
              color: AppColors.success,
            ),
          ),
        ),
        // Occupancy
        StaggeredGridTile.count(
          crossAxisCellCount: 1,
          mainAxisCellCount: 1,
          child: FadeIn(
            child: StatCard(
              title: 'Occupancy',
              value: '85%',
              icon: Icons.hotel,
              color: AppColors.primary,
            ),
          ),
        ),
        // Incidents
        StaggeredGridTile.count(
          crossAxisCellCount: 1,
          mainAxisCellCount: 1,
          child: FadeIn(
            child: StatCard(
              title: 'Incidents',
              value: '3',
              icon: Icons.warning,
              color: AppColors.warning,
            ),
          ),
        ),
        // Staff Active
        StaggeredGridTile.count(
          crossAxisCellCount: 1,
          mainAxisCellCount: 1,
          child: FadeIn(
            child: StatCard(
              title: 'Staff Active',
              value: '12/15',
              icon: Icons.people,
              color: AppColors.primaryDark,
            ),
          ),
        ),
        // Loyalty Points
        StaggeredGridTile.count(
          crossAxisCellCount: 1,
          mainAxisCellCount: 1,
          child: FadeIn(
            child: StatCard(
              title: 'Loyalty Redeemed',
              value: '4.5k',
              icon: Icons.star,
              color: AppColors.primary,
            ),
          ),
        ),
        // Offers Applied
        StaggeredGridTile.count(
          crossAxisCellCount: 1,
          mainAxisCellCount: 1,
          child: FadeIn(
            child: InkWell(
              onTap: () => context.push(DiscountReportScreen.routeName),
              child: StatCard(
                title: 'Offers Applied',
                value: '24',
                icon: Icons.local_offer,
                color: Colors.orange,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
