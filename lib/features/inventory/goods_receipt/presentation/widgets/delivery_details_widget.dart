import 'package:flutter/material.dart';
import 'package:hotel_manager/component/cards/app_card.dart';
import 'package:hotel_manager/component/inputs/app_phone_field.dart';
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
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Delivery Details',
            style: AppDesign.titleMedium.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppDesign.space3),
          AppTextField(
            controller: nameController,
            label: 'Delivery Person Name',
            hint: 'Enter name',
            prefixIcon: Icons.person,
          ),
          const SizedBox(height: AppDesign.space3),
          AppPhoneField(
            controller: phoneController,
            label: 'Delivery Person Phone',
            hint: '10-digit phone number',
          ),
        ],
      ),
    );
  }
}
