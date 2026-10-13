import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hotel_manager/component/cards/app_card.dart';
import 'package:hotel_manager/component/inputs/app_text_field.dart';
import 'package:hotel_manager/core/models/models.dart';
import 'package:hotel_manager/core/utils/build_context_ext.dart';
import 'package:hotel_manager/features/events/logic/event_cubit.dart';
import 'package:hotel_manager/theme/app_design.dart';
import 'package:intl/intl.dart';

/// Card widget to display and log operational incidents for a private event
class EventIncidentWidget extends StatelessWidget {
  final PrivateEvent event;

  const EventIncidentWidget({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EventCubit, EventState>(
      builder: (context, state) {
        final incidents = state.eventIncidents;
        return AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Incident Log',
                    style: AppDesign.titleMedium.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.report_problem_outlined),
                    onPressed: () => _showAddIncidentDialog(context, event),
                  ),
                ],
              ),
              const Divider(),
              if (incidents.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Center(child: Text('No incidents recorded.')),
                )
              else
                ...incidents.map((incident) {
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      incident.isResolved ? Icons.check_circle : Icons.warning,
                      color: incident.isResolved ? Colors.green : Colors.orange,
                    ),
                    title: Text(incident.title),
                    subtitle: Text(
                      '${DateFormat('HH:mm').format(incident.timestamp)} - ${incident.reportedBy}\n${incident.description}',
                    ),
                    trailing: incident.financialImpact > 0
                        ? Text(
                            '₹${incident.financialImpact.toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : null,
                  );
                }),
            ],
          ),
        );
      },
    );
  }

  void _showAddIncidentDialog(BuildContext context, PrivateEvent event) {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    final impactController = TextEditingController(text: '0');
    final reporterController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log New Incident'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppTextField(controller: titleController, label: 'Title'),
              const SizedBox(height: 12),
              AppTextField(
                controller: descController,
                label: 'Description',
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              AppTextField(
                controller: reporterController,
                label: 'Reported By',
              ),
              const SizedBox(height: 12),
              AppTextField(
                controller: impactController,
                label: 'Financial Impact (if any)',
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (titleController.text.isEmpty ||
                  reporterController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Title and reporter are required'),
                  ),
                );
                return;
              }

              final incident = EventIncident(
                id: context.read<EventCubit>().repository.nextId(
                  'event_incidents',
                  hotelId: context.hotelId,
                ),
                hotelId: context.hotelId,
                eventId: event.id,
                title: titleController.text,
                description: descController.text,
                timestamp: DateTime.now(),
                reportedBy: reporterController.text,
                financialImpact: double.tryParse(impactController.text) ?? 0.0,
              );

              context.read<EventCubit>().saveEventIncident(incident);
              Navigator.pop(context);
            },
            child: const Text('Report'),
          ),
        ],
      ),
    );
  }
}
