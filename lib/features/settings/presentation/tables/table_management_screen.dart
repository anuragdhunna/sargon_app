import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hotel_manager/core/models/models.dart';
import 'package:hotel_manager/features/settings/data/repositories/settings_repository.dart';
import 'package:hotel_manager/features/auth/logic/auth_cubit.dart';
import 'package:hotel_manager/features/auth/logic/auth_state.dart';
import 'package:hotel_manager/component/buttons/premium_button.dart';
import 'package:hotel_manager/theme/app_design.dart';
import 'package:hotel_manager/component/cards/app_card.dart';
import 'table_dialog.dart';

class TableManagementScreen extends StatelessWidget {
  const TableManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider.value(
      value: context.read<SettingsRepository>(),
      child: const _TableManagementContent(),
    );
  }
}

class _TableManagementContent extends StatelessWidget {
  const _TableManagementContent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppDesign.neutral50,
      appBar: AppBar(title: const Text('Table Management')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildHeader(context, 'Tables', () => _showAddTableDialog(context)),
            const SizedBox(height: 16),
            StreamBuilder<List<TableEntity>>(
              stream: context.read<SettingsRepository>().streamTables(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final tables = snapshot.data!;
                if (tables.isEmpty) {
                  return const Center(child: Text('No tables found.'));
                }

                // Sort by table code or name
                tables.sort((a, b) => a.tableCode.compareTo(b.tableCode));

                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: tables.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final table = tables[index];
                    return AppCard(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: _getStatusColor(
                            table.status,
                          ).withOpacity(0.2),
                          child: Text(
                            table.tableCode,
                            style: TextStyle(
                              color: _getStatusColor(table.status),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(
                          table.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          'Capacity: ${table.maxCapacity} • ${table.status.displayName}',
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, size: 20),
                              onPressed: () =>
                                  _showAddTableDialog(context, table),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.delete,
                                size: 20,
                                color: Colors.red,
                              ),
                              onPressed: () => _deleteTable(context, table),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(TableStatus status) {
    switch (status) {
      case TableStatus.available:
        return Colors.green;
      case TableStatus.occupied:
        return Colors.red;
      case TableStatus.reserved:
        return Colors.orange;
      case TableStatus.billed:
        return Colors.blue;
      case TableStatus.cleaning:
        return Colors.purple;
    }
  }

  Widget _buildHeader(BuildContext context, String title, VoidCallback onAdd) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: AppDesign.titleLarge),
        PremiumButton.primary(
          label: 'Add Table',
          icon: Icons.add,
          onPressed: onAdd,
        ),
      ],
    );
  }

  void _showAddTableDialog(BuildContext context, [TableEntity? table]) {
    showDialog(
      context: context,
      builder: (_) => RepositoryProvider.value(
        value: context.read<SettingsRepository>(),
        child: TableDialog(existingTable: table),
      ),
    );
  }

  Future<void> _deleteTable(BuildContext context, TableEntity table) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Table?'),
        content: Text('Are you sure you want to delete ${table.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      final authState = context.read<AuthCubit>().state;
      String userId = 'unknown';
      String userName = 'Unknown User';
      if (authState is AuthVerified) {
        userId = authState.userId;
        userName = authState.userName;
      }

      await context.read<SettingsRepository>().deleteTable(
        table.id,
        userId,
        userName,
      );
    }
  }
}
