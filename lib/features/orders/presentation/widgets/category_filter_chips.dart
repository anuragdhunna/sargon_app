import 'package:flutter/material.dart';
import 'package:hotel_manager/features/orders/data/menu_item_model.dart';
import 'package:hotel_manager/theme/app_design.dart';

/// Category filter chips widget for menu filtering
class CategoryFilterChips extends StatelessWidget {
  final MenuCategory? selectedCategory;
  final ValueChanged<MenuCategory?> onCategorySelected;

  const CategoryFilterChips({
    super.key,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          // All chip
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: const Text('All'),
              selected: selectedCategory == null,
              onSelected: (selected) => onCategorySelected(null),
              selectedColor: AppDesign.primaryStart.withOpacity(0.2),
              checkmarkColor: AppDesign.primaryStart,
              labelStyle: TextStyle(
                color: selectedCategory == null
                    ? AppDesign.primaryStart
                    : AppDesign.neutral600,
                fontWeight: selectedCategory == null
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
            ),
          ),
          // Category chips
          ...MenuCategory.values.map((cat) {
            final isSelected = selectedCategory == cat;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(cat.name.toUpperCase()),
                selected: isSelected,
                onSelected: (selected) {
                  onCategorySelected(selected ? cat : null);
                },
                selectedColor: AppDesign.primaryStart.withOpacity(0.2),
                checkmarkColor: AppDesign.primaryStart,
                labelStyle: TextStyle(
                  color: isSelected
                      ? AppDesign.primaryStart
                      : AppDesign.neutral600,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
