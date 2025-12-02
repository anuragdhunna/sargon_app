import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';

import '../../inventory_index.dart';

class CreatePODialog extends StatefulWidget {
  const CreatePODialog({super.key});

  @override
  State<CreatePODialog> createState() => _CreatePODialogState();
}

class _CreatePODialogState extends State<CreatePODialog> {
  final _formKey = GlobalKey<FormState>();
  final _vendorNameController = TextEditingController();
  final _notesController = TextEditingController();
  final _shippingCostController = TextEditingController();
  final _taxController = TextEditingController();

  DateTime? _expectedDeliveryDate;
  final List<_POLineItemInput> _lineItems = [];

  @override
  void initState() {
    super.initState();
    // Add one empty line item to start
    _addLineItem();
  }

  @override
  void dispose() {
    _vendorNameController.dispose();
    _notesController.dispose();
    _shippingCostController.dispose();
    _taxController.dispose();
    for (var item in _lineItems) {
      item.dispose();
    }
    super.dispose();
  }

  void _addLineItem() {
    setState(() {
      _lineItems.add(_POLineItemInput());
    });
  }

  void _removeLineItem(int index) {
    setState(() {
      _lineItems[index].dispose();
      _lineItems.removeAt(index);
    });
  }

  void _createPO() {
    if (!_formKey.currentState!.validate()) return;
    if (_lineItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one item')),
      );
      return;
    }

    final authState = context.read<AuthCubit>().state;
    if (authState is! AuthVerified) return;

    final inventoryState = context.read<InventoryCubit>().state;
    if (inventoryState is! InventoryLoaded) return;

    final uuid = const Uuid();
    final poLineItems = <POLineItem>[];

    for (var input in _lineItems) {
      if (input.selectedItem == null || input.quantityController.text.isEmpty) {
        continue;
      }

      final quantity = double.tryParse(input.quantityController.text) ?? 0;
      final price = double.tryParse(input.priceController.text) ?? 0;

      if (quantity <= 0 || price <= 0) continue;

      poLineItems.add(
        POLineItem(
          id: uuid.v4(),
          inventoryItemId: input.selectedItem!.id,
          itemName: input.selectedItem!.name,
          unit: input.selectedItem!.unit,
          orderedQuantity: quantity,
          pricePerUnit: price,
        ),
      );
    }

    if (poLineItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add valid items with quantity and price'),
        ),
      );
      return;
    }

    context.read<PurchaseOrderCubit>().createPurchaseOrder(
      vendorId: uuid.v4(),
      vendorName: _vendorNameController.text,
      lineItems: poLineItems,
      createdBy: authState.userName,
      expectedDeliveryDate: _expectedDeliveryDate,
      notes: _notesController.text.isNotEmpty ? _notesController.text : null,
      shippingCost: _shippingCostController.text.isNotEmpty
          ? double.tryParse(_shippingCostController.text)
          : null,
      taxAmount: _taxController.text.isNotEmpty
          ? double.tryParse(_taxController.text)
          : null,
      userId: authState.userId,
      userName: authState.userName,
      userRole: authState.role.name,
    );

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Purchase Order created successfully')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 600,
        constraints: const BoxConstraints(maxHeight: 700),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.receipt_long, color: Colors.white),
                  const SizedBox(width: 12),
                  const Text(
                    'Create Purchase Order',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            // Body
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Vendor Name
                      TextFormField(
                        controller: _vendorNameController,
                        decoration: const InputDecoration(
                          labelText: 'Vendor Name *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.business),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter vendor name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      // Expected Delivery Date
                      InkWell(
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now().add(
                              const Duration(days: 7),
                            ),
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(
                              const Duration(days: 365),
                            ),
                          );
                          if (date != null) {
                            setState(() {
                              _expectedDeliveryDate = date;
                            });
                          }
                        },
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Expected Delivery Date',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.calendar_today),
                          ),
                          child: Text(
                            _expectedDeliveryDate != null
                                ? '${_expectedDeliveryDate!.day}/${_expectedDeliveryDate!.month}/${_expectedDeliveryDate!.year}'
                                : 'Select date',
                            style: TextStyle(
                              color: _expectedDeliveryDate != null
                                  ? Colors.black
                                  : Colors.grey,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Line Items Section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Items',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextButton.icon(
                            onPressed: _addLineItem,
                            icon: const Icon(Icons.add),
                            label: const Text('Add Item'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ..._lineItems.asMap().entries.map((entry) {
                        final index = entry.key;
                        final item = entry.value;
                        return _buildLineItemInput(index, item);
                      }),
                      const SizedBox(height: 24),
                      // Additional Costs
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _shippingCostController,
                              decoration: const InputDecoration(
                                labelText: 'Shipping Cost',
                                border: OutlineInputBorder(),
                                prefixText: '₹ ',
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _taxController,
                              decoration: const InputDecoration(
                                labelText: 'Tax Amount',
                                border: OutlineInputBorder(),
                                prefixText: '₹ ',
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Notes
                      TextFormField(
                        controller: _notesController,
                        decoration: const InputDecoration(
                          labelText: 'Notes',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.note),
                        ),
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Footer
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 12),
                  FilledButton.icon(
                    onPressed: _createPO,
                    icon: const Icon(Icons.check),
                    label: const Text('Create PO'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLineItemInput(int index, _POLineItemInput item) {
    return BlocBuilder<InventoryCubit, InventoryState>(
      builder: (context, state) {
        if (state is! InventoryLoaded) {
          return const SizedBox();
        }

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: DropdownButtonFormField<InventoryItem>(
                        value: item.selectedItem,
                        decoration: const InputDecoration(
                          labelText: 'Item *',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        items: state.items.map((inventoryItem) {
                          return DropdownMenuItem(
                            value: inventoryItem,
                            child: Text(inventoryItem.name),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            item.selectedItem = value;
                            if (value != null) {
                              item.priceController.text = value.pricePerUnit
                                  .toString();
                            }
                          });
                        },
                        validator: (value) {
                          if (value == null) {
                            return 'Select item';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                        controller: item.quantityController,
                        decoration: InputDecoration(
                          labelText: 'Qty *',
                          border: const OutlineInputBorder(),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          suffix: Text(item.selectedItem?.unit.name ?? ''),
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'^\d+\.?\d{0,2}'),
                          ),
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Required';
                          }
                          if (double.tryParse(value) == null ||
                              double.parse(value) <= 0) {
                            return 'Invalid';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                        controller: item.priceController,
                        decoration: const InputDecoration(
                          labelText: 'Price *',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          prefixText: '₹',
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'^\d+\.?\d{0,2}'),
                          ),
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Required';
                          }
                          if (double.tryParse(value) == null ||
                              double.parse(value) <= 0) {
                            return 'Invalid';
                          }
                          return null;
                        },
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: _lineItems.length > 1
                          ? () => _removeLineItem(index)
                          : null,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _POLineItemInput {
  InventoryItem? selectedItem;
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController priceController = TextEditingController();

  void dispose() {
    quantityController.dispose();
    priceController.dispose();
  }
}
