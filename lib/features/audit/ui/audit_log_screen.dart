import 'package:flutter/material.dart';
import 'package:hotel_manager/core/models/audit_log.dart';
import 'package:hotel_manager/core/services/audit_service.dart';
import 'package:intl/intl.dart';

class AuditLogScreen extends StatefulWidget {
  const AuditLogScreen({super.key});

  static const String routeName = '/audit-logs';

  @override
  State<AuditLogScreen> createState() => _AuditLogScreenState();
}

class _AuditLogScreenState extends State<AuditLogScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Audit Logs')),
      body: Column(
        children: [
          // Search/Filter Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search logs...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              onChanged: (value) {
                setState(() => _searchQuery = value);
              },
            ),
          ),

          Expanded(
            child: StreamBuilder<List<AuditLog>>(
              stream: AuditService().streamAllLogs(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final logs = snapshot.data ?? [];
                final filteredLogs = logs
                    .where((log) {
                      final query = _searchQuery.toLowerCase();
                      return log.description.toLowerCase().contains(query) ||
                          log.userName.toLowerCase().contains(query) ||
                          log.entity.toLowerCase().contains(query);
                    })
                    .toList()
                    .reversed
                    .toList();

                if (filteredLogs.isEmpty) {
                  return const Center(child: Text('No logs found'));
                }

                return ListView.separated(
                  itemCount: filteredLogs.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final log = filteredLogs[index];
                    return ListTile(
                      leading: _buildActionIcon(log.action),
                      title: Text(log.description),
                      subtitle: Text(
                        '${DateFormat('MMM d, h:mm a').format(log.timestamp)} • ${log.userName} (${log.userRole})',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          log.entity.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
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

  Widget _buildActionIcon(AuditAction action) {
    IconData icon;
    Color color;

    switch (action) {
      case AuditAction.create:
        icon = Icons.add_circle_outline;
        color = Colors.green;
        break;
      case AuditAction.update:
        icon = Icons.edit;
        color = Colors.blue;
        break;
      case AuditAction.delete:
        icon = Icons.delete_outline;
        color = Colors.red;
        break;
      case AuditAction.login:
        icon = Icons.login;
        color = Colors.teal;
        break;
      case AuditAction.logout:
        icon = Icons.logout;
        color = Colors.grey;
        break;
      case AuditAction.checkIn:
        icon = Icons.person_add;
        color = Colors.purple;
        break;
      case AuditAction.checkOut:
        icon = Icons.person_remove;
        color = Colors.orange;
        break;
      case AuditAction.complete:
        icon = Icons.check_circle_outline;
        color = Colors.green;
        break;
      default:
        icon = Icons.info_outline;
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }
}
