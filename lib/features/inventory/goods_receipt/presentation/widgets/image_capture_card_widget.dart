import 'package:flutter/material.dart';
import 'package:hotel_manager/component/cards/app_card.dart';
import 'package:hotel_manager/component/buttons/premium_button.dart';
import 'package:hotel_manager/theme/app_design.dart';

class ImageCaptureCardWidget extends StatelessWidget {
  final String label;
  final String? imagePath;
  final VoidCallback onCapture;
  const ImageCaptureCardWidget({
    required this.label,
    this.imagePath,
    required this.onCapture,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            label,
            style: AppDesign.labelLarge.copyWith(fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: AppDesign.space3),
          PremiumButton.secondary(
            label: 'Capture',
            icon: Icons.camera_alt,
            onPressed: onCapture,
          ),
          if (imagePath != null)
            Padding(
              padding: const EdgeInsets.only(top: AppDesign.space2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle, color: AppDesign.success, size: 16),
                  const SizedBox(width: AppDesign.space1),
                  Text(
                    'Captured',
                    style: AppDesign.labelSmall.copyWith(
                      color: AppDesign.success,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
