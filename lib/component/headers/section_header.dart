import 'package:flutter/material.dart';
import 'package:hotel_manager/theme/app_design.dart';

/// Premium section header with icon, title, subtitle, and optional action
///
/// Provides consistent section headers across all screens with:
/// - Icon indicator
/// - Title and optional subtitle
/// - Optional action button
/// - Smooth animations
class SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? action;
  final Color? iconColor;
  final Color? titleColor;

  const SectionHeader({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.action,
    this.iconColor,
    this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(AppDesign.space2),
          decoration: BoxDecoration(
            gradient: AppDesign.primaryGradient,
            borderRadius: BorderRadius.circular(AppDesign.radiusMd),
            boxShadow: AppDesign.glowEffect(AppDesign.primaryStart),
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        const SizedBox(width: AppDesign.space3),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppDesign.titleLarge.copyWith(
                  color: titleColor ?? AppDesign.neutral900,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle!,
                  style: AppDesign.bodySmall.copyWith(
                    color: AppDesign.neutral500,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (action != null) action!,
      ],
    );
  }
}
