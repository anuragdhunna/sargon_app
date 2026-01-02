import 'package:flutter/material.dart';
import 'package:hotel_manager/component/buttons/premium_button.dart';
import 'package:hotel_manager/core/models/models.dart';
import 'package:hotel_manager/theme/app_design.dart';

/// A reusable dialog for adding a menu item to the order.
///
/// Enhanced to support Course selection (Industry Standard).
class OrderItemDialog extends StatefulWidget {
  final MenuItem item;
  final void Function(int quantity, String notes, CourseType course) onConfirm;

  const OrderItemDialog({
    super.key,
    required this.item,
    required this.onConfirm,
  });

  @override
  State<OrderItemDialog> createState() => _OrderItemDialogState();
}

class _OrderItemDialogState extends State<OrderItemDialog> {
  int _quantity = 1;
  late CourseType _selectedCourse;
  final TextEditingController _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedCourse = _inferCourse(widget.item.category);
  }

  CourseType _inferCourse(MenuCategory category) {
    switch (category) {
      case MenuCategory.starter:
        return CourseType.starters;
      case MenuCategory.mainCourse:
        return CourseType.mains;
      case MenuCategory.dessert:
        return CourseType.desserts;
      case MenuCategory.drink:
      case MenuCategory.alcohol:
        return CourseType.drinks;
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      title: Text(widget.item.name),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Quantity selector
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline),
                  onPressed: () {
                    if (_quantity > 1) setState(() => _quantity--);
                  },
                ),
                const SizedBox(width: 16),
                Text(
                  '$_quantity',
                  style: AppDesign.headlineMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 16),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: () => setState(() => _quantity++),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Course selection
            DropdownButtonFormField<CourseType>(
              initialValue: _selectedCourse,
              decoration: AppDesign.inputDecoration(label: 'Course'),
              items: CourseType.values.map((c) {
                return DropdownMenuItem(
                  value: c,
                  child: Text(c.name.split('.').last.toUpperCase()),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedCourse = val);
              },
            ),
            const SizedBox(height: 16),

            // Notes field
            TextField(
              controller: _notesController,
              decoration: InputDecoration(
                labelText: 'Notes (Optional)',
                hintText: 'e.g., Less spicy, no onions',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: AppDesign.neutral50,
              ),
              maxLines: 2,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        PremiumButton.primary(
          label: 'Add to Order - ₹${widget.item.price * _quantity}',
          onPressed: () {
            widget.onConfirm(
              _quantity,
              _notesController.text.trim(),
              _selectedCourse,
            );
            Navigator.pop(context);
          },
        ),
      ],
    );
  }
}
