import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../theme/app_design.dart';
import '../../../../component/buttons/premium_button.dart';
import '../../../../component/cards/app_card.dart';
import '../../../../component/inputs/app_text_field.dart';
import '../../../../core/models/models.dart';
import '../../../../component/inputs/app_phone_field.dart';
import '../../logic/event_cubit.dart';

class EventDetailsScreen extends StatefulWidget {
  final PrivateEvent event;

  const EventDetailsScreen({super.key, required this.event});

  @override
  State<EventDetailsScreen> createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends State<EventDetailsScreen> {
  @override
  void initState() {
    super.initState();
    final cubit = context.read<EventCubit>();
    cubit.fetchEvents();
    cubit.fetchHalls();
    cubit.streamStaff();
    cubit.streamStaffAssignments(widget.event.id);
    cubit.streamEventPOs(widget.event.id);
    cubit.streamEventIncidents(widget.event.id);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EventCubit, EventState>(
      builder: (context, state) {
        final currentEvent = state.events.firstWhere(
          (e) => e.id == widget.event.id,
          orElse: () => widget.event,
        );
        final halls = state.halls
            .where((h) => currentEvent.hallIds.contains(h.id))
            .toList();

        return Scaffold(
          backgroundColor: AppDesign.neutral50,
          appBar: AppBar(
            title: Text(currentEvent.name),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () async {
                  await context.push('/events/create', extra: currentEvent);
                  if (context.mounted) {
                    context.read<EventCubit>().fetchEvents();
                  }
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStatusBanner(context, currentEvent),
                const SizedBox(height: 16),
                _buildInfoSection(currentEvent, halls, state),
                const SizedBox(height: 24),
                _buildStaffAssignmentSection(context, currentEvent),
                const SizedBox(height: 24),
                _buildPricingSection(context, currentEvent),
                const SizedBox(height: 24),
                _buildVendorPOSection(context, currentEvent),
                const SizedBox(height: 24),
                _buildIncidentSection(context, currentEvent),
                const SizedBox(height: 24),
                _buildActionButtons(context, currentEvent),
                const SizedBox(height: 48),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusBanner(BuildContext context, PrivateEvent event) {
    return AppCard(
      color: _getStatusColor(event.status).withValues(alpha: 0.05),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: _getStatusColor(event.status)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Event is currently in ${event.status.name.toUpperCase()} state',
                  style: AppDesign.titleSmall.copyWith(
                    fontWeight: FontWeight.bold,
                    color: _getStatusColor(event.status),
                  ),
                ),
                Text(
                  _getStatusDescription(event.status),
                  style: AppDesign.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(
    PrivateEvent event,
    List<Hall> halls,
    EventState state,
  ) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Event Information',
            style: AppDesign.titleMedium.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            Icons.person,
            'Contact',
            '${event.guestName} (${event.guestPhone})',
          ),
          const Divider(),
          _buildInfoRow(
            Icons.calendar_today,
            'Date',
            DateFormat('EEEE, MMM dd, yyyy').format(event.date),
          ),
          const Divider(),
          _buildInfoRow(
            Icons.access_time,
            'Time',
            '${event.startTime} - ${event.endTime}',
          ),
          const Divider(),
          _buildInfoRow(
            Icons.business,
            'Halls',
            halls.map((h) => h.name).join(', '),
          ),
          const Divider(),
          _buildInfoRow(Icons.group, 'Guests', '${event.expectedPax} pax'),
          const Divider(),
          _buildInfoRow(
            Icons.payments_outlined,
            'Pricing Model',
            event.pricing.category.name.toUpperCase(),
          ),
          if (event.notes != null) ...[
            const Divider(),
            _buildInfoRow(Icons.note, 'Notes', event.notes!),
          ],
          ...event.featureSelections.where((s) => s.isSelected).map((s) {
            final feature = state.hallFeatures.firstWhere(
              (f) => f.id == s.featureId,
              orElse: () => HallFeature(id: s.featureId, name: s.featureId),
            );
            return Column(
              children: [
                const Divider(),
                _buildInfoRow(
                  _getFeatureIcon(feature.id),
                  feature.name,
                  s.arrangement != null
                      ? 'Required (${s.arrangement})'
                      : 'Required',
                ),
                if (s.isSelected && s.arrangement == 'customer')
                  _buildWarningRow(
                    'Note: Reserve space for customer ${feature.name} equipment',
                  ),
              ],
            );
          }),
        ],
      ),
    );
  }

  IconData _getFeatureIcon(String featureId) {
    switch (featureId.toLowerCase()) {
      case 'dj':
        return Icons.music_note;
      case 'decoration':
        return Icons.auto_awesome;
      case 'stage':
        return Icons.layers;
      case 'lighting':
        return Icons.lightbulb;
      default:
        return Icons.star_outline;
    }
  }

  Widget _buildWarningRow(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 8, left: 32),
      child: Row(
        children: [
          const Icon(Icons.info_outline, size: 16, color: Colors.orange),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: AppDesign.bodySmall.copyWith(
                color: Colors.orange,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppDesign.neutral600),
          const SizedBox(width: 12),
          Text(
            label,
            style: AppDesign.bodyMedium.copyWith(color: AppDesign.neutral600),
          ),
          const Spacer(),
          Text(
            value,
            style: AppDesign.bodyLarge.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildStaffAssignmentSection(
    BuildContext context,
    PrivateEvent event,
  ) {
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
                      name: 'Unknown Manager',
                      phoneNumber: '',
                      role: UserRole.manager,
                      createdAt: DateTime.now(),
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
                      id:
                          assignment?.id ??
                          context.read<EventCubit>().repository.nextId(
                            'event_staff',
                          ),
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

  Widget _buildPricingSection(BuildContext context, PrivateEvent event) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pricing Details',
            style: AppDesign.titleMedium.copyWith(fontWeight: FontWeight.bold),
          ),
          Text(
            'Category: ${event.pricing.category.name.toUpperCase()}',
            style: AppDesign.bodySmall,
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            Icons.money,
            'Base Price',
            '₹ ${event.pricing.basePrice.toStringAsFixed(2)}',
          ),
          ...event.pricing.addOns.map(
            (addon) => _buildInfoRow(
              Icons.add,
              addon.name,
              '₹ ${addon.price.toStringAsFixed(2)}',
            ),
          ),
          const Divider(thickness: 2),
          _buildInfoRow(
            Icons.calculate,
            'Estimated Total',
            '₹ ${_calculateTotal(event).toStringAsFixed(2)}',
          ),
          const SizedBox(height: 12),
          PremiumButton.outline(
            label: 'Manage Items & Pricing',
            isFullWidth: true,
            onPressed: () => _showPricingDialog(context, event),
          ),
        ],
      ),
    );
  }

  void _showPricingDialog(BuildContext context, PrivateEvent event) {
    final basePriceController = TextEditingController(
      text: event.pricing.basePrice.toString(),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Manage Pricing'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppTextField(
                controller: basePriceController,
                label: 'Base Price',
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              // Addons list and add button could go here
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
              final newPricing = event.pricing.copyWith(
                basePrice:
                    double.tryParse(basePriceController.text) ??
                    event.pricing.basePrice,
              );
              final updatedEvent = event.copyWith(pricing: newPricing);
              context.read<EventCubit>().saveEvent(updatedEvent);
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Widget _buildVendorPOSection(BuildContext context, PrivateEvent event) {
    return BlocBuilder<EventCubit, EventState>(
      builder: (context, state) {
        final pos = state.eventPOs;
        return AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Vendor POs',
                    style: AppDesign.titleMedium.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline),
                    onPressed: () => _showAddPODialog(context, event),
                  ),
                ],
              ),
              const Divider(),
              if (pos.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Text('No POs created for this event.'),
                  ),
                )
              else
                ...pos.map((po) {
                  final vendor = state.vendors.firstWhere(
                    (v) => v.id == po.vendorId,
                    orElse: () => Vendor(
                      id: 'unknown',
                      name: 'Unknown Vendor',
                      category: VendorCategory.other,
                      contactPerson: '',
                      phoneNumber: '',
                      createdAt: DateTime.now(),
                    ),
                  );
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(po.description),
                    subtitle: Text('Vendor: ${vendor.name}'),
                    trailing: Text(
                      '₹${po.cost.toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  );
                }),
            ],
          ),
        );
      },
    );
  }

  void _showAddPODialog(BuildContext context, PrivateEvent event) {
    final descController = TextEditingController();
    final costController = TextEditingController();
    String? selectedVendorId;
    bool isPassedToCustomer = false;

    // Controllers for new vendor
    final newVendorNameController = TextEditingController();
    final newVendorPhoneController = TextEditingController();
    bool isAddingNewVendor = false;

    showDialog(
      context: context,
      builder: (context) => BlocBuilder<EventCubit, EventState>(
        builder: (context, state) => StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            title: const Text('New Vendor PO'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppTextField(
                    controller: descController,
                    label: 'Description',
                    hint: 'e.g., DJ Services',
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    controller: costController,
                    label: 'Cost',
                    hint: '0.0',
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  if (!isAddingNewVendor) ...[
                    DropdownButtonFormField<String>(
                      initialValue: selectedVendorId,
                      decoration: const InputDecoration(
                        labelText: 'Select Vendor',
                      ),
                      items: [
                        ...state.vendors.map(
                          (v) => DropdownMenuItem(
                            value: v.id,
                            child: Text(v.name),
                          ),
                        ),
                      ],
                      onChanged: (val) =>
                          setState(() => selectedVendorId = val),
                    ),
                    TextButton.icon(
                      onPressed: () => setState(() => isAddingNewVendor = true),
                      icon: const Icon(Icons.add),
                      label: const Text('Add New Vendor'),
                    ),
                  ] else ...[
                    const Divider(),
                    const Text(
                      'New Vendor Details',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    AppTextField(
                      controller: newVendorNameController,
                      label: 'Vendor Name',
                    ),
                    const SizedBox(height: 8),
                    AppPhoneField(
                      controller: newVendorPhoneController,
                      label: 'Phone Number',
                    ),
                    TextButton(
                      onPressed: () =>
                          setState(() => isAddingNewVendor = false),
                      child: const Text('Select Existing Vendor'),
                    ),
                  ],
                  const SizedBox(height: 8),
                  CheckboxListTile(
                    title: const Text('Pass cost to customer?'),
                    value: isPassedToCustomer,
                    onChanged: (val) =>
                        setState(() => isPassedToCustomer = val!),
                    contentPadding: EdgeInsets.zero,
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
                onPressed: () async {
                  String finalVendorId = selectedVendorId ?? '';

                  if (isAddingNewVendor) {
                    if (newVendorNameController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please enter vendor name'),
                        ),
                      );
                      return;
                    }
                    final newVendor = Vendor(
                      id: context.read<EventCubit>().repository.nextId(
                        'vendors',
                      ),
                      name: newVendorNameController.text,
                      category: VendorCategory.other,
                      contactPerson: 'Event Admin',
                      phoneNumber: newVendorPhoneController.text,
                      createdAt: DateTime.now(),
                    );
                    if (!context.mounted) return;
                    await context.read<EventCubit>().saveVendor(newVendor);
                    if (!mounted) return;
                    finalVendorId = newVendor.id;
                  }

                  if (finalVendorId.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please select or add a vendor'),
                      ),
                    );
                    return;
                  }

                  if (!context.mounted) return;
                  context.read<EventCubit>().saveEventPO(
                    EventPO(
                      id: context.read<EventCubit>().repository.nextId(
                        'event_pos',
                      ),
                      eventId: event.id,
                      vendorId: finalVendorId,
                      description: descController.text,
                      cost: double.tryParse(costController.text) ?? 0.0,
                      isPassedToCustomer: isPassedToCustomer,
                    ),
                  );
                  Navigator.pop(context);
                },
                child: const Text('Create'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, PrivateEvent event) {
    if (event.status == EventStatus.billed ||
        event.status == EventStatus.archived) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        if (event.status == EventStatus.draft)
          PremiumButton.primary(
            label: 'Confirm Event',
            isFullWidth: true,
            onPressed: () => context.read<EventCubit>().updateStatus(
              event.id,
              EventStatus.confirmed,
            ),
          ),
        if (event.status == EventStatus.confirmed)
          PremiumButton.primary(
            label: 'Mark as Live',
            isFullWidth: true,
            onPressed: () => context.read<EventCubit>().updateStatus(
              event.id,
              EventStatus.live,
            ),
          ),
        if (event.status == EventStatus.live)
          PremiumButton.primary(
            label: 'Close Event',
            isFullWidth: true,
            onPressed: () => context.read<EventCubit>().updateStatus(
              event.id,
              EventStatus.closed,
            ),
          ),
        if (event.status == EventStatus.closed)
          PremiumButton.primary(
            label: 'Generate Bill',
            isFullWidth: true,
            onPressed: () => context.push('/events/billing', extra: event),
          ),
      ],
    );
  }

  Widget _buildIncidentSection(BuildContext context, PrivateEvent event) {
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
                ),
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

  double _calculateTotal(PrivateEvent event) {
    double total = event.pricing.basePrice;
    for (var addon in event.pricing.addOns) {
      total += addon.price;
    }
    return total;
  }

  Color _getStatusColor(EventStatus status) {
    switch (status) {
      case EventStatus.draft:
        return Colors.grey;
      case EventStatus.confirmed:
        return Colors.blue;
      case EventStatus.live:
        return Colors.green;
      case EventStatus.closed:
        return Colors.orange;
      case EventStatus.billed:
        return Colors.purple;
      case EventStatus.archived:
        return Colors.blueGrey;
    }
  }

  String _getStatusDescription(EventStatus status) {
    switch (status) {
      case EventStatus.draft:
        return 'Initial inquiry. Halls are not locked.';
      case EventStatus.confirmed:
        return 'Booking confirmed. Halls are locked.';
      case EventStatus.live:
        return 'Event is currently in progress.';
      case EventStatus.closed:
        return 'Event completed. Ready for billing.';
      case EventStatus.billed:
        return 'Bill generated and settled.';
      case EventStatus.archived:
        return 'Archived for records.';
    }
  }
}
