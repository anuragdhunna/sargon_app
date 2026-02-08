import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hotel_manager/component/cards/app_card.dart';
import 'package:hotel_manager/component/inputs/app_text_field.dart';
import 'package:hotel_manager/features/inventory/goods_receipt/presentation/widgets/receiving_inputs.dart';
import 'package:hotel_manager/theme/app_design.dart';

class ReceivingItemCardWidget extends StatelessWidget {
  final ReceivingItemInput input;
  final VoidCallback onRemove;
  final ValueChanged<bool> onQualityChanged;

  const ReceivingItemCardWidget({
    required this.input,
    required this.onRemove,
    required this.onQualityChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDesign.space3),
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        input.lineItem.itemName,
                        style: AppDesign.titleMedium,
                      ),
                      const SizedBox(height: AppDesign.space1),
                      Text(
                        'Pending: ${input.lineItem.pendingQuantity} ${input.lineItem.unit.name}',
                        style: AppDesign.bodySmall.copyWith(
                          color: AppDesign.warning,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '₹${input.lineItem.pricePerUnit}/${input.lineItem.unit.name}',
                  style: AppDesign.bodySmall.copyWith(
                    color: AppDesign.neutral600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDesign.space3),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: AppTextField(
                    controller: input.quantityController,
                    labelText: 'Received Quantity *',
                    hintText: 'Enter quantity',
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'^\d*\.?\d{0,2}'),
                      ),
                    ],
                    suffixIcon: Padding(
                      padding: const EdgeInsets.all(AppDesign.space3),
                      child: Text(
                        input.lineItem.unit.name,
                        style: AppDesign.bodySmall.copyWith(
                          color: AppDesign.neutral600,
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) return null;
                      final qty = double.tryParse(value);
                      if (qty == null || qty <= 0) return 'Invalid quantity';
                      if (qty > input.maxQuantity) {
                        return 'Exceeds pending (${input.maxQuantity})';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: AppDesign.space3),
                Expanded(
                  child: Column(
                    children: [
                      const SizedBox(height: 24), // Align with text field
                      CheckboxListTile(
                        title: const Text(
                          'Quality OK',
                          style: TextStyle(fontSize: 12),
                        ),
                        value: input.qualityCheckPassed,
                        onChanged: (value) => onQualityChanged(value ?? false),
                        controlAffinity: ListTileControlAffinity.leading,
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDesign.space3),
            AppTextField(
              controller: input.notesController,
              labelText: 'Notes (optional)',
              hintText: 'Add notes...',
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }
}
