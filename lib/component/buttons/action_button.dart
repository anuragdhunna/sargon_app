import 'package:flutter/material.dart';
import 'package:hotel_manager/theme/app_theme.dart';

/// Reusable action button component with variants
class ActionButton extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final String? tooltip;
  final ActionButtonVariant variant;
  final bool isEnabled;

  const ActionButton({
    super.key,
    required this.onPressed,
    required this.icon,
    this.tooltip,
    this.variant = ActionButtonVariant.primary,
    this.isEnabled = true,
  });

  /// Primary action button (filled, prominent)
  const ActionButton.primary({
    super.key,
    required this.onPressed,
    required this.icon,
    this.tooltip,
    this.isEnabled = true,
  }) : variant = ActionButtonVariant.primary;

  /// Secondary action button (outlined)
  const ActionButton.secondary({
    super.key,
    required this.onPressed,
    required this.icon,
    this.tooltip,
    this.isEnabled = true,
  }) : variant = ActionButtonVariant.secondary;

  /// Add/Create action button (success color)
  const ActionButton.add({
    super.key,
    required this.onPressed,
    this.tooltip = 'Add',
    this.isEnabled = true,
  })  : icon = Icons.add,
        variant = ActionButtonVariant.success;

  /// Edit action button
  const ActionButton.edit({
    super.key,
    required this.onPressed,
    this.tooltip = 'Edit',
    this.isEnabled = true,
  })  : icon = Icons.edit,
        variant = ActionButtonVariant.secondary;

  /// Delete action button (danger color)
  const ActionButton.delete({
    super.key,
    required this.onPressed,
    this.tooltip = 'Delete',
    this.isEnabled = true,
  })  : icon = Icons.delete,
        variant = ActionButtonVariant.danger;

  @override
  Widget build(BuildContext context) {
    final color = switch (variant) {
      ActionButtonVariant.primary => AppColors.primary,
      ActionButtonVariant.secondary => AppColors.textSecondary,
      ActionButtonVariant.success => AppColors.success,
      ActionButtonVariant.danger => AppColors.error,
      ActionButtonVariant.warning => AppColors.warning,
    };

    final isFilled = switch (variant) {
      ActionButtonVariant.primary => true,
      ActionButtonVariant.success => true,
      ActionButtonVariant.danger => true,
      _ => false,
    };

    return Tooltip(
      message: tooltip ?? '',
      child: isFilled
          ? IconButton.filled(
              onPressed: isEnabled ? onPressed : null,
              icon: Icon(icon),
              style: IconButton.styleFrom(
                backgroundColor: color,
                foregroundColor: Colors.white,
              ),
            )
          : IconButton(
              onPressed: isEnabled ? onPressed : null,
              icon: Icon(icon),
              color: color,
            ),
    );
  }
}

enum ActionButtonVariant {
  primary,
  secondary,
  success,
  danger,
  warning,
}
