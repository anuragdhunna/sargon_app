import '../../../inventory_index.dart';

class POSelectionWidget extends StatelessWidget {
  final PurchaseOrder? selectedPO;
  final ValueChanged<PurchaseOrder?> onChanged;
  const POSelectionWidget({
    required this.selectedPO,
    required this.onChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Purchase Order',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        BlocBuilder<PurchaseOrderCubit, PurchaseOrderState>(
          builder: (context, state) {
            if (state is PurchaseOrderLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is PurchaseOrderLoaded) {
              final approvedPOs = state.orders
                  .where(
                    (po) =>
                        po.status == POStatus.sent ||
                        po.status == POStatus.partial,
                  )
                  .toList();

              if (approvedPOs.isEmpty) {
                return const Text('No pending purchase orders found.');
              }

              return DropdownButtonFormField<PurchaseOrder>(
                value: selectedPO,
                decoration: const InputDecoration(
                  labelText: 'Purchase Order',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.assignment),
                ),
                items: approvedPOs.map((po) {
                  return DropdownMenuItem(
                    value: po,
                    child: Text('${po.poNumber} - ${po.vendorName}'),
                  );
                }).toList(),
                onChanged: onChanged,
              );
            }

            return const Text('Failed to load purchase orders.');
          },
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}
