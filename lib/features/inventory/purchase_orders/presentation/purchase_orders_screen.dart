import 'package:hotel_manager/features/inventory/purchase_orders/presentation/create_po_dialog.dart';
import 'package:intl/intl.dart';

import '../../inventory_index.dart';

/// Premium Purchase Orders Screen
///
/// Features:
/// - Filter by status
/// - Search by PO number or vendor
/// - Premium card-based UI
/// - Status indicators
class PurchaseOrdersScreen extends StatefulWidget {
  const PurchaseOrdersScreen({super.key});

  @override
  State<PurchaseOrdersScreen> createState() => _PurchaseOrdersScreenState();
}

class _PurchaseOrdersScreenState extends State<PurchaseOrdersScreen> {
  POStatus? _selectedFilter;
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Purchase Orders')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => const CreatePODialog(),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('New PO'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppDesign.space4),
            child: Column(
              children: [
                PremiumSearchBar(
                  hintText: 'Search PO number or vendor...',
                  onSearch: (query) {
                    setState(() {
                      _searchQuery = query;
                    });
                  },
                  showFilter: true,
                  onFilterTap: () => _showFilterMenu(context),
                ),
                if (_selectedFilter != null) ...[
                  const SizedBox(height: AppDesign.space3),
                  Container(
                    padding: const EdgeInsets.all(AppDesign.space3),
                    decoration: BoxDecoration(
                      color: AppDesign.info.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppDesign.radiusMd),
                      border: Border.all(
                        color: AppDesign.info.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.filter_list,
                          size: 16,
                          color: AppDesign.info,
                        ),
                        const SizedBox(width: AppDesign.space2),
                        Text(
                          'Filtered by: ${_selectedFilter!.displayName}',
                          style: AppDesign.bodySmall.copyWith(
                            color: AppDesign.info,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _selectedFilter = null;
                            });
                          },
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(50, 30),
                          ),
                          child: const Text('Clear'),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          Expanded(
            child: BlocBuilder<PurchaseOrderCubit, PurchaseOrderState>(
              builder: (context, state) {
                if (state is! PurchaseOrderLoaded) {
                  return const Center(child: CircularProgressIndicator());
                }

                var orders = state.orders;

                // Apply filters
                if (_selectedFilter != null) {
                  orders = orders
                      .where((po) => po.status == _selectedFilter)
                      .toList();
                }

                // Apply search
                if (_searchQuery.isNotEmpty) {
                  orders = orders.where((po) {
                    return po.poNumber.toLowerCase().contains(
                          _searchQuery.toLowerCase(),
                        ) ||
                        (po.vendorName?.toLowerCase().contains(
                              _searchQuery.toLowerCase(),
                            ) ??
                            false);
                  }).toList();
                }

                if (orders.isEmpty) {
                  return EmptyState(
                    icon: Icons.receipt_long,
                    title: _selectedFilter == null && _searchQuery.isEmpty
                        ? 'No Purchase Orders'
                        : 'No Orders Found',
                    message: _selectedFilter == null && _searchQuery.isEmpty
                        ? 'Create your first PO to get started'
                        : 'Try adjusting your search or filters',
                    actionLabel: _selectedFilter == null && _searchQuery.isEmpty
                        ? 'Create PO'
                        : 'Clear Filters',
                    onAction: () {
                      if (_selectedFilter == null && _searchQuery.isEmpty) {
                        showDialog(
                          context: context,
                          builder: (context) => const CreatePODialog(),
                        );
                      } else {
                        setState(() {
                          _selectedFilter = null;
                          _searchQuery = '';
                        });
                      }
                    },
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(AppDesign.space4),
                  itemCount: orders.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: AppDesign.space3),
                  itemBuilder: (context, index) {
                    return _buildPOCard(context, orders[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPOCard(BuildContext context, PurchaseOrder po) {
    return PremiumInfoCard(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PODetailScreen(purchaseOrderId: po.id),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(po.poNumber, style: AppDesign.titleMedium),
                    const SizedBox(height: 2),
                    Text(
                      po.vendorName ?? 'No Vendor',
                      style: AppDesign.bodySmall.copyWith(
                        color: AppDesign.neutral500,
                      ),
                    ),
                  ],
                ),
              ),
              _buildStatusBadge(po.status),
            ],
          ),
          const SizedBox(height: AppDesign.space3),
          const Divider(),
          const SizedBox(height: AppDesign.space3),
          Row(
            children: [
              Expanded(
                child: _buildInfoItem(
                  icon: Icons.calendar_today,
                  label: 'Created',
                  value: DateFormat('dd MMM yyyy').format(po.createdAt),
                ),
              ),
              Expanded(
                child: _buildInfoItem(
                  icon: Icons.inventory_2,
                  label: 'Items',
                  value: '${po.totalItemsOrdered}',
                ),
              ),
              Expanded(
                child: _buildInfoItem(
                  icon: Icons.currency_rupee,
                  label: 'Total',
                  value: '₹${po.total.toStringAsFixed(0)}',
                ),
              ),
            ],
          ),
          if (po.status == POStatus.partial ||
              po.status == POStatus.completed) ...[
            const SizedBox(height: AppDesign.space3),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Receiving Progress',
                      style: AppDesign.bodySmall.copyWith(
                        color: AppDesign.neutral500,
                      ),
                    ),
                    Text(
                      '${po.itemsFullyReceived}/${po.totalItemsOrdered} items',
                      style: AppDesign.bodySmall.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDesign.space2),
                LinearProgressIndicator(
                  value: po.itemsFullyReceived / po.totalItemsOrdered,
                  backgroundColor: AppDesign.neutral200,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    po.isFullyReceived ? AppDesign.success : AppDesign.warning,
                  ),
                  borderRadius: BorderRadius.circular(AppDesign.radiusFull),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusBadge(POStatus status) {
    switch (status) {
      case POStatus.draft:
        return StatusBadge(
          label: status.displayName,
          type: StatusType.info,
          icon: Icons.edit_note,
        );
      case POStatus.sent:
        return StatusBadge(
          label: status.displayName,
          type: StatusType.info,
          icon: Icons.send,
        );
      case POStatus.partial:
        return StatusBadge(
          label: status.displayName,
          type: StatusType.warning,
          icon: Icons.timelapse,
        );
      case POStatus.completed:
        return StatusBadge(
          label: status.displayName,
          type: StatusType.success,
          icon: Icons.check_circle,
        );
      case POStatus.cancelled:
        return StatusBadge(
          label: status.displayName,
          type: StatusType.error,
          icon: Icons.cancel,
        );
    }
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppDesign.neutral500),
        const SizedBox(width: AppDesign.space1),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppDesign.labelSmall.copyWith(color: AppDesign.neutral500),
            ),
            Text(
              value,
              style: AppDesign.bodySmall.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ],
    );
  }

  void _showFilterMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppDesign.space4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Filter by Status', style: AppDesign.titleLarge),
            const SizedBox(height: AppDesign.space4),
            ListTile(
              leading: const Icon(Icons.all_inclusive),
              title: const Text('All Orders'),
              selected: _selectedFilter == null,
              onTap: () {
                setState(() {
                  _selectedFilter = null;
                });
                Navigator.pop(context);
              },
            ),
            const Divider(),
            ...POStatus.values.map((status) {
              return ListTile(
                leading: Icon(_getStatusIcon(status)),
                title: Text(status.displayName),
                trailing: _selectedFilter == status
                    ? const Icon(Icons.check, color: AppDesign.success)
                    : null,
                selected: _selectedFilter == status,
                onTap: () {
                  setState(() {
                    _selectedFilter = status;
                  });
                  Navigator.pop(context);
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  IconData _getStatusIcon(POStatus status) {
    switch (status) {
      case POStatus.draft:
        return Icons.edit_note;
      case POStatus.sent:
        return Icons.send;
      case POStatus.partial:
        return Icons.timelapse;
      case POStatus.completed:
        return Icons.check_circle;
      case POStatus.cancelled:
        return Icons.cancel;
    }
  }
}
