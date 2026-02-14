import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../../theme/app_design.dart';
import '../../../../core/models/event_models.dart';
import '../../logic/event_cubit.dart';

class EventCalendarScreen extends StatefulWidget {
  const EventCalendarScreen({super.key});

  @override
  State<EventCalendarScreen> createState() => _EventCalendarScreenState();
}

class _EventCalendarScreenState extends State<EventCalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    final cubit = context.read<EventCubit>();
    cubit.fetchEvents();
    cubit.fetchHalls();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppDesign.neutral50,
      appBar: AppBar(title: const Text('Event Calendar')),
      body: BlocBuilder<EventCubit, EventState>(
        builder: (context, state) {
          final events = state.events;

          return Column(
            children: [
              TableCalendar(
                firstDay: DateTime.now().subtract(const Duration(days: 365)),
                lastDay: DateTime.now().add(const Duration(days: 365)),
                focusedDay: _focusedDay,
                calendarFormat: _calendarFormat,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                },
                onFormatChanged: (format) {
                  setState(() => _calendarFormat = format);
                },
                eventLoader: (day) {
                  return events.where((e) => isSameDay(e.date, day)).toList();
                },
                calendarStyle: const CalendarStyle(
                  todayDecoration: BoxDecoration(
                    color: AppDesign.primaryStart,
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: BoxDecoration(
                    color: AppDesign.primaryEnd,
                    shape: BoxShape.circle,
                  ),
                  markerDecoration: BoxDecoration(
                    color: AppDesign.primaryStart,
                    shape: BoxShape.circle,
                  ),
                ),
                calendarBuilders: CalendarBuilders(
                  markerBuilder: (context, date, events) {
                    if (events.isEmpty) return const SizedBox.shrink();
                    final dayEvents = events.cast<PrivateEvent>();
                    final occupiedHallIds = dayEvents
                        .expand((e) => e.hallIds)
                        .toSet();

                    return Positioned(
                      bottom: 4,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: state.halls.map((hall) {
                          final isOccupied = occupiedHallIds.contains(hall.id);
                          return Container(
                            width: 5,
                            height: 5,
                            margin: const EdgeInsets.symmetric(horizontal: 1),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isOccupied
                                  ? Colors.orange
                                  : Colors.grey.withValues(alpha: 0.3),
                            ),
                          );
                        }).toList(),
                      ),
                    );
                  },
                ),
              ),
              const Divider(),
              Expanded(
                child: _buildDayEventsList(
                  events.where((e) => isSameDay(e.date, _selectedDay)).toList(),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDayEventsList(List<PrivateEvent> dayEvents) {
    if (dayEvents.isEmpty) {
      return Center(
        child: Text(
          'No events for this day',
          style: AppDesign.bodyMedium.copyWith(color: AppDesign.neutral400),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: dayEvents.length,
      itemBuilder: (context, index) {
        final event = dayEvents[index];
        return Card(
          child: ListTile(
            title: Text(
              event.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              '${event.startTime} - ${event.endTime}\n${event.guestName}',
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              context.push('/events/details', extra: event);
            },
          ),
        );
      },
    );
  }
}
