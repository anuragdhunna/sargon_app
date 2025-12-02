import 'package:flutter/material.dart';
import 'package:hotel_manager/theme/app_design.dart';

/// Premium status badge with glow effects
///
/// Displays status with appropriate color and icon:
/// - Success (green)
/// - Warning (amber)
/// - Error (red)
/// - Info (blue)
/// - Custom colors supported
class StatusBadge extends StatelessWidget {
  final String label;
  final StatusType type;
  final IconData? icon;
  final bool showGlow;

  const StatusBadge({
    super.key,
    required this.label,
    required this.type,
    this.icon,
    this.showGlow = true,
  });

  const StatusBadge.success({
    super.key,
    required this.label,
    this.icon,
    this.showGlow = true,
  }) : type = StatusType.success;

  const StatusBadge.warning({
    super.key,
    required this.label,
    this.icon,
    this.showGlow = true,
  }) : type = StatusType.warning;

  const StatusBadge.error({
    super.key,
    required this.label,
    this.icon,
    this.showGlow = true,
  }) : type = StatusType.error;

  const StatusBadge.info({
    super.key,
    required this.label,
    this.icon,
    this.showGlow = true,
  }) : type = StatusType.info;

  Color _getColor() {
    switch (type) {
      case StatusType.success:
        return AppDesign.success;
      case StatusType.warning:
        return AppDesign.warning;
      case StatusType.error:
        return AppDesign.error;
      case StatusType.info:
        return AppDesign.info;
    }
  }

  IconData? _getDefaultIcon() {
    switch (type) {
      case StatusType.success:
        return Icons.check_circle;
      case StatusType.warning:
        return Icons.warning;
      case StatusType.error:
        return Icons.error;
      case StatusType.info:
        return Icons.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getColor();
    final displayIcon = icon ?? _getDefaultIcon();

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDesign.space3,
        vertical: AppDesign.space1,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppDesign.radiusFull),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
        boxShadow: showGlow ? AppDesign.glowEffect(color) : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (displayIcon != null) ...[
            Icon(displayIcon, size: 14, color: color),
            const SizedBox(width: AppDesign.space1),
          ],
          Text(label, style: AppDesign.labelSmall.copyWith(color: color)),
        ],
      ),
    );
  }
}

enum StatusType { success, warning, error, info }
