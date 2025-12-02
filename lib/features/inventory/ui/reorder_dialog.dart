import 'package:uuid/uuid.dart';
import 'package:flutter/services.dart';

import '../inventory_index.dart';

/// Dialog for reordering low stock items
///
/// Shows all items below minimum quantity and allows user to:
/// - Review suggested reorder quantities
/// - Adjust quantities as needed
/// - Enter vendor information
/// - Create a Purchase Order directly
class ReorderDialog extends StatefulWidget {
  final List<InventoryItem>? preselectedItems;

  const ReorderDialog({super.key, this.preselectedItems});

  @override
  State<ReorderDialog> createState() => _ReorderDialogState();
}

class _ReorderDialogState extends State<ReorderDialog> {
  final _formKey = GlobalKey<FormState>();
  Vendor? _selectedVendor;
  final Map<String, _ReorderItemInput> _reorderItems = {};
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeReorderItems();
    });
  }

  void _initializeReorderItems() {
    final inventoryState = context.read<InventoryCubit>().state;
    if (inventoryState is! InventoryLoaded) return;

    final lowStockItems =
        widget.preselectedItems ??
        inventoryState.items.where((item) => item.isLowStock).toList();

    setState(() {
      for (var item in lowStockItems) {
        /// Calculate suggested reorder quantity: (min - current) * 1.5 for 50% buffer
        final deficit = item.minQuantity - item.quantity;
        final suggestedQty = (deficit * 1.5).ceil().toDouble();

        _reorderItems[item.id] = _ReorderItemInput(
          item: item,
          suggestedQuantity: suggestedQty,
        );
      }
    });
  }

  @override
  void dispose() {
    for (var input in _reorderItems.values) {
      input.dispose();
    }
    super.dispose();
  }

  void _submitReorder() async {
    if (!_formKey.currentState!.validate()) {
      CustomSnackbar.showError(context, 'Please fix the errors in the form');
      return;
    }

    if (_selectedVendor == null) {
      CustomSnackbar.showError(context, 'Please select a vendor');
      return;
    }

    final authState = context.read<AuthCubit>().state;
    if (authState is! AuthVerified) return;

    setState(() {
      _isSubmitting = true;
    });

    /// Collect line items
    final lineItems = <POLineItem>[];
    final uuid = const Uuid();

    for (var entry in _reorderItems.entries) {
      final input = entry.value;
      final quantity = double.tryParse(input.quantityController.text) ?? 0;

      if (quantity > 0) {
        lineItems.add(
          POLineItem(
            id: uuid.v4(),
            inventoryItemId: input.item.id,
            itemName: input.item.name,
            unit: input.item.unit,
            orderedQuantity: quantity,
            receivedQuantity: 0,
            pricePerUnit: input.item.pricePerUnit,
          ),
        );
      }
    }

    if (lineItems.isEmpty) {
      setState(() {
        _isSubmitting = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one item with quantity'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    /// Create PO
    context.read<PurchaseOrderCubit>().createPurchaseOrder(
      vendorId: _selectedVendor!.id,
      vendorName: _selectedVendor!.name,
      lineItems: lineItems,
      createdBy: authState.userName,
      userId: authState.userId,
      userName: authState.userName,
      userRole: authState.role.name,
      notes: 'Auto-generated reorder for low stock items',
    );

    setState(() {
      _isSubmitting = false;
    });

    if (mounted) {
      Navigator.pop(context);
      CustomSnackbar.showSuccess(context, 'Reorder PO created successfully!');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 600,
        constraints: const BoxConstraints(maxHeight: 700),
        child: Column(
          children: [
            /// Header
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
                  const Icon(Icons.shopping_cart, color: Colors.white),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Reorder Low Stock Items',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Review and adjust quantities before creating PO',
                          style: TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            /// Body
            Expanded(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// Info Card
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blue.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Colors.blue.shade700,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Suggested quantities are calculated as: (Min Qty - Current Qty) × 1.5 to provide a 50% buffer.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.blue.shade900,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      /// Vendor Selection
                      VendorSelectionDropdown(
                        selectedVendorId: _selectedVendor?.id,
                        onVendorSelected: (vendor) {
                          setState(() {
                            _selectedVendor = vendor;
                          });
                        },
                        label: 'Select Vendor *',
                        showPreferredOnly: false,
                      ),
                      const SizedBox(height: 20),

                      /// Items Section
                      Row(
                        children: [
                          const Text(
                            'Items to Reorder',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red.shade100,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${_reorderItems.length}',
                              style: TextStyle(
                                color: Colors.red.shade900,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      if (_reorderItems.isEmpty)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(32),
                            child: Text('No low stock items found'),
                          ),
                        )
                      else
                        ..._reorderItems.entries.map((entry) {
                          return _buildReorderItemCard(entry.value);
                        }),
                    ],
                  ),
                ),
              ),
            ),

            /// Footer
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                border: Border(top: BorderSide(color: Colors.grey.shade300)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isSubmitting
                          ? null
                          : () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: PremiumButton.primary(
                      label: 'Send Order',
                      icon: Icons.send,
                      isFullWidth: true,
                      isLoading: _isSubmitting,
                      onPressed: _isSubmitting ? null : _submitReorder,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReorderItemCard(_ReorderItemInput input) {
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
                        input.item.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${input.item.category.name} • ₹${input.item.pricePerUnit}/${input.item.unit.name}',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'Low Stock',
                    style: TextStyle(
                      color: Colors.red.shade700,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStockInfo(
                    'Current',
                    input.item.quantity,
                    Colors.red,
                  ),
                ),
                Expanded(
                  child: _buildStockInfo(
                    'Minimum',
                    input.item.minQuantity,
                    Colors.orange,
                  ),
                ),
                Expanded(
                  child: _buildStockInfo(
                    'Deficit',
                    input.item.minQuantity - input.item.quantity,
                    Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: input.quantityController,
              decoration: InputDecoration(
                labelText: 'Order Quantity *',
                border: const OutlineInputBorder(),
                suffix: Text(input.item.unit.name),
                helperText:
                    'Suggested: ${input.suggestedQuantity.toStringAsFixed(0)} ${input.item.unit.name}',
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Required';
                }
                final qty = double.tryParse(value);
                if (qty == null || qty <= 0) {
                  return 'Invalid quantity';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStockInfo(String label, double value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 2),
        Text(
          value.toStringAsFixed(0),
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}

/// Input model for reorder items
class _ReorderItemInput {
  final InventoryItem item;
  final double suggestedQuantity;
  final TextEditingController quantityController;

  _ReorderItemInput({required this.item, required this.suggestedQuantity})
    : quantityController = TextEditingController(
        text: suggestedQuantity.toStringAsFixed(0),
      );

  void dispose() {
    quantityController.dispose();
  }
}
