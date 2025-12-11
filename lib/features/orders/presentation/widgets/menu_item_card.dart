import 'package:flutter/material.dart';
import 'package:hotel_manager/component/cards/app_card.dart';
import 'package:hotel_manager/features/orders/data/menu_item_model.dart';
import 'package:hotel_manager/theme/app_design.dart';

/// Reusable menu item card widget for displaying menu items in a grid
class MenuItemCard extends StatelessWidget {
  final MenuItem item;
  final VoidCallback onTap;

  const MenuItemCard({super.key, required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.zero,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Fixed-height Image for consistent grid size
          Container(
            height: 120,
            decoration: BoxDecoration(
              color: AppDesign.neutral100,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              image: DecorationImage(
                image: NetworkImage(item.imageUrl),
                fit: BoxFit.cover,
                onError: (_, __) {},
              ),
            ),
            child: item.imageUrl.contains('placeholder')
                ? Center(
                    child: Icon(
                      Icons.restaurant_menu,
                      size: 36,
                      color: AppDesign.neutral400,
                    ),
                  )
                : null,
          ),

          // Content
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppDesign.titleMedium.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  item.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppDesign.bodySmall.copyWith(
                    height: 1.3,
                    color: AppDesign.neutral500,
                  ),
                ),

                const SizedBox(height: 8),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '₹${item.price}',
                      style: AppDesign.titleMedium.copyWith(
                        color: AppDesign.primaryStart,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    // Modern Add Button
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppDesign.primaryStart.withOpacity(0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.add,
                        size: 20,
                        color: AppDesign.primaryStart,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
