import 'package:flutter/material.dart';
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
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: AppDesign.space2),
            Text(label, style: const TextStyle(fontSize: 12)),
            const SizedBox(height: AppDesign.space2),
            ElevatedButton.icon(
              onPressed: onCapture,
              icon: const Icon(Icons.camera_alt),
              label: const Text('Capture'),
            ),
            if (imagePath != null)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  'Captured ✓',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
