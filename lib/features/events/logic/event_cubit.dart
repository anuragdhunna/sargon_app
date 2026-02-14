import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/models/models.dart';
import '../data/repositories/event_repository.dart';

part 'event_state.dart';

class EventCubit extends Cubit<EventState> {
  final EventRepository _repository;

  EventRepository get repository => _repository;

  EventCubit(this._repository) : super(const EventInitial());

  void streamHalls() {
    emit(state.copyWith(status: EventStatusType.loading));
    _repository.streamHalls().listen(
      (halls) =>
          emit(state.copyWith(halls: halls, status: EventStatusType.loaded)),
      onError: (e) => emit(
        state.copyWith(status: EventStatusType.error, message: e.toString()),
      ),
    );
  }

  void streamMenuItems() {
    _repository.streamMenuItems().listen(
      (items) => emit(state.copyWith(menuItems: items)),
    );
  }

  void streamVendors() {
    _repository.streamVendors().listen(
      (vendors) => emit(state.copyWith(vendors: vendors)),
    );
  }

  void streamStaff() {
    _repository.streamStaff().listen(
      (staff) => emit(state.copyWith(staff: staff)),
    );
  }

  Future<void> saveVendor(Vendor vendor) async {
    try {
      await _repository.saveVendor(vendor);
    } catch (e) {
      emit(
        state.copyWith(status: EventStatusType.error, message: e.toString()),
      );
    }
  }

  void streamEvents() {
    emit(state.copyWith(status: EventStatusType.loading));
    _repository.streamEvents().listen(
      (events) =>
          emit(state.copyWith(events: events, status: EventStatusType.loaded)),
      onError: (e) => emit(
        state.copyWith(status: EventStatusType.error, message: e.toString()),
      ),
    );
  }

  Future<void> saveHall(Hall hall) async {
    try {
      await _repository.saveHall(hall);
    } catch (e) {
      emit(
        state.copyWith(status: EventStatusType.error, message: e.toString()),
      );
    }
  }

  Future<void> saveEvent(PrivateEvent event) async {
    try {
      if (checkConflicts(event)) {
        emit(
          state.copyWith(
            status: EventStatusType.error,
            message: 'Hall already booked for this time.',
          ),
        );
        return;
      }
      await _repository.saveEvent(event);
    } catch (e) {
      emit(
        state.copyWith(status: EventStatusType.error, message: e.toString()),
      );
    }
  }

  bool checkConflicts(PrivateEvent newEvent) {
    for (var event in state.events) {
      if (event.id == newEvent.id) continue;
      if (event.status != EventStatus.confirmed &&
          event.status != EventStatus.live)
        continue;

      // Check date
      if (event.date.year == newEvent.date.year &&
          event.date.month == newEvent.date.month &&
          event.date.day == newEvent.date.day) {
        // Check hall overlap
        final hallOverlap = event.hallIds.any(
          (id) => newEvent.hallIds.contains(id),
        );
        if (hallOverlap) {
          // Check time overlap
          if (isTimeOverlap(
            event.startTime,
            event.endTime,
            newEvent.startTime,
            newEvent.endTime,
          )) {
            return true;
          }
        }
      }
    }
    return false;
  }

  bool isTimeOverlap(String start1, String end1, String start2, String end2) {
    final s1 = _timeToDouble(start1);
    final e1 = _timeToDouble(end1);
    final s2 = _timeToDouble(start2);
    final e2 = _timeToDouble(end2);
    return s1 < e2 && s2 < e1;
  }

  double _timeToDouble(String time) {
    final parts = time.split(':');
    return double.parse(parts[0]) + double.parse(parts[1]) / 60.0;
  }

  Future<void> updateStatus(String eventId, EventStatus status) async {
    try {
      await _repository.updateEventStatus(eventId, status);
    } catch (e) {
      emit(
        state.copyWith(status: EventStatusType.error, message: e.toString()),
      );
    }
  }

  Future<void> saveEventPO(EventPO po) async {
    try {
      await _repository.saveEventPO(po);
    } catch (e) {
      emit(
        state.copyWith(status: EventStatusType.error, message: e.toString()),
      );
    }
  }

  void streamEventPOs(String eventId) {
    _repository
        .streamEventPOs(eventId)
        .listen((pos) => emit(state.copyWith(eventPOs: pos)));
  }

  void streamStaffAssignments(String eventId) {
    _repository
        .streamStaffAssignments(eventId)
        .listen(
          (assignments) => emit(state.copyWith(assignments: assignments)),
        );
  }

  Future<void> saveStaffAssignment(EventStaffAssignment assignment) async {
    try {
      await _repository.saveStaffAssignment(assignment);
    } catch (e) {
      emit(
        state.copyWith(status: EventStatusType.error, message: e.toString()),
      );
    }
  }

  void streamEventTaxRules() {
    _repository.streamEventTaxRules().listen(
      (rules) => emit(state.copyWith(eventTaxRules: rules)),
    );
  }

  void streamEventIncidents(String eventId) {
    _repository
        .streamEventIncidents(eventId)
        .listen((incidents) => emit(state.copyWith(eventIncidents: incidents)));
  }

  Future<void> saveEventIncident(EventIncident incident) async {
    try {
      await _repository.saveEventIncident(incident);
    } catch (e) {
      emit(
        state.copyWith(status: EventStatusType.error, message: e.toString()),
      );
    }
  }

  Future<void> fetchEventIncidents(String eventId) async {
    try {
      final incidents = await _repository.fetchEventIncidents(eventId);
      emit(state.copyWith(eventIncidents: incidents));
    } catch (e) {
      // Log error
    }
  }

  // --- On-Demand Fetch Methods ---

  Future<void> fetchHalls() async {
    emit(state.copyWith(status: EventStatusType.loading));
    try {
      final halls = await _repository.fetchHalls();
      emit(state.copyWith(halls: halls, status: EventStatusType.loaded));
    } catch (e) {
      emit(
        state.copyWith(status: EventStatusType.error, message: e.toString()),
      );
    }
  }

  Future<void> fetchEvents() async {
    emit(state.copyWith(status: EventStatusType.loading));
    try {
      final events = await _repository.fetchEvents();
      emit(state.copyWith(events: events, status: EventStatusType.loaded));
    } catch (e) {
      emit(
        state.copyWith(status: EventStatusType.error, message: e.toString()),
      );
    }
  }

  Future<void> fetchEventTaxRules() async {
    try {
      final rules = await _repository.fetchEventTaxRules();
      emit(state.copyWith(eventTaxRules: rules));
    } catch (e) {
      // Quietly handle or log
    }
  }

  /// Returns a list of conflicts for a specific time and set of halls.
  /// Used for instant warnings in the UI.
  List<PrivateEvent> getConflictsForDate({
    required DateTime date,
    required String startTime,
    required String endTime,
    required List<String> hallIds,
    String? excludeEventId,
  }) {
    final conflicts = <PrivateEvent>[];
    for (var event in state.events) {
      if (event.id == excludeEventId) continue;
      // Only confirmed/live/billed events cause conflicts. Drafts do not lock halls.
      if (event.status == EventStatus.draft ||
          event.status == EventStatus.archived)
        continue;

      // Check date
      if (event.date.year == date.year &&
          event.date.month == date.month &&
          event.date.day == date.day) {
        // Check hall overlap
        final hallOverlap = event.hallIds.any((id) => hallIds.contains(id));
        if (hallOverlap) {
          // Check time overlap
          if (isTimeOverlap(
            event.startTime,
            event.endTime,
            startTime,
            endTime,
          )) {
            conflicts.add(event);
          }
        }
      }
    }
    return conflicts;
  }

  Future<void> saveEventAdvancePayment(String eventId, double amount) async {
    try {
      final event = state.events.firstWhere((e) => e.id == eventId);
      final updatedEvent = event.copyWith(advancePayment: amount);
      await _repository.saveEvent(updatedEvent);
      // Refresh events after save to reflect change
      await fetchEvents();
    } catch (e) {
      emit(
        state.copyWith(status: EventStatusType.error, message: e.toString()),
      );
    }
  }

  // Hall Features
  Future<void> fetchHallFeatures() async {
    emit(state.copyWith(status: EventStatusType.loading));
    try {
      final features = await _repository.fetchHallFeatures();
      emit(
        state.copyWith(hallFeatures: features, status: EventStatusType.loaded),
      );
    } catch (e) {
      emit(
        state.copyWith(status: EventStatusType.error, message: e.toString()),
      );
    }
  }

  void streamHallFeatures() {
    _repository.streamHallFeatures().listen(
      (features) => emit(state.copyWith(hallFeatures: features)),
    );
  }

  Future<void> saveHallFeature(HallFeature feature) async {
    try {
      await _repository.saveHallFeature(feature);
    } catch (e) {
      emit(
        state.copyWith(status: EventStatusType.error, message: e.toString()),
      );
    }
  }

  Future<void> deleteHallFeature(String id) async {
    try {
      await _repository.deleteHallFeature(id);
    } catch (e) {
      emit(
        state.copyWith(status: EventStatusType.error, message: e.toString()),
      );
    }
  }
}
