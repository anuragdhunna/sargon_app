import 'package:flutter/material.dart';
import 'package:hotel_manager/theme/app_design.dart';

class OrderTakingFAB extends StatelessWidget {
  final int totalItems;
  final double totalAmount;
  final VoidCallback onPressed;

  const OrderTakingFAB({
    super.key,
    required this.totalItems,
    required this.totalAmount,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: onPressed,
      backgroundColor: AppDesign.primaryStart,
      icon: const Icon(Icons.shopping_cart),
      label: Text('$totalItems Items • ₹${totalAmount.toStringAsFixed(0)}'),
    );
  }
}
