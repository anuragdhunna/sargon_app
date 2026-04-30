import 'package:intl/intl.dart';
import '../../inventory_index.dart';

part 'po_detail_screen_methods.dart';

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

        final PurchaseOrder? po = context.read<PurchaseOrderCubit>().getPOById(
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
                    if (po.status == POStatus.pendingApproval)
                      PopupMenuItem(
                        value: 'approve',
                        child: Row(
                          children: [
                            Icon(
                              Icons.check_circle,
                              size: 20,
                              color: Colors.green,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Approve',
                              style: TextStyle(color: Colors.green),
                            ),
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
                    } else if (value == 'approve') {
                      _handleStatusUpdate(context, po, POStatus.sent);
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
}
