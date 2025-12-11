import 'package:flutter/material.dart';
import 'package:hotel_manager/theme/app_theme.dart';

/// A simple placeholder widget used while the live‑room map is under development.
class PlaceholderCard extends StatelessWidget {
  const PlaceholderCard({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        color: AppColors.backgroundAlt,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Center(
        child: Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(color: AppColors.textPrimary),
        ),
      ),
    );
  }
}
