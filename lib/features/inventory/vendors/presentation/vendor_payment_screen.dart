import '../../inventory_index.dart';

/// Vendor Payment Tracking Screen
///
/// Features:
/// - View vendors with outstanding amounts
/// - Group POs by vendor
/// - Track payment status
/// - Calculate total payable per vendor
class VendorPaymentScreen extends StatefulWidget {
  const VendorPaymentScreen({super.key});

  @override
  State<VendorPaymentScreen> createState() => _VendorPaymentScreenState();
}

class _VendorPaymentScreenState extends State<VendorPaymentScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Vendor Payments')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppDesign.space4),
            child: PremiumSearchBar(
              hintText: 'Search vendors...',
              onSearch: (query) {
                setState(() {
                  _searchQuery = query;
                });
              },
            ),
          ),
          Expanded(
            child: BlocBuilder<VendorCubit, VendorState>(
              builder: (context, vendorState) {
                if (vendorState is! VendorLoaded) {
                  return const Center(child: CircularProgressIndicator());
                }

                return BlocBuilder<PurchaseOrderCubit, PurchaseOrderState>(
                  builder: (context, poState) {
                    if (poState is! PurchaseOrderLoaded) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    var vendors = vendorState.vendors;

                    // Apply search
                    if (_searchQuery.isNotEmpty) {
                      vendors = vendors.where((v) {
                        return v.name.toLowerCase().contains(
                              _searchQuery.toLowerCase(),
                            ) ||
                            v.contactPerson.toLowerCase().contains(
                              _searchQuery.toLowerCase(),
                            );
                      }).toList();
                    }

                    // Calculate outstanding amounts per vendor
                    final vendorPayments = vendors
                        .map((vendor) {
                          final vendorPOs = poState.orders
                              .where((po) => po.vendorId == vendor.id)
                              .toList();

                          final outstandingPOs = vendorPOs
                              .where((po) => po.status != POStatus.cancelled)
                              .toList();

                          final totalOutstanding = outstandingPOs.fold<double>(
                            0,
                            (sum, po) => sum + po.total,
                          );

                          return VendorPaymentInfo(
                            vendor: vendor,
                            purchaseOrders: outstandingPOs,
                            totalOutstanding: totalOutstanding,
                          );
                        })
                        .where((info) => info.totalOutstanding > 0)
                        .toList();

                    // Sort by outstanding amount (highest first)
                    vendorPayments.sort(
                      (a, b) =>
                          b.totalOutstanding.compareTo(a.totalOutstanding),
                    );

                    if (vendorPayments.isEmpty) {
                      return EmptyState(
                        icon: Icons.payments,
                        title: 'No Outstanding Payments',
                        message: _searchQuery.isEmpty
                            ? 'All vendors have been paid'
                            : 'No vendors found matching your search',
                        actionLabel: _searchQuery.isNotEmpty
                            ? 'Clear Search'
                            : null,
                        onAction: _searchQuery.isNotEmpty
                            ? () {
                                setState(() {
                                  _searchQuery = '';
                                });
                              }
                            : null,
                      );
                    }

                    return ListView.separated(
                      padding: const EdgeInsets.all(AppDesign.space4),
                      itemCount: vendorPayments.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: AppDesign.space3),
                      itemBuilder: (context, index) {
                        return _buildVendorPaymentCard(
                          context,
                          vendorPayments[index],
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVendorPaymentCard(BuildContext context, VendorPaymentInfo info) {
    return PremiumInfoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppDesign.space3),
                decoration: BoxDecoration(
                  color: AppDesign.primaryStart.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppDesign.radiusMd),
                ),
                child: Icon(
                  Icons.business,
                  color: AppDesign.primaryStart,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppDesign.space3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(info.vendor.name, style: AppDesign.titleMedium),
                        if (info.vendor.isPreferred) ...[
                          const SizedBox(width: AppDesign.space2),
                          Icon(Icons.star, size: 16, color: AppDesign.warning),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${info.vendor.contactPerson} • ${info.vendor.phoneNumber}',
                      style: AppDesign.bodySmall.copyWith(
                        color: AppDesign.neutral500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDesign.space4),
          Container(
            padding: const EdgeInsets.all(AppDesign.space4),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppDesign.error.withOpacity(0.1),
                  AppDesign.error.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(AppDesign.radiusMd),
              border: Border.all(color: AppDesign.error.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.currency_rupee, color: AppDesign.error, size: 32),
                const SizedBox(width: AppDesign.space2),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Outstanding',
                      style: AppDesign.labelSmall.copyWith(
                        color: AppDesign.error,
                      ),
                    ),
                    Text(
                      '₹${info.totalOutstanding.toStringAsFixed(2)}',
                      style: AppDesign.headlineMedium.copyWith(
                        color: AppDesign.error,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                StatusBadge.error(
                  label: '${info.purchaseOrders.length} POs',
                  showGlow: false,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDesign.space4),
          const Divider(),
          const SizedBox(height: AppDesign.space3),
          Row(
            children: [
              Text('Purchase Orders', style: AppDesign.titleSmall),
              const Spacer(),
              Text(
                info.vendor.paymentTerms.displayName,
                style: AppDesign.bodySmall.copyWith(
                  color: AppDesign.neutral500,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDesign.space3),
          ...info.purchaseOrders.take(3).map((po) {
            return Padding(
              padding: const EdgeInsets.only(bottom: AppDesign.space2),
              child: Row(
                children: [
                  Icon(Icons.receipt, size: 16, color: AppDesign.neutral500),
                  const SizedBox(width: AppDesign.space2),
                  Expanded(
                    child: Text(po.poNumber, style: AppDesign.bodySmall),
                  ),
                  Text(
                    '₹${po.total.toStringAsFixed(0)}',
                    style: AppDesign.bodySmall.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: AppDesign.space2),
                  _buildPOStatusBadge(po.status),
                ],
              ),
            );
          }),
          if (info.purchaseOrders.length > 3) ...[
            const SizedBox(height: AppDesign.space2),
            Text(
              '+${info.purchaseOrders.length - 3} more POs',
              style: AppDesign.bodySmall.copyWith(
                color: AppDesign.neutral500,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPOStatusBadge(POStatus status) {
    switch (status) {
      case POStatus.draft:
        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDesign.space2,
            vertical: 2,
          ),
          decoration: BoxDecoration(
            color: AppDesign.neutral200,
            borderRadius: BorderRadius.circular(AppDesign.radiusSm),
          ),
          child: Text(
            'Draft',
            style: AppDesign.labelSmall.copyWith(color: AppDesign.neutral600),
          ),
        );
      case POStatus.sent:
        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDesign.space2,
            vertical: 2,
          ),
          decoration: BoxDecoration(
            color: AppDesign.info.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppDesign.radiusSm),
          ),
          child: Text(
            'Sent',
            style: AppDesign.labelSmall.copyWith(color: AppDesign.info),
          ),
        );
      case POStatus.partial:
        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDesign.space2,
            vertical: 2,
          ),
          decoration: BoxDecoration(
            color: AppDesign.warning.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppDesign.radiusSm),
          ),
          child: Text(
            'Partial',
            style: AppDesign.labelSmall.copyWith(color: AppDesign.warning),
          ),
        );
      case POStatus.completed:
        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDesign.space2,
            vertical: 2,
          ),
          decoration: BoxDecoration(
            color: AppDesign.success.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppDesign.radiusSm),
          ),
          child: Text(
            'Done',
            style: AppDesign.labelSmall.copyWith(color: AppDesign.success),
          ),
        );
      case POStatus.cancelled:
        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDesign.space2,
            vertical: 2,
          ),
          decoration: BoxDecoration(
            color: AppDesign.error.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppDesign.radiusSm),
          ),
          child: Text(
            'Cancelled',
            style: AppDesign.labelSmall.copyWith(color: AppDesign.error),
          ),
        );
    }
  }
}

/// Helper class to group vendor with their payment info
class VendorPaymentInfo {
  final Vendor vendor;
  final List<PurchaseOrder> purchaseOrders;
  final double totalOutstanding;

  VendorPaymentInfo({
    required this.vendor,
    required this.purchaseOrders,
    required this.totalOutstanding,
  });
}
