import 'package:flutter/material.dart';

class VendorInfoWidget extends StatelessWidget {
  final TextEditingController controller;
  final bool enabled;
  const VendorInfoWidget({
    required this.controller,
    required this.enabled,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      decoration: const InputDecoration(
        labelText: 'Vendor Name *',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.business),
      ),
      validator: (v) =>
          (v == null || v.trim().isEmpty) ? 'Vendor name is required' : null,
    );
  }
}
