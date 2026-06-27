import 'package:flutter/material.dart';
import 'package:hotel_manager/core/models/models.dart';

class MenuItemCard extends StatelessWidget {
  final MenuItem item;
  final void Function(int quantity, String? notes, CourseType course)
  onAddToCart;

  const MenuItemCard({
    super.key,
    required this.item,
    required this.onAddToCart,
  });

  /// Helper function to convert MenuCategory to CourseType
  static CourseType _menuCategoryToCourseType(MenuCategory category) {
    switch (category) {
      case MenuCategory.starter:
        return CourseType.starters;
      case MenuCategory.mainCourse:
        return CourseType.mains;
      case MenuCategory.dessert:
        return CourseType.desserts;
      case MenuCategory.drink:
        return CourseType.drinks;
      case MenuCategory.alcohol:
        return CourseType.drinks; // Alcohol treated as drinks for course type
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Image
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(8),
              ),
              child: item.imageUrl.isNotEmpty
                  ? Image.network(
                      item.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.restaurant_menu,
                        size: 48,
                        color: Colors.grey,
                      ),
                    )
                  : const Icon(
                      Icons.restaurant_menu,
                      size: 48,
                      color: Colors.grey,
                    ),
            ),
          ),
          // Details
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: Theme.of(context).textTheme.titleMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  item.description,
                  style: Theme.of(context).textTheme.bodySmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  '₹${item.price.toStringAsFixed(2)}',
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          // Add to cart button
          Container(
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: Colors.grey, width: 0.5)),
            ),
            child: TextButton(
              onPressed: () {
                // Add one item with no notes and convert category to course type
                final courseType = _menuCategoryToCourseType(item.category);
                onAddToCart(1, null, courseType);
              },
              child: const Text(
                'ADD',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
