import 'package:flutter/material.dart';
import 'package:hotel_manager/theme/app_design.dart';

/// Premium empty state component with illustration and action
///
/// Displays when no data is available with:
/// - Icon/illustration
/// - Title and message
/// - Optional action button
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDesign.space8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(AppDesign.space6),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppDesign.neutral100, AppDesign.neutral50],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: AppDesign.shadowMd,
              ),
              child: Icon(icon, size: 64, color: AppDesign.neutral400),
            ),
            const SizedBox(height: AppDesign.space6),
            Text(
              title,
              style: AppDesign.headlineSmall.copyWith(
                color: AppDesign.neutral700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDesign.space2),
            Text(
              message,
              style: AppDesign.bodyMedium.copyWith(color: AppDesign.neutral500),
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: AppDesign.space6),
              FilledButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.add),
                label: Text(actionLabel!),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDesign.space6,
                    vertical: AppDesign.space4,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
