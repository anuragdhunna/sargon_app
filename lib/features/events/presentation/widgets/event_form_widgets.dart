import 'package:flutter/material.dart';
import '../../../../theme/app_design.dart';
import '../../../../core/models/models.dart';

class HallSelector extends StatelessWidget {
  final List<Hall> halls;
  final List<String> selectedHallIds;
  final Function(String, bool) onSelectionChanged;

  const HallSelector({
    super.key,
    required this.halls,
    required this.selectedHallIds,
    required this.onSelectionChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: halls.map((hall) {
        final isSelected = selectedHallIds.contains(hall.id);
        return FilterChip(
          label: Text('${hall.name} (${hall.capacity} pax)'),
          selected: isSelected,
          onSelected: (selected) => onSelectionChanged(hall.id, selected),
          selectedColor: AppDesign.primaryStart.withOpacity(0.2),
          checkmarkColor: AppDesign.primaryStart,
        );
      }).toList(),
    );
  }
}

class MenuSelector extends StatelessWidget {
  final List<MenuItem> items;
  final List<String> selectedMenuItemIds;
  final Function(String, bool) onSelectionChanged;

  const MenuSelector({
    super.key,
    required this.items,
    required this.selectedMenuItemIds,
    required this.onSelectionChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const Text('No menu items available.');
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: items.map((item) {
        final isSelected = selectedMenuItemIds.contains(item.id);
        return FilterChip(
          label: Text(item.name),
          selected: isSelected,
          onSelected: (selected) => onSelectionChanged(item.id, selected),
          selectedColor: Colors.orange.withOpacity(0.2),
          checkmarkColor: Colors.orange,
        );
      }).toList(),
    );
  }
}

class QuoteEstimator extends StatelessWidget {
  final int pax;
  final double basePrice;
  final double perPaxRate;
  final PricingCategory category;

  const QuoteEstimator({
    super.key,
    required this.pax,
    required this.basePrice,
    required this.perPaxRate,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    double subtotal = 0;
    if (category == PricingCategory.package) {
      subtotal = basePrice;
    } else if (category == PricingCategory.perPax) {
      subtotal = pax * perPaxRate;
    } else if (category == PricingCategory.hybrid) {
      subtotal = basePrice + (pax * perPaxRate);
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.calculate_outlined, color: Colors.blue),
              const SizedBox(width: 8),
              Text(
                'Live Quote Estimator',
                style: AppDesign.bodyLarge.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade900,
                ),
              ),
            ],
          ),
          const Divider(),
          if (category == PricingCategory.package ||
              category == PricingCategory.hybrid)
            _buildRow('Base Package', basePrice),
          if (category == PricingCategory.perPax ||
              category == PricingCategory.hybrid)
            _buildRow('Guest Charge ($pax x ₹$perPaxRate)', pax * perPaxRate),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Estimated Subtotal',
                style: AppDesign.bodyLarge.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '₹${subtotal.toStringAsFixed(2)}',
                style: AppDesign.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '* Taxes and add-ons will be calculated during billing.',
            style: AppDesign.bodySmall.copyWith(fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(String label, double amount) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppDesign.bodyMedium),
          Text('₹${amount.toStringAsFixed(2)}', style: AppDesign.bodyMedium),
        ],
      ),
    );
  }
}
