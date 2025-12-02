import 'package:flutter/material.dart';
import 'package:hotel_manager/theme/app_design.dart';

/// Premium button component with loading states and variants
///
/// Features:
/// - Primary, secondary, outline variants
/// - Loading state with spinner
/// - Icon support
/// - Consistent styling
/// - Disabled state
class PremiumButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final ButtonVariant variant;
  final bool isFullWidth;

  const PremiumButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.variant = ButtonVariant.primary,
    this.isFullWidth = false,
  });

  const PremiumButton.primary({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.isFullWidth = false,
  }) : variant = ButtonVariant.primary;

  const PremiumButton.secondary({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.isFullWidth = false,
  }) : variant = ButtonVariant.secondary;

  const PremiumButton.outline({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.isFullWidth = false,
  }) : variant = ButtonVariant.outline;

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = onPressed == null || isLoading;

    Widget buttonChild = Row(
      mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading)
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                _getTextColor(isDisabled),
              ),
            ),
          )
        else if (icon != null)
          Icon(icon, size: 20),
        if (isLoading || icon != null) const SizedBox(width: AppDesign.space2),
        Text(
          isLoading ? 'Loading...' : label,
          style: AppDesign.labelLarge.copyWith(
            color: _getTextColor(isDisabled),
          ),
        ),
      ],
    );

    switch (variant) {
      case ButtonVariant.primary:
        return SizedBox(
          width: isFullWidth ? double.infinity : null,
          child: FilledButton(
            onPressed: isDisabled ? null : onPressed,
            style: FilledButton.styleFrom(
              backgroundColor: AppDesign.primaryStart,
              disabledBackgroundColor: AppDesign.neutral300,
              padding: const EdgeInsets.symmetric(
                horizontal: AppDesign.space6,
                vertical: AppDesign.space4,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDesign.radiusMd),
              ),
            ),
            child: buttonChild,
          ),
        );

      case ButtonVariant.secondary:
        return SizedBox(
          width: isFullWidth ? double.infinity : null,
          child: FilledButton(
            onPressed: isDisabled ? null : onPressed,
            style: FilledButton.styleFrom(
              backgroundColor: AppDesign.neutral100,
              disabledBackgroundColor: AppDesign.neutral200,
              padding: const EdgeInsets.symmetric(
                horizontal: AppDesign.space6,
                vertical: AppDesign.space4,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDesign.radiusMd),
              ),
            ),
            child: buttonChild,
          ),
        );

      case ButtonVariant.outline:
        return SizedBox(
          width: isFullWidth ? double.infinity : null,
          child: OutlinedButton(
            onPressed: isDisabled ? null : onPressed,
            style: OutlinedButton.styleFrom(
              side: BorderSide(
                color: isDisabled
                    ? AppDesign.neutral300
                    : AppDesign.primaryStart,
                width: 1.5,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: AppDesign.space6,
                vertical: AppDesign.space4,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDesign.radiusMd),
              ),
            ),
            child: buttonChild,
          ),
        );
    }
  }

  Color _getTextColor(bool isDisabled) {
    if (isDisabled) {
      return variant == ButtonVariant.primary
          ? Colors.white.withOpacity(0.5)
          : AppDesign.neutral400;
    }

    switch (variant) {
      case ButtonVariant.primary:
        return Colors.white;
      case ButtonVariant.secondary:
        return AppDesign.neutral900;
      case ButtonVariant.outline:
        return AppDesign.primaryStart;
    }
  }
}

enum ButtonVariant { primary, secondary, outline }
