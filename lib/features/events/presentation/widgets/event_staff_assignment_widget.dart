import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hotel_manager/component/cards/app_card.dart';
import 'package:hotel_manager/core/models/models.dart';
import 'package:hotel_manager/core/utils/build_context_ext.dart';
import 'package:hotel_manager/features/events/logic/event_cubit.dart';
import 'package:hotel_manager/theme/app_design.dart';

/// Card widget to display and manage staff assignments for a private event
class EventStaffAssignmentWidget extends StatelessWidget {
  final PrivateEvent event;

  const EventStaffAssignmentWidget({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EventCubit, EventState>(
      builder: (context, state) {
        final assignments = state.assignments;
        return AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Staff Assignment',
                    style: AppDesign.titleMedium.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.person_add_outlined),
                    onPressed: () => _showStaffAssignmentDialog(context, event),
                  ),
                ],
              ),
              const Divider(),
              if (assignments.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text('No staff assigned yet.'),
                )
              else
                ...assignments.map((a) {
                  final manager = state.staff.firstWhere(
                    (s) => s.id == a.managerId,
                    orElse: () => User(
                      id: 'unknown',
                      hotelId: context.hotelId,
                      name: 'Unknown Manager',
                      email: '',
                      phoneNumber: '',
                      role: UserRole.manager,
                      status: UserStatus.active,
                      createdOn: DateTime.now(),
                    ),
                  );
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.badge_outlined),
                    title: Text('Manager: ${manager.name}'),
                    subtitle: Text('Staff: ${a.staffIds.length} members'),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit_outlined),
                      onPressed: () => _showStaffAssignmentDialog(
                        context,
                        event,
                        assignment: a,
                      ),
                    ),
                  );
                }),
            ],
          ),
        );
      },
    );
  }

  void _showStaffAssignmentDialog(
    BuildContext context,
    PrivateEvent event, {
    EventStaffAssignment? assignment,
  }) {
    String? selectedManagerId = assignment?.managerId;
    List<String> selectedStaffIds = List.from(assignment?.staffIds ?? []);

    showDialog(
      context: context,
      builder: (context) => BlocBuilder<EventCubit, EventState>(
        builder: (context, state) {
          final managers = state.staff
              .where(
                (s) => s.role == UserRole.manager || s.role == UserRole.owner,
              )
              .toList();
          final staffCandidates = state.staff
              .where((s) => s.role != UserRole.owner)
              .toList();

          return StatefulBuilder(
            builder: (context, setState) => AlertDialog(
              title: Text(
                assignment == null ? 'Assign Staff' : 'Edit Staff Assignment',
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DropdownButtonFormField<String>(
                        initialValue: selectedManagerId,
                        decoration: const InputDecoration(
                          labelText: 'Event Manager',
                        ),
                        items: managers
                            .map(
                              (m) => DropdownMenuItem(
                                value: m.id,
                                child: Text(m.name),
                              ),
                            )
                            .toList(),
                        onChanged: (val) =>
                            setState(() => selectedManagerId = val),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Service Staff',
                        style: AppDesign.bodyMedium.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (staffCandidates.isEmpty)
                        const Text('No staff available.'),
                      ...staffCandidates.map((s) {
                        return CheckboxListTile(
                          title: Text(s.name),
                          subtitle: Text(s.role.displayName),
                          value: selectedStaffIds.contains(s.id),
                          onChanged: (val) {
                            setState(() {
                              if (val == true) {
                                selectedStaffIds.add(s.id);
                              } else {
                                selectedStaffIds.remove(s.id);
                              }
                            });
                          },
                          contentPadding: EdgeInsets.zero,
                        );
                      }),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    if (selectedManagerId == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please select a manager'),
                        ),
                      );
                      return;
                    }

                    final newAssignment = EventStaffAssignment(
                      id: assignment?.id ??
                          context.read<EventCubit>().repository.nextId(
                            'event_staff',
                            hotelId: context.hotelId,
                          ),
                      hotelId: context.hotelId,
                      eventId: event.id,
                      managerId: selectedManagerId!,
                      staffIds: selectedStaffIds,
                    );

                    context.read<EventCubit>().saveStaffAssignment(
                      newAssignment,
                    );
                    Navigator.pop(context);
                  },
                  child: Text(assignment == null ? 'Assign' : 'Update'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
