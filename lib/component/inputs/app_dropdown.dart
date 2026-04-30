import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

/// Premium reusable dropdown component
///
/// Supports TWO modes:
/// 1. FormBuilder mode (with `name` parameter) - for form-based screens
/// 2. Regular mode (without `name`) - for simple usage
class AppDropdown<T> extends StatelessWidget {
  final String? name;
  final String label;
  final List<DropdownMenuItem<T>> items;
  final T? initialValue;
  final ValueChanged<T?>? onChanged;
  final String? Function(T?)? validator;
  final Decoration? decoration;

  const AppDropdown({
    super.key,
    this.name,
    required this.label,
    required this.items,
    this.initialValue,
    this.onChanged,
    this.validator,
    this.decoration,
  });

  bool get isFormBuilderMode => name != null;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
        ),
        const SizedBox(height: 8),
        if (isFormBuilderMode)
          FormBuilderDropdown<T>(
            name: name!,
            initialValue: initialValue,
            validator: validator,
            onChanged: onChanged,
            decoration: _buildInputDecoration(context),
            items: items,
          )
        else
          DropdownButtonFormField<T>(
            value: initialValue,
            validator: validator,
            onChanged: onChanged,
            decoration: _buildInputDecoration(context),
            items: items,
          ),
      ],
    );
  }

  InputDecoration _buildInputDecoration(BuildContext context) {
    return InputDecoration(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.grey),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
      ),
      filled: true,
      fillColor: Colors.grey.shade50,
    );
  }
}
