import 'package:flutter/material.dart';
import 'package:hotel_manager/theme/app_design.dart';

/// Bento grid layout system for dashboard-style interfaces
///
/// Provides a responsive grid layout with different card sizes:
/// - 1x1: Small square card
/// - 2x1: Wide horizontal card
/// - 1x2: Tall vertical card
/// - 2x2: Large square card
class BentoGrid extends StatelessWidget {
  final List<BentoGridItem> items;
  final double spacing;
  final int crossAxisCount;

  const BentoGrid({
    super.key,
    required this.items,
    this.spacing = AppDesign.space4,
    this.crossAxisCount = 2,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: spacing,
        mainAxisSpacing: spacing,
        childAspectRatio: 1,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        return items[index];
      },
    );
  }
}

/// Individual item in the bento grid
class BentoGridItem extends StatelessWidget {
  final Widget child;
  final int width; // 1 or 2
  final int height; // 1 or 2
  final Color? color;
  final Gradient? gradient;
  final VoidCallback? onTap;

  const BentoGridItem({
    super.key,
    required this.child,
    this.width = 1,
    this.height = 1,
    this.color,
    this.gradient,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color,
          gradient: gradient,
          borderRadius: BorderRadius.circular(AppDesign.radiusLg),
          boxShadow: AppDesign.shadowMd,
        ),
        child: child,
      ),
    );
  }
}

/// Premium bento card with glassmorphism effect
class BentoCard extends StatefulWidget {
  final Widget child;
  final Color? backgroundColor;
  final Gradient? gradient;
  final VoidCallback? onTap;
  final bool enableHoverEffect;

  const BentoCard({
    super.key,
    required this.child,
    this.backgroundColor,
    this.gradient,
    this.onTap,
    this.enableHoverEffect = true,
  });

  @override
  State<BentoCard> createState() => _BentoCardState();
}

class _BentoCardState extends State<BentoCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: AppDesign.durationNormal,
        curve: AppDesign.curveDefault,
        transform: _isHovered && widget.enableHoverEffect
            ? Matrix4.translationValues(0, -4, 0)
            : Matrix4.identity(),
        decoration: BoxDecoration(
          color: widget.backgroundColor ?? AppDesign.neutral50,
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
              padding: const EdgeInsets.all(AppDesign.space4),
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}
