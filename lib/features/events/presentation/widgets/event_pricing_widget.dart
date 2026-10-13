import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hotel_manager/component/buttons/premium_button.dart';
import 'package:hotel_manager/component/cards/app_card.dart';
import 'package:hotel_manager/component/inputs/app_text_field.dart';
import 'package:hotel_manager/core/models/models.dart';
import 'package:hotel_manager/features/events/logic/event_cubit.dart';
import 'package:hotel_manager/theme/app_design.dart';

/// Card widget to display and manage pricing details for an event
class EventPricingWidget extends StatelessWidget {
  final PrivateEvent event;

  const EventPricingWidget({super.key, required this.event});

  double _calculateTotal(PrivateEvent event) {
    double total = event.pricing.basePrice;
    for (final addon in event.pricing.addOns) {
      total += addon.price;
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pricing Details',
            style: AppDesign.titleMedium.copyWith(fontWeight: FontWeight.bold),
          ),
          Text(
            'Category: ${event.pricing.category.name.toUpperCase()}',
            style: AppDesign.bodySmall,
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            Icons.money,
            'Base Price',
            '₹ ${event.pricing.basePrice.toStringAsFixed(2)}',
          ),
          ...event.pricing.addOns.map(
            (addon) => _buildInfoRow(
              Icons.add,
              addon.name,
              '₹ ${addon.price.toStringAsFixed(2)}',
            ),
          ),
          const Divider(thickness: 2),
          _buildInfoRow(
            Icons.calculate,
            'Estimated Total',
            '₹ ${_calculateTotal(event).toStringAsFixed(2)}',
          ),
          const SizedBox(height: 12),
          PremiumButton.outline(
            label: 'Manage Items & Pricing',
            isFullWidth: true,
            onPressed: () => showEventPricingDialog(context, event),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppDesign.neutral600),
          const SizedBox(width: 12),
          Text(
            label,
            style: AppDesign.bodyMedium.copyWith(color: AppDesign.neutral600),
          ),
          const Spacer(),
          Text(
            value,
            style: AppDesign.bodyLarge.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

/// Dialog to adjust base pricing for an event
void showEventPricingDialog(BuildContext context, PrivateEvent event) {
  final basePriceController = TextEditingController(
    text: event.pricing.basePrice.toString(),
  );

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Manage Pricing'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppTextField(
              controller: basePriceController,
              label: 'Base Price',
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            final newPricing = event.pricing.copyWith(
              basePrice:
                  double.tryParse(basePriceController.text) ??
                  event.pricing.basePrice,
            );
            final updatedEvent = event.copyWith(pricing: newPricing);
            context.read<EventCubit>().saveEvent(updatedEvent);
            Navigator.pop(context);
          },
          child: const Text('Save'),
        ),
      ],
    ),
  );
}
