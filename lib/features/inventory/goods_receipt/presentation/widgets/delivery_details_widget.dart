import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hotel_manager/component/inputs/app_text_field.dart';
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
        Text(
          'Delivery Details',
          style: AppDesign.titleMedium.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: AppDesign.space3),
        AppTextField(
          controller: nameController,
          labelText: 'Delivery Person Name',
          hintText: 'Enter name',
          prefixIcon: Icons.person,
        ),
        const SizedBox(height: AppDesign.space3),
        AppTextField(
          controller: phoneController,
          labelText: 'Delivery Person Phone',
          hintText: '10-digit phone number',
          prefixIcon: Icons.phone,
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
