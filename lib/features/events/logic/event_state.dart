part of 'event_cubit.dart';

enum EventStatusType { initial, loading, loaded, error }

class EventState extends Equatable {
  final List<Hall> halls;
  final List<PrivateEvent> events;
  final List<MenuItem> menuItems;
  final List<Vendor> vendors;
  final List<User> staff;
  final List<EventStaffAssignment> assignments;
  final List<EventPO> eventPOs;
  final List<TaxRule> eventTaxRules;
  final List<EventIncident> eventIncidents;
  final List<HallFeature> hallFeatures;
  final EventStatusType status;
  final String? message;

  const EventState({
    this.halls = const [],
    this.events = const [],
    this.menuItems = const [],
    this.vendors = const [],
    this.staff = const [],
    this.assignments = const [],
    this.eventPOs = const [],
    this.eventTaxRules = const [],
    this.eventIncidents = const [],
    this.hallFeatures = const [],
    this.status = EventStatusType.initial,
    this.message,
  });

  @override
  List<Object?> get props => [
    halls,
    events,
    menuItems,
    vendors,
    staff,
    assignments,
    eventPOs,
    eventTaxRules,
    eventIncidents,
    hallFeatures,
    status,
    message,
  ];

  EventState copyWith({
    List<Hall>? halls,
    List<PrivateEvent>? events,
    List<MenuItem>? menuItems,
    List<Vendor>? vendors,
    List<User>? staff,
    List<EventStaffAssignment>? assignments,
    List<EventPO>? eventPOs,
    List<TaxRule>? eventTaxRules,
    List<EventIncident>? eventIncidents,
    List<HallFeature>? hallFeatures,
    EventStatusType? status,
    String? message,
  }) {
    return EventState(
      halls: halls ?? this.halls,
      events: events ?? this.events,
      menuItems: menuItems ?? this.menuItems,
      vendors: vendors ?? this.vendors,
      staff: staff ?? this.staff,
      assignments: assignments ?? this.assignments,
      eventPOs: eventPOs ?? this.eventPOs,
      eventTaxRules: eventTaxRules ?? this.eventTaxRules,
      eventIncidents: eventIncidents ?? this.eventIncidents,
      hallFeatures: hallFeatures ?? this.hallFeatures,
      status: status ?? this.status,
      message: message ?? this.message,
    );
  }
}

class EventInitial extends EventState {
  const EventInitial() : super();
}
