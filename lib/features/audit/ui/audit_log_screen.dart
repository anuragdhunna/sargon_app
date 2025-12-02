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
  List<AuditLog> _logs = [];
  List<AuditLog> _filteredLogs = [];
  String _searchQuery = '';
  String? _selectedEntity;

  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

  void _loadLogs() {
    setState(() {
      _logs = AuditService().getAllLogs().reversed.toList(); // Newest first
      _filterLogs();
    });
  }

  void _filterLogs() {
    setState(() {
      _filteredLogs = _logs.where((log) {
        final matchesSearch = _searchQuery.isEmpty ||
            log.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            log.userName.toLowerCase().contains(_searchQuery.toLowerCase());
        
        final matchesEntity = _selectedEntity == null || log.entity == _selectedEntity;
        
        return matchesSearch && matchesEntity;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final entities = _logs.map((e) => e.entity).toSet().toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Audit Logs'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadLogs,
          ),
        ],
      ),
      body: Column(
        children: [
          // Filters
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: 'Search logs...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    onChanged: (value) {
                      _searchQuery = value;
                      _filterLogs();
                    },
                  ),
                ),
                const SizedBox(width: 16),
                DropdownButton<String>(
                  value: _selectedEntity,
                  hint: const Text('Entity'),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('All')),
                    ...entities.map((e) => DropdownMenuItem(value: e, child: Text(e.toUpperCase()))),
                  ],
                  onChanged: (value) {
                    _selectedEntity = value;
                    _filterLogs();
                  },
                ),
              ],
            ),
          ),
          
          // Logs List
          Expanded(
            child: _filteredLogs.isEmpty
                ? const Center(child: Text('No logs found'))
                : ListView.separated(
                    itemCount: _filteredLogs.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final log = _filteredLogs[index];
                      return ListTile(
                        leading: _buildActionIcon(log.action),
                        title: Text(log.description),
                        subtitle: Text(
                          '${DateFormat('MMM d, h:mm a').format(log.timestamp)} • ${log.userName} (${log.userRole})',
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                        ),
                        trailing: Chip(
                          label: Text(
                            log.entity.toUpperCase(),
                            style: const TextStyle(fontSize: 10),
                          ),
                          padding: EdgeInsets.zero,
                          visualDensity: VisualDensity.compact,
                        ),
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
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }
}
