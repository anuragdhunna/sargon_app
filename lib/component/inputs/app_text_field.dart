import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:hotel_manager/theme/app_design.dart';

/// Premium reusable text field component
///
/// Supports TWO modes:
/// 1. FormBuilder mode (with `name` parameter) - for form-based screens
/// 2. Regular TextField mode (without `name`) - for simple inputs
///
/// Usage:
/// ```dart
/// // FormBuilder mode (for forms)
/// AppTextField(
///   name: 'field_name',
///   label: 'Label',
///   hint: 'Hint text',
/// )
///
/// // Regular mode (simple usage)
/// AppTextField(
///   labelText: 'Search',
///   controller: _controller,
///   onChanged: (value) => print(value),
/// )
/// ```
class AppTextField extends StatelessWidget {
  // FormBuilder mode parameters (backward compatible with CustomTextField)
  final String? name; // If provided, uses FormBuilder mode
  final String? label; // FormBuilder label
  final String? hint; // FormBuilder hint

  // Regular TextField parameters
  final String? labelText; // Regular mode label
  final String? hintText; // Regular mode hint
  final TextEditingController? controller;
  final void Function(String?)? onChanged;
  final String? Function(String?)? validator;

  // Common parameters
  final bool obscureText;
  final TextInputType? keyboardType;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final int maxLines;
  final int? maxLength;
  final String? initialValue;
  final List<TextInputFormatter>? inputFormatters;
  final bool enabled;
  final bool readOnly;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final void Function()? onTap;

  const AppTextField({
    super.key,
    // FormBuilder mode
    this.name,
    this.label,
    this.hint,
    // Regular mode
    this.labelText,
    this.hintText,
    this.controller,
    this.onChanged,
    // Common
    this.validator,
    this.obscureText = false,
    this.keyboardType,
    this.prefixIcon,
    this.suffixIcon,
    this.maxLines = 1,
    this.maxLength,
    this.initialValue,
    this.inputFormatters,
    this.enabled = true,
    this.readOnly = false,
    this.focusNode,
    this.textInputAction,
    this.onTap,
  });

  // Check if using FormBuilder mode
  bool get isFormBuilderMode => name != null;

  @override
  Widget build(BuildContext context) {
    final effectiveLabel = label ?? labelText;
    final effectiveHint = hint ?? hintText;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (effectiveLabel != null) ...[
          Text(
            effectiveLabel,
            style: AppDesign.labelLarge.copyWith(
              fontWeight: FontWeight.w500,
              color: AppDesign.neutral700,
            ),
          ),
          const SizedBox(height: AppDesign.space2),
        ],
        if (isFormBuilderMode)
          _buildFormBuilderField(effectiveHint)
        else
          _buildRegularField(effectiveHint),
      ],
    );
  }

  Widget _buildFormBuilderField(String? hintText) {
    return FormBuilderTextField(
      name: name!,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      maxLines: maxLines,
      maxLength: maxLength,
      initialValue: initialValue,
      inputFormatters: inputFormatters,
      enabled: enabled,
      readOnly: readOnly,
      focusNode: focusNode,
      textInputAction: textInputAction,
      onTap: onTap,
      style: AppDesign.bodyMedium,
      decoration: _buildInputDecoration(hintText),
      onChanged: onChanged, // Pass onChanged to FormBuilderTextField
    );
  }

  Widget _buildRegularField(String? hintText) {
    return TextFormField(
      controller: controller,
      initialValue: initialValue,
      onChanged: onChanged,
      validator: validator,
      obscureText: obscureText,
      keyboardType: keyboardType,
      maxLines: maxLines,
      maxLength: maxLength,
      inputFormatters: inputFormatters,
      enabled: enabled,
      readOnly: readOnly,
      focusNode: focusNode,
      textInputAction: textInputAction,
      onTap: onTap,
      style: AppDesign.bodyMedium,
      decoration: _buildInputDecoration(hintText),
    );
  }

  InputDecoration _buildInputDecoration(String? hintText) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: AppDesign.bodyMedium.copyWith(color: AppDesign.neutral400),
      prefixIcon: prefixIcon != null
          ? Icon(prefixIcon, color: AppDesign.neutral500, size: 20)
          : null,
      suffixIcon: suffixIcon,
      counterText: maxLength != null ? '' : null,
      filled: true,
      fillColor: enabled ? AppDesign.neutral50 : AppDesign.neutral100,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppDesign.space3,
        vertical: AppDesign.space3,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDesign.radiusMd),
        borderSide: BorderSide(color: AppDesign.neutral300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDesign.radiusMd),
        borderSide: BorderSide(color: AppDesign.neutral300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDesign.radiusMd),
        borderSide: BorderSide(color: AppDesign.primaryStart, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDesign.radiusMd),
        borderSide: BorderSide(color: AppDesign.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDesign.radiusMd),
        borderSide: BorderSide(color: AppDesign.error, width: 2),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDesign.radiusMd),
        borderSide: BorderSide(color: AppDesign.neutral200),
      ),
    );
  }
}
