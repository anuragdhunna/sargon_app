import 'package:flutter/material.dart';
import 'package:hotel_manager/theme/app_design.dart';

/// Premium info card with glassmorphism effect
///
/// Features:
/// - Glassmorphism background
/// - Hover effects
/// - Customizable content
/// - Smooth animations
class PremiumInfoCard extends StatefulWidget {
  final Widget child;
  final Color? backgroundColor;
  final Gradient? gradient;
  final VoidCallback? onTap;
  final EdgeInsets? padding;
  final bool enableHover;

  const PremiumInfoCard({
    super.key,
    required this.child,
    this.backgroundColor,
    this.gradient,
    this.onTap,
    this.padding,
    this.enableHover = true,
  });

  @override
  State<PremiumInfoCard> createState() => _PremiumInfoCardState();
}

class _PremiumInfoCardState extends State<PremiumInfoCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: AppDesign.durationNormal,
        curve: AppDesign.curveDefault,
        transform: _isHovered && widget.enableHover
            ? Matrix4.translationValues(0, -2, 0)
            : Matrix4.identity(),
        decoration: BoxDecoration(
          color: widget.backgroundColor ?? Colors.white,
          gradient: widget.gradient,
          borderRadius: BorderRadius.circular(AppDesign.radiusLg),
          border: Border.all(
            color: _isHovered
                ? AppDesign.primaryStart.withOpacity(0.3)
                : AppDesign.neutral200,
            width: 1.5,
          ),
          boxShadow: _isHovered ? AppDesign.shadowLg : AppDesign.shadowMd,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(AppDesign.radiusLg),
            child: Padding(
              padding: widget.padding ?? const EdgeInsets.all(AppDesign.space4),
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}

/// Stat card for displaying key metrics
class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? color;
  final String? trend;
  final bool isPositiveTrend;

  const StatCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.color,
    this.trend,
    this.isPositiveTrend = true,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? AppDesign.primaryStart;

    return PremiumInfoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppDesign.space2),
                decoration: BoxDecoration(
                  color: effectiveColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppDesign.radiusMd),
                ),
                child: Icon(icon, color: effectiveColor, size: 20),
              ),
              const Spacer(),
              if (trend != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDesign.space2,
                    vertical: AppDesign.space1,
                  ),
                  decoration: BoxDecoration(
                    color:
                        (isPositiveTrend ? AppDesign.success : AppDesign.error)
                            .withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppDesign.radiusSm),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isPositiveTrend
                            ? Icons.trending_up
                            : Icons.trending_down,
                        size: 12,
                        color: isPositiveTrend
                            ? AppDesign.success
                            : AppDesign.error,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        trend!,
                        style: AppDesign.labelSmall.copyWith(
                          color: isPositiveTrend
                              ? AppDesign.success
                              : AppDesign.error,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppDesign.space3),
          Text(
            value,
            style: AppDesign.headlineMedium.copyWith(
              color: AppDesign.neutral900,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppDesign.space1),
          Text(
            label,
            style: AppDesign.bodySmall.copyWith(color: AppDesign.neutral500),
          ),
        ],
      ),
    );
  }
}
