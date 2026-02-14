import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../theme/app_design.dart';
import '../../../../component/cards/app_card.dart';
import '../../../../core/models/event_models.dart';
import '../../logic/event_cubit.dart';

class EventListScreen extends StatefulWidget {
  const EventListScreen({super.key});

  @override
  State<EventListScreen> createState() => _EventListScreenState();
}

class _EventListScreenState extends State<EventListScreen> {
  @override
  void initState() {
    super.initState();
    context.read<EventCubit>().streamEvents();
    context.read<EventCubit>().streamHalls();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppDesign.neutral50,
      appBar: AppBar(
        title: const Text('Event Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month),
            onPressed: () => context.push('/events/calendar'),
          ),
        ],
      ),
      body: BlocBuilder<EventCubit, EventState>(
        builder: (context, state) {
          if (state.status == EventStatusType.loading && state.events.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.events.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.event_available,
                    size: 64,
                    color: AppDesign.neutral300,
                  ),
                  const SizedBox(height: 16),
                  Text('No events scheduled', style: AppDesign.titleMedium),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => context.push('/events/create'),
                    child: const Text('Schedule first event'),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: state.events.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final event = state.events[index];
              return _EventCard(event: event, halls: state.halls);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/events/create'),
        backgroundColor: AppDesign.primaryStart,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('New Event', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}

class _EventCard extends StatelessWidget {
  final PrivateEvent event;
  final List<Hall> halls;

  const _EventCard({required this.event, required this.halls});

  @override
  Widget build(BuildContext context) {
    final eventHalls = halls
        .where((h) => event.hallIds.contains(h.id))
        .map((h) => h.name)
        .join(', ');

    return AppCard(
      child: InkWell(
        onTap: () => context.push('/events/details', extra: event),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    event.name,
                    style: AppDesign.titleLarge.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  _buildStatusChip(event.status),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.person_outline,
                    size: 16,
                    color: AppDesign.neutral600,
                  ),
                  const SizedBox(width: 4),
                  Text(event.guestName, style: AppDesign.bodyMedium),
                  const SizedBox(width: 16),
                  Icon(
                    Icons.group_outlined,
                    size: 16,
                    color: AppDesign.neutral600,
                  ),
                  const SizedBox(width: 4),
                  Text('${event.expectedPax} pax', style: AppDesign.bodyMedium),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: AppDesign.neutral600,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    DateFormat('MMM dd, yyyy').format(event.date),
                    style: AppDesign.bodyMedium,
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    Icons.access_time,
                    size: 16,
                    color: AppDesign.neutral600,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${event.startTime} - ${event.endTime}',
                    style: AppDesign.bodyMedium,
                  ),
                ],
              ),
              const Divider(height: 24),
              Row(
                children: [
                  Icon(Icons.business, size: 16, color: AppDesign.neutral600),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      eventHalls.isEmpty ? 'No halls assigned' : eventHalls,
                      style: AppDesign.bodyMedium,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(EventStatus status) {
    Color color;
    switch (status) {
      case EventStatus.draft:
        color = Colors.grey;
        break;
      case EventStatus.confirmed:
        color = Colors.blue;
        break;
      case EventStatus.live:
        color = Colors.green;
        break;
      case EventStatus.closed:
        color = Colors.orange;
        break;
      case EventStatus.billed:
        color = Colors.purple;
        break;
      case EventStatus.archived:
        color = Colors.blueGrey;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        status.name.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
