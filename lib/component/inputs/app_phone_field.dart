import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_text_field.dart';

/// Standardized phone number input component
class AppPhoneField extends StatelessWidget {
  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final String? initialValue;
  final String? name;
  final void Function(String?)? onChanged;
  final String? Function(String?)? validator;
  final bool enabled;

  const AppPhoneField({
    super.key,
    this.controller,
    this.label = 'Phone Number',
    this.hint = 'e.g., +1 234 567 890',
    this.initialValue,
    this.name,
    this.onChanged,
    this.validator,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      name: name,
      label: label,
      hint: hint,
      controller: controller,
      initialValue: initialValue,
      onChanged: onChanged,
      enabled: enabled,
      keyboardType: TextInputType.number,
      prefixIcon: Icons.phone_outlined,
      maxLength: 10,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      validator:
          validator ??
          (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter phone number';
            }
            if (value.length != 10) {
              return 'Phone number must be exactly 10 digits';
            }
            return null;
          },
    );
  }
}
