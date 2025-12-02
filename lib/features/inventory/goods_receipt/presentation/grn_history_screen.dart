import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hotel_manager/features/inventory/goods_receipt/data/goods_receipt_model.dart';
import 'package:hotel_manager/features/inventory/goods_receipt/logic/goods_receipt_cubit.dart';
import 'package:hotel_manager/features/inventory/goods_receipt/logic/goods_receipt_state.dart';
import 'package:intl/intl.dart';

class GRNHistoryScreen extends StatefulWidget {
  const GRNHistoryScreen({super.key});

  @override
  State<GRNHistoryScreen> createState() => _GRNHistoryScreenState();
}

class _GRNHistoryScreenState extends State<GRNHistoryScreen> {
  DateTimeRange? _dateFilter;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Goods Receipt History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: BlocBuilder<GoodsReceiptCubit, GoodsReceiptState>(
        builder: (context, state) {
          if (state is! GoodsReceiptLoaded) {
            return const Center(child: CircularProgressIndicator());
          }

          var grns = state.grns;

          // Apply date filter
          if (_dateFilter != null) {
            grns = grns
                .where(
                  (grn) =>
                      grn.receivedAt.isAfter(_dateFilter!.start) &&
                      grn.receivedAt.isBefore(
                        _dateFilter!.end.add(const Duration(days: 1)),
                      ),
                )
                .toList();
          }

          if (grns.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inventory_2,
                    size: 64,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No Goods Receipts',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Received goods will appear here',
                    style: TextStyle(color: Colors.grey.shade500),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: grns.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final grn = grns[index];
              return _buildGRNCard(context, grn);
            },
          );
        },
      ),
    );
  }

  Widget _buildGRNCard(BuildContext context, GoodsReceiptNote grn) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () => _showGRNDetail(context, grn),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          grn.grnNumber,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          grn.vendorName ?? 'No Vendor',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (grn.isLinkedToPO)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.blue),
                      ),
                      child: Text(
                        grn.purchaseOrderNumber!,
                        style: const TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.orange),
                      ),
                      child: const Text(
                        'No PO',
                        style: TextStyle(
                          color: Colors.orange,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 12),
              // Details Grid
              Row(
                children: [
                  Expanded(
                    child: _buildInfoItem(
                      icon: Icons.calendar_today,
                      label: 'Received',
                      value: DateFormat('dd MMM yyyy').format(grn.receivedAt),
                    ),
                  ),
                  Expanded(
                    child: _buildInfoItem(
                      icon: Icons.person,
                      label: 'Received By',
                      value: grn.receivedByName,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildInfoItem(
                      icon: Icons.inventory_2,
                      label: 'Items',
                      value: '${grn.totalItems}',
                    ),
                  ),
                  Expanded(
                    child: _buildInfoItem(
                      icon: Icons.currency_rupee,
                      label: 'Value',
                      value: '₹${grn.totalValue.toStringAsFixed(0)}',
                    ),
                  ),
                ],
              ),
              if (grn.hasProofImages) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    if (grn.billImagePath != null)
                      const Chip(
                        avatar: Icon(Icons.receipt, size: 16),
                        label: Text('Bill', style: TextStyle(fontSize: 11)),
                        visualDensity: VisualDensity.compact,
                      ),
                    if (grn.billImagePath != null && grn.goodsImagePath != null)
                      const SizedBox(width: 8),
                    if (grn.goodsImagePath != null)
                      const Chip(
                        avatar: Icon(Icons.photo_camera, size: 16),
                        label: Text('Photo', style: TextStyle(fontSize: 11)),
                        visualDensity: VisualDensity.compact,
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade600),
        const SizedBox(width: 4),
        Expanded(
          child: Column(
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
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showFilterDialog() async {
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      initialDateRange: _dateFilter,
    );

    if (range != null) {
      setState(() {
        _dateFilter = range;
      });
    }
  }

  void _showGRNDetail(BuildContext context, GoodsReceiptNote grn) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          width: 500,
          constraints: const BoxConstraints(maxHeight: 600),
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
                    Expanded(
                      child: Text(
                        grn.grnNumber,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailRow('Vendor', grn.vendorName ?? 'N/A'),
                      _buildDetailRow(
                        'PO Number',
                        grn.purchaseOrderNumber ?? 'No PO',
                      ),
                      _buildDetailRow(
                        'Invoice Number',
                        grn.invoiceNumber ?? 'N/A',
                      ),
                      _buildDetailRow('Received By', grn.receivedByName),
                      _buildDetailRow(
                        'Received At',
                        DateFormat(
                          'dd MMM yyyy, hh:mm a',
                        ).format(grn.receivedAt),
                      ),
                      if (grn.deliveryPersonName != null)
                        _buildDetailRow(
                          'Delivery Person',
                          grn.deliveryPersonName!,
                        ),
                      if (grn.deliveryPersonPhone != null)
                        _buildDetailRow(
                          'Delivery Phone',
                          grn.deliveryPersonPhone!,
                        ),
                      const SizedBox(height: 16),
                      const Text(
                        'Items Received',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...grn.lineItems.map(
                        (item) => Card(
                          child: ListTile(
                            title: Text(item.itemName),
                            subtitle: Text(
                              '${item.quantityReceived} ${item.unit.name} @ ₹${item.pricePerUnit}/${item.unit.name}',
                            ),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '₹${item.totalValue.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (item.qualityCheckPassed)
                                  const Icon(
                                    Icons.check_circle,
                                    color: Colors.green,
                                    size: 16,
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total Value',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '₹${grn.totalValue.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (grn.notes != null) ...[
                        const SizedBox(height: 16),
                        const Text(
                          'Notes',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(grn.notes!),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
