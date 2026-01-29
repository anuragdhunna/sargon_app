import 'package:flutter/material.dart';
import 'package:hotel_manager/theme/app_design.dart';
import 'package:hotel_manager/core/models/models.dart';
import 'package:hotel_manager/features/orders/presentation/widgets/menu_item_card.dart';

class OrderMenuGrid extends StatelessWidget {
  final List<MenuItem> items;
  final Function(MenuItem) onItemTap;

  const OrderMenuGrid({
    super.key,
    required this.items,
    required this.onItemTap,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 48, color: AppDesign.neutral400),
            const SizedBox(height: 16),
            Text(
              'No items found',
              style: AppDesign.bodyLarge.copyWith(color: AppDesign.neutral500),
            ),
          ],
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        // 5 items on wide screens, 3 on tablets, 2 on phones
        final crossAxisCount = constraints.maxWidth > 1200
            ? 5
            : (constraints.maxWidth > 600 ? 3 : 2);

        return GridView.builder(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: 0.88,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return MenuItemCard(item: item, onTap: () => onItemTap(item));
          },
        );
      },
    );
  }
}
