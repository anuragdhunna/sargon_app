import 'package:flutter/material.dart';
import 'package:hotel_manager/theme/app_design.dart';

class OrderGuestInfo extends StatelessWidget {
  final String guestName;

  const OrderGuestInfo({super.key, required this.guestName});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppDesign.primaryStart.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(Icons.person, size: 16, color: AppDesign.primaryStart),
            const SizedBox(width: 8),
            Text(
              'Guest: $guestName',
              style: AppDesign.bodyMedium.copyWith(
                color: AppDesign.primaryStart,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
