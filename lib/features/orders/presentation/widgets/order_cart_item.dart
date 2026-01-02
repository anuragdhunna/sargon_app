import 'package:flutter/material.dart';

import 'package:hotel_manager/features/orders/data/order_model.dart';
import 'package:hotel_manager/theme/app_design.dart';

/// A reusable cart item widget used in the order taking screen.
///
/// Displays the item name, quantity, optional notes and price, and provides
/// edit / remove callbacks. All UI styling follows the app's design system.
class OrderCartItem extends StatelessWidget {
  final OrderItem item;
  final VoidCallback onEdit;
  final VoidCallback onRemove;
  final bool canEdit;

  const OrderCartItem({
    super.key,
    required this.item,
    required this.onEdit,
    required this.onRemove,
    this.canEdit = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppDesign.neutral50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppDesign.neutral200),
      ),
      child: Row(
        children: [
          // Quantity badge
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: AppDesign.primaryStart.withAlpha(25),
            ),
            child: Center(
              child: Text(
                '${item.quantity}x',
                style: AppDesign.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppDesign.primaryStart,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Details column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: AppDesign.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (item.notes != null && item.notes!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.edit_note,
                          size: 14,
                          color: AppDesign.primaryStart,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            item.notes!,
                            style: AppDesign.bodySmall.copyWith(
                              color: AppDesign.primaryStart,
                              fontStyle: FontStyle.italic,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                Text(
                  '₹${item.totalPrice.toStringAsFixed(0)}',
                  style: AppDesign.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          // Action buttons
          if (canEdit) ...[
            IconButton(
              icon: const Icon(Icons.edit, size: 20),
              tooltip: 'Edit item',
              onPressed: onEdit,
            ),
            IconButton(
              icon: const Icon(Icons.delete, size: 20),
              tooltip: 'Remove item',
              onPressed: onRemove,
            ),
          ],
        ],
      ),
    );
  }
}
