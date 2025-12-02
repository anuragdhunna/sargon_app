import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:hotel_manager/component/buttons/primary_button.dart';
import 'package:hotel_manager/component/inputs/custom_text_field.dart';
import 'package:hotel_manager/features/auth/logic/auth_cubit.dart';
import 'package:hotel_manager/features/auth/logic/auth_state.dart';
import 'package:hotel_manager/features/incidents/data/incident_model.dart';
import 'package:hotel_manager/features/incidents/logic/incident_cubit.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

class IncidentManagementScreen extends StatelessWidget {
  const IncidentManagementScreen({super.key});

  static const String routeName = '/issues';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Incident Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_comment),
            onPressed: () => _showReportDialog(context),
          ),
        ],
      ),
      body: BlocBuilder<IncidentCubit, IncidentState>(
        builder: (context, state) {
          if (state is IncidentLoaded) {
            if (state.incidents.isEmpty) {
              return const Center(
                child: Text('No incidents reported. Everything is smooth! 🌟'),
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: state.incidents.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final incident = state.incidents[index];
                return _IncidentCard(incident: incident);
              },
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  void _showReportDialog(BuildContext context) {
    final formKey = GlobalKey<FormBuilderState>();
    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(24),
          constraints: const BoxConstraints(maxWidth: 500),
          child: SingleChildScrollView(
            child: FormBuilder(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Report an Incident',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 24),
                  CustomTextField(
                    name: 'title',
                    label: 'Incident Title',
                    hint: 'e.g., WiFi not working',
                    validator: FormBuilderValidators.required(),
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    name: 'location',
                    label: 'Location',
                    hint: 'e.g., Room 101',
                    validator: FormBuilderValidators.required(),
                  ),
                  const SizedBox(height: 16),
                  FormBuilderDropdown<IncidentPriority>(
                    name: 'priority',
                    initialValue: IncidentPriority.medium,
                    decoration: const InputDecoration(
                      labelText: 'Priority',
                      border: OutlineInputBorder(),
                    ),
                    items: IncidentPriority.values
                        .map(
                          (p) => DropdownMenuItem(
                            value: p,
                            child: Text(p.name.toUpperCase()),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    name: 'description',
                    label: 'Description',
                    hint: 'Details...',
                    maxLines: 3,
                  ),
                  const SizedBox(height: 24),
                  PrimaryButton(
                    label: 'Submit Report',
                    onPressed: () {
                      if (formKey.currentState?.saveAndValidate() ?? false) {
                        final authState = context.read<AuthCubit>().state;
                        if (authState is! AuthVerified) return;

                        final data = formKey.currentState!.value;
                        final incident = Incident(
                          id: const Uuid().v4(),
                          title: data['title'],
                          description: data['description'] ?? '',
                          reportedBy: authState.userName,
                          timestamp: DateTime.now(),
                          priority: data['priority'],
                          status: IncidentStatus.open,
                          location: data['location'],
                        );
                        context.read<IncidentCubit>().reportIncident(
                          incident,
                          userId: authState.userId,
                          userName: authState.userName,
                          userRole: authState.role.name,
                        );
                        Navigator.pop(dialogContext);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Incident Reported')),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _IncidentCard extends StatelessWidget {
  final Incident incident;

  const _IncidentCard({required this.incident});

  @override
  Widget build(BuildContext context) {
    Color priorityColor;
    switch (incident.priority) {
      case IncidentPriority.low:
        priorityColor = Colors.green;
        break;
      case IncidentPriority.medium:
        priorityColor = Colors.orange;
        break;
      case IncidentPriority.high:
        priorityColor = Colors.red;
        break;
      case IncidentPriority.critical:
        priorityColor = Colors.purple;
        break;
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    incident.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: priorityColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    incident.priority.name.toUpperCase(),
                    style: TextStyle(
                      color: priorityColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              incident.description,
              style: TextStyle(color: Colors.grey.shade700),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.location_on, size: 14, color: Colors.grey.shade500),
                const SizedBox(width: 4),
                Text(
                  incident.location ?? 'Unknown',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
                const Spacer(),
                Text(
                  DateFormat('MMM d, h:mm a').format(incident.timestamp),
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                ),
              ],
            ),
            if (incident.status != IncidentStatus.resolved) ...[
              const Divider(height: 24),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    final authState = context.read<AuthCubit>().state;
                    if (authState is AuthVerified) {
                      context.read<IncidentCubit>().resolveIncident(
                        incident.id,
                        userId: authState.userId,
                        userName: authState.userName,
                        userRole: authState.role.name,
                      );
                    }
                  },
                  child: const Text('Mark Resolved'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
