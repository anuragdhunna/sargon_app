import 'package:hotel_manager/features/inventory/goods_receipt/presentation/widgets/delivery_details_widget.dart';
import 'package:hotel_manager/features/inventory/goods_receipt/presentation/widgets/image_capture_card_widget.dart';
import 'package:hotel_manager/features/inventory/goods_receipt/presentation/widgets/manual_item_card_widget.dart';
import 'package:hotel_manager/features/inventory/goods_receipt/presentation/widgets/receiving_inputs.dart';
import 'package:hotel_manager/features/inventory/goods_receipt/presentation/widgets/receiving_item_card_widget.dart';
import 'package:hotel_manager/features/inventory/purchase_orders/presentation/widgets/po_selection_widget.dart';
import 'package:hotel_manager/features/inventory/vendors/presentation/widgets/vendor_info_widget.dart';
import 'package:uuid/uuid.dart';

import '../../inventory_index.dart';

/// Screen for receiving goods from vendors
///
/// Supports two modes:
/// 1. Receiving against a Purchase Order
/// 2. Receiving without a Purchase Order (manual item selection)
class GoodsReceivingScreen extends StatefulWidget {
  final String? purchaseOrderId;

  const GoodsReceivingScreen({super.key, this.purchaseOrderId});

  @override
  State<GoodsReceivingScreen> createState() => _GoodsReceivingScreenState();
}

class _GoodsReceivingScreenState extends State<GoodsReceivingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _deliveryPersonNameController = TextEditingController();
  final _deliveryPersonPhoneController = TextEditingController();
  final _invoiceNumberController = TextEditingController();
  final _vendorNameController = TextEditingController();
  final _notesController = TextEditingController();

  PurchaseOrder? _selectedPO;
  List<ReceivingItemInput> _receivingItems = [];
  final List<ManualItemInput> _manualItems = [];
  String? _billImagePath;
  String? _goodsImagePath;
  bool _withoutPO = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _withoutPO = widget.purchaseOrderId == null;
    if (widget.purchaseOrderId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final po = context.read<PurchaseOrderCubit>().getPOById(
          widget.purchaseOrderId!,
        );
        if (po != null) {
          setState(() {
            _selectedPO = po;
            _vendorNameController.text = po.vendorName ?? '';
            _initializeReceivingItems(po);
          });
        }
      });
    }
  }

  void _initializeReceivingItems(PurchaseOrder po) {
    _receivingItems = po.lineItems
        .where((item) => item.pendingQuantity > 0)
        .map((item) {
          return ReceivingItemInput(
            lineItem: item,
            maxQuantity: item.pendingQuantity,
          );
        })
        .toList();
  }

  @override
  void dispose() {
    _vendorNameController.dispose();
    _deliveryPersonNameController.dispose();
    _deliveryPersonPhoneController.dispose();
    _notesController.dispose();
    for (var input in _receivingItems) {
      input.dispose();
    }
    for (var input in _manualItems) {
      input.dispose();
    }
    super.dispose();
  }

  /// Capture image for proof of delivery
  void _captureImage(bool isBill) {
    /// Mock image capture - in production, use image_picker package
    setState(() {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      if (isBill) {
        _billImagePath = '/mock/images/bill_$timestamp.jpg';
      } else {
        _goodsImagePath = '/mock/images/goods_$timestamp.jpg';
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${isBill ? 'Bill' : 'Goods'} image captured')),
    );
  }

  /// Add a new manual item row for receiving without PO
  void _addManualItem() {
    setState(() {
      _manualItems.add(ManualItemInput());
    });
  }

  /// Remove a manual item row
  void _removeManualItem(int index) {
    setState(() {
      _manualItems[index].dispose();
      _manualItems.removeAt(index);
    });
  }

  /// Submit the goods receipt note
  void _submitGRN() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fix the errors in the form'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_isSubmitting) return;

    final authState = context.read<AuthCubit>().state;
    if (authState is! AuthVerified) return;

    /// Collect line items with received quantities
    final grnLineItems = <GRNLineItem>[];
    final uuid = const Uuid();

    if (_withoutPO) {
      /// Validate vendor name is provided
      if (_vendorNameController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter vendor name'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      /// Collect manual items
      for (var input in _manualItems) {
        if (input.selectedItem == null) continue;

        final quantity = double.tryParse(input.quantityController.text) ?? 0;
        final price = double.tryParse(input.priceController.text) ?? 0;

        if (quantity > 0 && price > 0) {
          grnLineItems.add(
            GRNLineItem(
              id: uuid.v4(),
              inventoryItemId: input.selectedItem!.id,
              itemName: input.selectedItem!.name,
              unit: input.selectedItem!.unit,
              quantityReceived: quantity,
              pricePerUnit: price,
              qualityCheckPassed: input.qualityCheckPassed,
              notes: input.notesController.text.isNotEmpty
                  ? input.notesController.text
                  : null,
            ),
          );
        }
      }
    } else {
      if (_selectedPO != null) {
        for (var input in _receivingItems) {
          final quantity = double.tryParse(input.quantityController.text) ?? 0;
          if (quantity > 0) {
            grnLineItems.add(
              GRNLineItem(
                id: const Uuid().v4(),
                inventoryItemId: input.lineItem.inventoryItemId,
                itemName: input.lineItem.itemName,
                unit: input.lineItem.unit,
                quantityReceived: quantity,
                pricePerUnit: input.lineItem.pricePerUnit,
                qualityCheckPassed: input.qualityCheckPassed,
                notes: input.notesController.text,
              ),
            );
          }
        }
      }
    }

    if (grnLineItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one item with quantity'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    /// Create GRN
    await context.read<GoodsReceiptCubit>().createGoodsReceipt(
      purchaseOrderId: _selectedPO?.id,
      vendorId: _withoutPO ? uuid.v4() : _selectedPO?.vendorId,
      vendorName: _withoutPO
          ? _vendorNameController.text.trim()
          : _selectedPO?.vendorName,
      lineItems: grnLineItems,
      receivedBy: authState.userId,
      receivedByName: authState.userName,
      deliveryPersonName: _deliveryPersonNameController.text.isNotEmpty
          ? _deliveryPersonNameController.text
          : null,
      deliveryPersonPhone: _deliveryPersonPhoneController.text.isNotEmpty
          ? _deliveryPersonPhoneController.text
          : null,
      billImagePath: _billImagePath,
      goodsImagePath: _goodsImagePath,
      invoiceNumber: _invoiceNumberController.text.isNotEmpty
          ? _invoiceNumberController.text
          : null,
      notes: _notesController.text.isNotEmpty ? _notesController.text : null,
      userId: authState.userId,
      userName: authState.userName,
      userRole: authState.role.name,
    );

    setState(() {
      _isSubmitting = false;
    });

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Goods received successfully! Inventory updated.'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Receive Goods'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (!_withoutPO && _selectedPO != null)
            Padding(
              padding: const EdgeInsets.only(right: AppDesign.space4),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDesign.space3,
                    vertical: AppDesign.space1,
                  ),
                  decoration: BoxDecoration(
                    color: AppDesign.primaryStart.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppDesign.radiusFull),
                    border: Border.all(
                      color: AppDesign.primaryStart.withOpacity(0.2),
                    ),
                  ),
                  child: Text(
                    _selectedPO!.poNumber,
                    style: AppDesign.labelMedium.copyWith(
                      color: AppDesign.primaryStart,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.purchaseOrderId == null)
                POSelectionWidget(
                  selectedPO: _selectedPO,
                  onChanged: (po) {
                    setState(() {
                      _selectedPO = po;
                      if (po != null) {
                        _withoutPO = false;
                        _initializeReceivingItems(po);
                        _vendorNameController.text = po.vendorName ?? '';
                      } else {
                        _receivingItems.clear();
                        _vendorNameController.clear();
                      }
                    });
                  },
                ),

              if (_selectedPO == null && widget.purchaseOrderId == null) ...[
                CheckboxListTile(
                  title: const Text('Receive without Purchase Order'),
                  value: _withoutPO,
                  onChanged: (value) {
                    setState(() {
                      _withoutPO = value ?? false;
                      if (_withoutPO) {
                        _selectedPO = null;
                        _receivingItems.clear();
                        _vendorNameController.clear();
                      }
                    });
                  },
                ),
              ],

              if (_selectedPO != null || _withoutPO) ...[
                const SizedBox(height: 24),
                AppCard(
                  child: VendorInfoWidget(
                    controller: _vendorNameController,
                    enabled: _withoutPO,
                  ),
                ),

                const SizedBox(height: 24),
                DeliveryDetailsWidget(
                  nameController: _deliveryPersonNameController,
                  phoneController: _deliveryPersonPhoneController,
                ),

                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: ImageCaptureCardWidget(
                        label: 'Bill/Invoice Image',
                        imagePath: _billImagePath,
                        onCapture: () => _captureImage(true),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ImageCaptureCardWidget(
                        label: 'Goods Image',
                        imagePath: _goodsImagePath,
                        onCapture: () => _captureImage(false),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppDesign.space6),
                Text(
                  'Items Received',
                  style: AppDesign.headlineSmall.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppDesign.space3),

                if (_selectedPO != null) ...[
                  ..._receivingItems.map(
                    (input) => ReceivingItemCardWidget(
                      input: input,
                      onRemove: () {},
                      onQualityChanged: (value) {
                        setState(() {
                          input.qualityCheckPassed = value;
                        });
                      },
                    ),
                  ),
                ] else ...[
                  ..._manualItems.asMap().entries.map((entry) {
                    return ManualItemCardWidget(
                      index: entry.key,
                      input: entry.value,
                      onRemove: () => _removeManualItem(entry.key),
                      onItemChanged: (value) {
                        setState(() {
                          entry.value.selectedItem = value;
                        });
                      },
                      onQualityChanged: (value) {
                        setState(() {
                          entry.value.qualityCheckPassed = value;
                        });
                      },
                    );
                  }),
                  PremiumButton.secondary(
                    onPressed: _addManualItem,
                    label: 'Add Item',
                    icon: Icons.add,
                  ),
                ],

                const SizedBox(height: 32),
                PremiumButton.primary(
                  onPressed: _submitGRN,
                  label: 'Complete Receiving',
                  isLoading: _isSubmitting,
                ),
                const SizedBox(height: 32),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
