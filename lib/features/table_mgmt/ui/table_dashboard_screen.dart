import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hotel_manager/features/orders/presentation/order_taking/ui/order_taking_screen.dart';
import '../../../core/models/models.dart';
import '../../../theme/app_design.dart';
import '../logic/table_cubit.dart';
import '../logic/table_state.dart';
import '../../orders/logic/order_cubit.dart';
import '../../../component/buttons/premium_button.dart';
import '../../checklists/ui/checklist_list_screen.dart';

class TableDashboardScreen extends StatelessWidget {
  const TableDashboardScreen({super.key});

  static const String routeName = '/tables';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppDesign.neutral50,
      appBar: AppBar(
        title: const Text('Table Management'),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: AppDesign.headlineSmall.copyWith(
          color: AppDesign.neutral900,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: const IconThemeData(color: AppDesign.neutral900),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline, color: AppDesign.primaryStart),
            onPressed: () => _showTablesGuide(context),
            tooltip: 'Floor Plan Guide',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: BlocBuilder<TableCubit, TableState>(
        builder: (context, tableState) {
          if (tableState is TableLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (tableState is TableError) {
            return Center(child: Text(tableState.message));
          }
          if (tableState is TableLoaded) {
            return BlocBuilder<OrderCubit, OrderState>(
              builder: (context, orderState) {
                final orders = orderState is OrderLoaded
                    ? orderState.orders
                    : <Order>[];

                return _TableDashboardContent(
                  tables: tableState.tables,
                  orders: orders,
                );
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  void _showTablesGuide(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Floor Plan Guide'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Table Statuses:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            _StatusGuideItem(
              color: Colors.green,
              label: 'Available',
              desc: 'Ready for seating.',
            ),
            _StatusGuideItem(
              color: Colors.red,
              label: 'Occupied',
              desc: 'Guests seated, ordering active.',
            ),
            _StatusGuideItem(
              color: Colors.orange,
              label: 'Billed',
              desc: 'Bill generated, payment pending.',
            ),
            _StatusGuideItem(
              color: Colors.blue,
              label: 'Cleaning',
              desc: 'Tables being prepared.',
            ),
            SizedBox(height: 16),
            Text('Quick Tips:', style: TextStyle(fontWeight: FontWeight.bold)),
            Text(
              '• Tap a table to open Order Taking.',
              style: TextStyle(height: 1.5),
            ),
            Text(
              '• Long Press for Manager Actions (Force Clear, etc.)',
              style: TextStyle(height: 1.5),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

class _StatusGuideItem extends StatelessWidget {
  final Color color;
  final String label;
  final String desc;

  const _StatusGuideItem({
    required this.color,
    required this.label,
    required this.desc,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
          Text(desc, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}

class _TableDashboardContent extends StatefulWidget {
  final List<TableEntity> tables;
  final List<Order> orders;

  const _TableDashboardContent({required this.tables, required this.orders});

  @override
  State<_TableDashboardContent> createState() => _TableDashboardContentState();
}

class _TableDashboardContentState extends State<_TableDashboardContent> {
  TableStatus? _selectedFilter;

  @override
  Widget build(BuildContext context) {
    final filteredTables = _selectedFilter == null
        ? widget.tables
        : widget.tables.where((t) => t.status == _selectedFilter).toList();

    return Column(
      children: [
        _buildFilterRow(),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final crossAxisCount = constraints.maxWidth > 1200
                  ? 6
                  : (constraints.maxWidth > 800 ? 4 : 2);

              if (filteredTables.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.table_restaurant_outlined,
                        size: 64,
                        color: AppDesign.neutral300,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No tables found for this filter',
                        style: AppDesign.titleMedium.copyWith(
                          color: AppDesign.neutral500,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.1,
                ),
                itemCount: filteredTables.length,
                itemBuilder: (context, index) {
                  final table = filteredTables[index];
                  final tableOrders = widget.orders
                      .where(
                        (o) =>
                            o.tableId == table.id &&
                            o.status != OrderStatus.cancelled,
                      )
                      .toList();
                  final activeOrder = tableOrders.isNotEmpty
                      ? tableOrders.first
                      : null;

                  return _TableTile(table: table, activeOrder: activeOrder);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFilterRow() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      color: Colors.white,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _FilterChip(
            label: 'All Tables',
            count: widget.tables.length,
            isSelected: _selectedFilter == null,
            onSelected: () => setState(() => _selectedFilter = null),
            color: AppDesign.neutral600,
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: 'Occupied',
            count: widget.tables
                .where((t) => t.status == TableStatus.occupied)
                .length,
            isSelected: _selectedFilter == TableStatus.occupied,
            onSelected: () =>
                setState(() => _selectedFilter = TableStatus.occupied),
            color: Colors.red,
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: 'Billed (Unpaid)',
            count: widget.tables
                .where((t) => t.status == TableStatus.billed)
                .length,
            isSelected: _selectedFilter == TableStatus.billed,
            onSelected: () =>
                setState(() => _selectedFilter = TableStatus.billed),
            color: Colors.orange,
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: 'Cleaning',
            count: widget.tables
                .where((t) => t.status == TableStatus.cleaning)
                .length,
            isSelected: _selectedFilter == TableStatus.cleaning,
            onSelected: () =>
                setState(() => _selectedFilter = TableStatus.cleaning),
            color: Colors.blue,
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: 'Available',
            count: widget.tables
                .where((t) => t.status == TableStatus.available)
                .length,
            isSelected: _selectedFilter == TableStatus.available,
            onSelected: () =>
                setState(() => _selectedFilter = TableStatus.available),
            color: Colors.green,
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final int count;
  final bool isSelected;
  final VoidCallback onSelected;
  final Color color;

  const _FilterChip({
    required this.label,
    required this.count,
    required this.isSelected,
    required this.onSelected,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: FilterChip(
        selected: isSelected,
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white : color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                count.toString(),
                style: AppDesign.bodySmall.copyWith(
                  color: isSelected ? color : color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        onSelected: (_) => onSelected(),
        selectedColor: color,
        checkmarkColor: Colors.white,
        labelStyle: AppDesign.bodyMedium.copyWith(
          color: isSelected ? Colors.white : AppDesign.neutral700,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: isSelected ? color : AppDesign.neutral300),
        ),
      ),
    );
  }
}

class _TableTile extends StatelessWidget {
  final TableEntity table;
  final Order? activeOrder;

  const _TableTile({required this.table, this.activeOrder});

  Color _getStatusColor() {
    switch (table.status) {
      case TableStatus.available:
        return Colors.green;
      case TableStatus.occupied:
        return Colors.red;
      case TableStatus.billed:
        return Colors.orange;
      case TableStatus.cleaning:
        return Colors.blue;
      case TableStatus.reserved:
        return Colors.purple;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor();
    final duration = activeOrder != null
        ? DateTime.now().difference(activeOrder!.timestamp)
        : null;
    final durationStr = duration != null ? '${duration.inMinutes}m' : '';

    return InkWell(
      onTap: () {
        context.go('${OrderTakingScreen.routeName}?tableId=${table.id}');
      },
      onLongPress: () {
        _showManagerActions(context);
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: statusColor.withOpacity(0.3), width: 2),
          boxShadow: [
            BoxShadow(
              color: statusColor.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Status Indicator (Top bar)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 4,
              child: Container(
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        table.tableCode,
                        style: AppDesign.titleLarge.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (duration != null)
                        Text(
                          durationStr,
                          style: AppDesign.bodySmall.copyWith(
                            color: AppDesign.neutral500,
                          ),
                        ),
                    ],
                  ),
                  const Spacer(),
                  if (activeOrder != null) ...[
                    Row(
                      children: [
                        const Icon(
                          Icons.people,
                          size: 14,
                          color: AppDesign.neutral500,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Pax: ${activeOrder!.paxCount}',
                          style: AppDesign.bodySmall,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '₹${activeOrder!.totalPrice.toStringAsFixed(0)}',
                      style: AppDesign.titleMedium.copyWith(
                        color: AppDesign.primaryStart,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ] else ...[
                    Text(
                      'Cap: ${table.minCapacity}-${table.maxCapacity}',
                      style: AppDesign.bodySmall.copyWith(
                        color: AppDesign.neutral400,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      table.status.displayName,
                      style: AppDesign.bodySmall.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (table.status == TableStatus.cleaning)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: PremiumButton.outline(
                          label: 'Checklist',
                          onPressed: () {
                            context.push(ChecklistListScreen.routeName);
                          },
                          isFullWidth: true,
                        ),
                      ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showManagerActions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Manage Table ${table.tableCode}',
                  style: AppDesign.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.check_circle, color: Colors.green),
                title: const Text('Force Available'),
                onTap: () {
                  context.read<TableCubit>().updateTableStatus(
                    table.id,
                    TableStatus.available,
                  );
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.cleaning_services,
                  color: Colors.blue,
                ),
                title: const Text('Mark Cleaning'),
                onTap: () {
                  context.read<TableCubit>().updateTableStatus(
                    table.id,
                    TableStatus.cleaning,
                  );
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.lock_clock, color: Colors.purple),
                title: const Text('Mark Reserved'),
                onTap: () {
                  context.read<TableCubit>().updateTableStatus(
                    table.id,
                    TableStatus.reserved,
                  );
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
