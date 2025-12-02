import 'package:intl/intl.dart';

import '../inventory_index.dart';

class PODetailScreen extends StatelessWidget {
  final String purchaseOrderId;

  const PODetailScreen({super.key, required this.purchaseOrderId});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PurchaseOrderCubit, PurchaseOrderState>(
      builder: (context, state) {
        if (state is! PurchaseOrderLoaded) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final po = context.read<PurchaseOrderCubit>().getPOById(
          purchaseOrderId,
        );
        if (po == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Purchase Order')),
            body: const Center(child: Text('Purchase Order not found')),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(po.poNumber),
            actions: [
              if (po.status != POStatus.cancelled &&
                  po.status != POStatus.completed)
                PopupMenuButton(
                  itemBuilder: (context) => [
                    if (po.status == POStatus.sent ||
                        po.status == POStatus.partial)
                      const PopupMenuItem(
                        value: 'receive',
                        child: Row(
                          children: [
                            Icon(Icons.inventory_2, size: 20),
                            SizedBox(width: 8),
                            Text('Receive Goods'),
                          ],
                        ),
                      ),
                    const PopupMenuItem(
                      value: 'cancel',
                      child: Row(
                        children: [
                          Icon(Icons.cancel, size: 20, color: Colors.red),
                          SizedBox(width: 8),
                          Text(
                            'Cancel PO',
                            style: TextStyle(color: Colors.red),
                          ),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (value) {
                    if (value == 'receive') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              GoodsReceivingScreen(purchaseOrderId: po.id),
                        ),
                      );
                    } else if (value == 'cancel') {
                      _showCancelDialog(context, po);
                    }
                  },
                ),
            ],
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Card
                _buildHeaderCard(context, po),
                const SizedBox(height: 16),
                // Line Items
                _buildLineItemsSection(context, po),
                const SizedBox(height: 16),
                // Summary Card
                _buildSummaryCard(context, po),
                const SizedBox(height: 100),
              ],
            ),
          ),
          bottomSheet:
              po.status != POStatus.cancelled && po.status != POStatus.completed
              ? Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    child: PremiumButton.primary(
                      label: 'Receive Goods',
                      icon: Icons.inventory_2,
                      isFullWidth: true,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                GoodsReceivingScreen(purchaseOrderId: po.id),
                          ),
                        );
                      },
                    ),
                  ),
                )
              : null,
        );
      },
    );
  }

  Widget _buildHeaderCard(BuildContext context, PurchaseOrder po) {
    final theme = Theme.of(context);
    final statusColor = _getStatusColor(po.status);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [statusColor.withOpacity(0.1), statusColor.withOpacity(0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
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
                      po.vendorName ?? 'No Vendor',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Created by ${po.createdBy}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  po.status.displayName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildInfoChip(
                  icon: Icons.calendar_today,
                  label: 'Created',
                  value: DateFormat('dd MMM yyyy').format(po.createdAt),
                ),
              ),
              if (po.expectedDeliveryDate != null)
                Expanded(
                  child: _buildInfoChip(
                    icon: Icons.local_shipping,
                    label: 'Expected',
                    value: DateFormat(
                      'dd MMM yyyy',
                    ).format(po.expectedDeliveryDate!),
                  ),
                ),
            ],
          ),
          if (po.notes != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.note, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(po.notes!, style: theme.textTheme.bodySmall),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey.shade600),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLineItemsSection(BuildContext context, PurchaseOrder po) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Items (${po.lineItems.length})',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: po.lineItems.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final item = po.lineItems[index];
              return _buildLineItemCard(context, item);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLineItemCard(BuildContext context, POLineItem item) {
    final progress = item.orderedQuantity > 0
        ? item.receivedQuantity / item.orderedQuantity
        : 0.0;
    final isFullyReceived = item.isFullyReceived;
    final isPartiallyReceived = item.isPartiallyReceived;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
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
                        item.itemName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '₹${item.pricePerUnit}/${item.unit.name}',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '₹${item.totalPrice.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    if (isFullyReceived)
                      const Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 20,
                      )
                    else if (isPartiallyReceived)
                      const Icon(
                        Icons.timelapse,
                        color: Colors.orange,
                        size: 20,
                      ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildQuantityInfo(
                    'Ordered',
                    item.orderedQuantity,
                    item.unit.name,
                    Colors.blue,
                  ),
                ),
                Expanded(
                  child: _buildQuantityInfo(
                    'Received',
                    item.receivedQuantity,
                    item.unit.name,
                    Colors.green,
                  ),
                ),
                Expanded(
                  child: _buildQuantityInfo(
                    'Pending',
                    item.pendingQuantity,
                    item.unit.name,
                    Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(
                isFullyReceived ? Colors.green : Colors.orange,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuantityInfo(
    String label,
    double quantity,
    String unit,
    Color color,
  ) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 2),
        Text(
          '${quantity.toStringAsFixed(0)} $unit',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(BuildContext context, PurchaseOrder po) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        color: Colors.grey.shade50,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Order Summary',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              _buildSummaryRow(
                'Subtotal',
                '₹${po.subtotal.toStringAsFixed(2)}',
              ),
              if (po.shippingCost != null)
                _buildSummaryRow(
                  'Shipping',
                  '₹${po.shippingCost!.toStringAsFixed(2)}',
                ),
              if (po.taxAmount != null)
                _buildSummaryRow('Tax', '₹${po.taxAmount!.toStringAsFixed(2)}'),
              const Divider(height: 24),
              _buildSummaryRow(
                'Total',
                '₹${po.total.toStringAsFixed(2)}',
                isTotal: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 18 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(POStatus status) {
    switch (status) {
      case POStatus.draft:
        return Colors.grey;
      case POStatus.sent:
        return Colors.blue;
      case POStatus.partial:
        return Colors.orange;
      case POStatus.completed:
        return Colors.green;
      case POStatus.cancelled:
        return Colors.red;
    }
  }

  void _showCancelDialog(BuildContext context, PurchaseOrder po) {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Cancel Purchase Order'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Are you sure you want to cancel ${po.poNumber}?'),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Reason (optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          PremiumButton.secondary(
            label: 'Cancel',
            onPressed: () => Navigator.pop(dialogContext),
          ),
          PremiumButton.primary(
            label: 'Confirm Cancel',
            onPressed: () {
              final authState = context.read<AuthCubit>().state;
              if (authState is AuthVerified) {
                context.read<PurchaseOrderCubit>().cancelPurchaseOrder(
                  po.id,
                  userId: authState.userId,
                  userName: authState.userName,
                  userRole: authState.role.name,
                  reason: reasonController.text.isNotEmpty
                      ? reasonController.text
                      : null,
                );
              }
              Navigator.pop(dialogContext);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
