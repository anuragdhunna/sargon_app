import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../component/buttons/premium_button.dart';
import '../../../../component/cards/app_card.dart';
import '../../../../core/models/models.dart';
import '../../../../theme/app_design.dart';
import 'package:hotel_manager/core/utils/build_context_ext.dart';
import '../../logic/event_cubit.dart';
import '../widgets/event_incident_widget.dart';
import '../widgets/event_pricing_widget.dart';
import '../widgets/event_staff_assignment_widget.dart';
import '../widgets/event_vendor_po_widget.dart';

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
                EventStaffAssignmentWidget(event: currentEvent),
                const SizedBox(height: 24),
                EventPricingWidget(event: currentEvent),
                const SizedBox(height: 24),
                EventVendorPOWidget(event: currentEvent),
                const SizedBox(height: 24),
                EventIncidentWidget(event: currentEvent),
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
            'Date & Time',
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
              orElse: () => HallFeature(
                id: s.featureId,
                hotelId: context.hotelId,
                name: s.featureId,
                description: '',
                isActive: true,
              ),
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
