import 'package:flutter/material.dart';

/// A reusable button component that displays an icon with a label
///
/// This component improves UX by making button purposes clear at a glance.
/// Supports both vertical (icon above text) and horizontal (icon beside text) layouts.
class IconButtonWithLabel extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final Color? color;
  final Color? backgroundColor;
  final bool isVertical;
  final double iconSize;
  final double fontSize;
  final EdgeInsets? padding;

  const IconButtonWithLabel({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
    this.color,
    this.backgroundColor,
    this.isVertical = false,
    this.iconSize = 24,
    this.fontSize = 12,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? Theme.of(context).primaryColor;

    if (isVertical) {
      return InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding:
              padding ??
              const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: backgroundColor != null
              ? BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(8),
                )
              : null,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: iconSize, color: effectiveColor),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: fontSize,
                  color: effectiveColor,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return TextButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: iconSize, color: effectiveColor),
      label: Text(
        label,
        style: TextStyle(
          fontSize: fontSize,
          color: effectiveColor,
          fontWeight: FontWeight.w600,
        ),
      ),
      style: TextButton.styleFrom(
        backgroundColor: backgroundColor,
        padding:
            padding ?? const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }
}

/// A compact version for app bar usage
class AppBarIconButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final Color? color;

  const AppBarIconButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20),
          Text(label, style: const TextStyle(fontSize: 9)),
        ],
      ),
      onPressed: onPressed,
      color: color,
      tooltip: label,
    );
  }
}
