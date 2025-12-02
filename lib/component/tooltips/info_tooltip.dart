import 'package:flutter/material.dart';

/// A reusable info tooltip component that displays helpful information
///
/// Shows an info icon that displays a tooltip with explanation text when tapped or hovered.
/// Helps users understand features and functionality without cluttering the UI.
class InfoTooltip extends StatelessWidget {
  final String message;
  final IconData icon;
  final double iconSize;
  final Color? iconColor;

  const InfoTooltip({
    super.key,
    required this.message,
    this.icon = Icons.info_outline,
    this.iconSize = 18,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: message,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey.shade800,
        borderRadius: BorderRadius.circular(8),
      ),
      textStyle: const TextStyle(color: Colors.white, fontSize: 13),
      preferBelow: false,
      child: Icon(
        icon,
        size: iconSize,
        color: iconColor ?? Colors.grey.shade600,
      ),
    );
  }
}

/// An info tooltip with a clickable dialog for longer explanations
class InfoTooltipDialog extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final double iconSize;
  final Color? iconColor;

  const InfoTooltipDialog({
    super.key,
    required this.title,
    required this.message,
    this.icon = Icons.info_outline,
    this.iconSize = 18,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        icon,
        size: iconSize,
        color: iconColor ?? Colors.grey.shade600,
      ),
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Row(
              children: [
                Icon(icon, color: Theme.of(context).primaryColor),
                const SizedBox(width: 12),
                Text(title),
              ],
            ),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Got it'),
              ),
            ],
          ),
        );
      },
      tooltip: 'Learn more',
    );
  }
}
