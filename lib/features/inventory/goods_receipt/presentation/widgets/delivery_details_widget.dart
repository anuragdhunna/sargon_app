import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hotel_manager/theme/app_design.dart';

class DeliveryDetailsWidget extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController phoneController;
  const DeliveryDetailsWidget({
    required this.nameController,
    required this.phoneController,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: AppDesign.space2),
        const Text('Delivery Details', style: AppDesign.bodyMedium),
        const SizedBox(height: AppDesign.space2),
        TextFormField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Delivery Person Name',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.person),
          ),
        ),
        const SizedBox(height: AppDesign.space2),
        TextFormField(
          controller: phoneController,
          decoration: const InputDecoration(
            labelText: 'Delivery Person Phone',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.phone),
            hintText: '10‑digit phone number',
          ),
          keyboardType: TextInputType.phone,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(10),
          ],
          validator: (v) => (v != null && v.isNotEmpty && v.length != 10)
              ? 'Phone number must be exactly 10 digits'
              : null,
        ),
      ],
    );
  }
}
