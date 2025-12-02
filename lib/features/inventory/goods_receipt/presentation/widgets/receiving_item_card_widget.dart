import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hotel_manager/features/inventory/goods_receipt/presentation/widgets/receiving_inputs.dart';

class ReceivingItemCardWidget extends StatelessWidget {
  final ReceivingItemInput input;
  final VoidCallback onRemove;
  const ReceivingItemCardWidget({
    required this.input,
    required this.onRemove,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
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
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Pending: ${input.lineItem.pendingQuantity} ${input.lineItem.unit.name}',
                        style: TextStyle(
                          color: Colors.orange.shade700,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '₹${input.lineItem.pricePerUnit}/${input.lineItem.unit.name}',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: input.quantityController,
                    decoration: InputDecoration(
                      labelText: 'Received Quantity *',
                      suffix: Text(input.lineItem.unit.name),
                      border: const OutlineInputBorder(),
                      hintText: 'Enter quantity',
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'^\d*\.?\d{0,2}'),
                      ),
                    ],
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
                const SizedBox(width: 12),
                Expanded(
                  child: CheckboxListTile(
                    title: const Text(
                      'Quality OK',
                      style: TextStyle(fontSize: 12),
                    ),
                    value: input.qualityCheckPassed,
                    onChanged: (value) {
                      // Since this is a StatelessWidget, we cannot setState here.
                      // The parent screen should handle state updates via a callback.
                    },
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: input.notesController,
              decoration: const InputDecoration(
                labelText: 'Notes (optional)',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }
}
