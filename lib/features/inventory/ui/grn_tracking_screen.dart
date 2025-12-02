import 'package:intl/intl.dart';

import '../inventory_index.dart';

/// GRN Tracking Screen - Monitor received orders and delivery delays
///
/// Features:
/// - View all GRNs with status
/// - Track delivery delays
/// - Filter by status (on-time, delayed, pending)
/// - Search by GRN or vendor
class GRNTrackingScreen extends StatefulWidget {
  const GRNTrackingScreen({super.key});

  @override
  State<GRNTrackingScreen> createState() => _GRNTrackingScreenState();
}

class _GRNTrackingScreenState extends State<GRNTrackingScreen> {
  String _searchQuery = '';
  DeliveryStatus? _selectedFilter;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('GRN Tracking')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppDesign.space4),
            child: Column(
              children: [
                PremiumSearchBar(
                  hintText: 'Search GRN or vendor...',
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
                      color: _getFilterColor().withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppDesign.radiusMd),
                      border: Border.all(
                        color: _getFilterColor().withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _getFilterIcon(),
                          size: 16,
                          color: _getFilterColor(),
                        ),
                        const SizedBox(width: AppDesign.space2),
                        Text(
                          'Filtered by: ${_selectedFilter!.displayName}',
                          style: AppDesign.bodySmall.copyWith(
                            color: _getFilterColor(),
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
            child: BlocBuilder<GoodsReceiptCubit, GoodsReceiptState>(
              builder: (context, state) {
                if (state is! GoodsReceiptLoaded) {
                  return const Center(child: CircularProgressIndicator());
                }

                var grns = state.grns;

                // Apply filters
                if (_selectedFilter != null) {
                  grns = grns.where((grn) {
                    final status = _calculateDeliveryStatus(grn);
                    return status == _selectedFilter;
                  }).toList();
                }

                // Apply search
                if (_searchQuery.isNotEmpty) {
                  grns = grns.where((grn) {
                    return grn.grnNumber.toLowerCase().contains(
                          _searchQuery.toLowerCase(),
                        ) ||
                        (grn.vendorName?.toLowerCase().contains(
                              _searchQuery.toLowerCase(),
                            ) ??
                            false);
                  }).toList();
                }

                if (grns.isEmpty) {
                  return EmptyState(
                    icon: Icons.receipt_long,
                    title: 'No GRNs Found',
                    message: _selectedFilter == null && _searchQuery.isEmpty
                        ? 'No goods have been received yet'
                        : 'Try adjusting your search or filters',
                    actionLabel:
                        _selectedFilter != null || _searchQuery.isNotEmpty
                        ? 'Clear Filters'
                        : null,
                    onAction: _selectedFilter != null || _searchQuery.isNotEmpty
                        ? () {
                            setState(() {
                              _selectedFilter = null;
                              _searchQuery = '';
                            });
                          }
                        : null,
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(AppDesign.space4),
                  itemCount: grns.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: AppDesign.space3),
                  itemBuilder: (context, index) {
                    return _buildGRNCard(context, grns[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGRNCard(BuildContext context, GoodsReceiptNote grn) {
    final deliveryStatus = _calculateDeliveryStatus(grn);
    final daysDelayed = _calculateDaysDelayed(grn);

    return PremiumInfoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(grn.grnNumber, style: AppDesign.titleMedium),
                    const SizedBox(height: 2),
                    Text(
                      grn.vendorName ?? 'No Vendor',
                      style: AppDesign.bodySmall.copyWith(
                        color: AppDesign.neutral500,
                      ),
                    ),
                  ],
                ),
              ),
              _buildDeliveryStatusBadge(deliveryStatus, daysDelayed),
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
                  label: 'Received',
                  value: DateFormat('dd MMM yyyy').format(grn.receivedAt),
                ),
              ),
              Expanded(
                child: _buildInfoItem(
                  icon: Icons.inventory_2,
                  label: 'Items',
                  value: '${grn.lineItems.length}',
                ),
              ),
              Expanded(
                child: _buildInfoItem(
                  icon: Icons.person,
                  label: 'Received By',
                  value: grn.receivedBy,
                ),
              ),
            ],
          ),
          if (grn.purchaseOrderId != null) ...[
            const SizedBox(height: AppDesign.space2),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        PODetailScreen(purchaseOrderId: grn.purchaseOrderId!),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(AppDesign.radiusSm),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDesign.space3,
                  vertical: AppDesign.space2,
                ),
                decoration: BoxDecoration(
                  color: AppDesign.primaryStart.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppDesign.radiusSm),
                  border: Border.all(
                    color: AppDesign.primaryStart.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.receipt,
                      size: 16,
                      color: AppDesign.primaryStart,
                    ),
                    const SizedBox(width: AppDesign.space2),
                    Text(
                      'View PO: ${grn.purchaseOrderId}',
                      style: AppDesign.bodySmall.copyWith(
                        color: AppDesign.primaryStart,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: AppDesign.space1),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 12,
                      color: AppDesign.primaryStart,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDeliveryStatusBadge(DeliveryStatus status, int daysDelayed) {
    switch (status) {
      case DeliveryStatus.onTime:
        return StatusBadge.success(label: 'On Time', icon: Icons.check_circle);
      case DeliveryStatus.delayed:
        return StatusBadge.error(
          label: 'Delayed ($daysDelayed days)',
          icon: Icons.warning,
        );
      case DeliveryStatus.pending:
        return StatusBadge.warning(label: 'Pending', icon: Icons.pending);
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

  DeliveryStatus _calculateDeliveryStatus(GoodsReceiptNote grn) {
    // For now, using simple logic based on received date
    // In real app, would compare with expected delivery date from PO
    final daysSinceReceived = DateTime.now().difference(grn.receivedAt).inDays;

    if (grn.purchaseOrderId == null) {
      return DeliveryStatus.onTime; // No PO, so no delay tracking
    }

    // Mock logic: if received more than 7 days ago, consider on-time
    // if less, might still be pending
    if (daysSinceReceived > 7) {
      return DeliveryStatus.onTime;
    } else if (daysSinceReceived > 3) {
      return DeliveryStatus.delayed;
    } else {
      return DeliveryStatus.pending;
    }
  }

  int _calculateDaysDelayed(GoodsReceiptNote grn) {
    // Mock calculation - in real app would compare with PO expected date
    final daysSinceReceived = DateTime.now().difference(grn.receivedAt).inDays;
    return daysSinceReceived > 3 ? daysSinceReceived - 3 : 0;
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
            Text('Filter by Delivery Status', style: AppDesign.titleLarge),
            const SizedBox(height: AppDesign.space4),
            ListTile(
              leading: const Icon(Icons.all_inclusive),
              title: const Text('All GRNs'),
              selected: _selectedFilter == null,
              onTap: () {
                setState(() {
                  _selectedFilter = null;
                });
                Navigator.pop(context);
              },
            ),
            const Divider(),
            ...DeliveryStatus.values.map((status) {
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

  Color _getFilterColor() {
    switch (_selectedFilter!) {
      case DeliveryStatus.onTime:
        return AppDesign.success;
      case DeliveryStatus.delayed:
        return AppDesign.error;
      case DeliveryStatus.pending:
        return AppDesign.warning;
    }
  }

  IconData _getFilterIcon() {
    switch (_selectedFilter!) {
      case DeliveryStatus.onTime:
        return Icons.check_circle;
      case DeliveryStatus.delayed:
        return Icons.warning;
      case DeliveryStatus.pending:
        return Icons.pending;
    }
  }

  IconData _getStatusIcon(DeliveryStatus status) {
    switch (status) {
      case DeliveryStatus.onTime:
        return Icons.check_circle;
      case DeliveryStatus.delayed:
        return Icons.warning;
      case DeliveryStatus.pending:
        return Icons.pending;
    }
  }
}

enum DeliveryStatus { onTime, delayed, pending }

extension DeliveryStatusExtension on DeliveryStatus {
  String get displayName {
    switch (this) {
      case DeliveryStatus.onTime:
        return 'On Time';
      case DeliveryStatus.delayed:
        return 'Delayed';
      case DeliveryStatus.pending:
        return 'Pending';
    }
  }
}
