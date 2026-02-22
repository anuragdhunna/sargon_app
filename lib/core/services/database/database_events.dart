part of '../database_service.dart';

extension DatabaseEvents on DatabaseService {
  CollectionReference _hallsRef(String hotelId) =>
      _hotelDoc(hotelId).collection('halls');
  CollectionReference _eventsRef(String hotelId) =>
      _hotelDoc(hotelId).collection('events');
  CollectionReference _eventPOsRef(String hotelId) =>
      _hotelDoc(hotelId).collection('event_pos');
  CollectionReference _eventStaffRef(String hotelId) =>
      _hotelDoc(hotelId).collection('event_staff');
  CollectionReference _eventTaxesRef(String hotelId) =>
      _hotelDoc(hotelId).collection('event_taxes');
  CollectionReference _eventIncidentsRef(String hotelId) =>
      _hotelDoc(hotelId).collection('event_incidents');
  CollectionReference _hallFeaturesRef(String hotelId) =>
      _hotelDoc(hotelId).collection('hall_features');

  /// Stream all incidents for an event
  Stream<List<EventIncident>> streamEventIncidents(
    String hotelId,
    String eventId,
  ) {
    return _eventIncidentsRef(
      hotelId,
    ).where('eventId', isEqualTo: eventId).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return EventIncident.fromJson(data);
      }).toList()..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    });
  }

  /// Save Event Incident
  Future<void> saveEventIncident(EventIncident incident) async {
    await _eventIncidentsRef(
      incident.hotelId,
    ).doc(incident.id).set(incident.toJson());
  }

  /// On-demand fetch incidents
  Future<List<EventIncident>> fetchEventIncidents(
    String hotelId,
    String eventId,
  ) async {
    final snapshot = await _eventIncidentsRef(
      hotelId,
    ).where('eventId', isEqualTo: eventId).get();
    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return EventIncident.fromJson(data);
    }).toList()..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  /// Stream all halls (real-time)
  Stream<List<Hall>> streamHalls(String hotelId) {
    return _hallsRef(hotelId).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Hall.fromJson(data);
      }).toList();
    });
  }

  /// Save hall
  Future<void> saveHall(Hall hall) async {
    await _hallsRef(hall.hotelId).doc(hall.id).set(hall.toJson());
  }

  /// Delete hall
  Future<void> deleteHall(String hotelId, String id) async {
    await _hallsRef(hotelId).doc(id).delete();
  }

  /// Stream all hall features
  Stream<List<HallFeature>> streamHallFeatures(String hotelId) {
    return _hallFeaturesRef(hotelId).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return HallFeature.fromJson(data);
      }).toList();
    });
  }

  /// Save hall feature
  Future<void> saveHallFeature(HallFeature feature) async {
    await _hallFeaturesRef(
      feature.hotelId,
    ).doc(feature.id).set(feature.toJson());
  }

  /// Delete hall feature
  Future<void> deleteHallFeature(String hotelId, String id) async {
    await _hallFeaturesRef(hotelId).doc(id).delete();
  }

  /// Stream all events (real-time)
  Stream<List<PrivateEvent>> streamEvents(String hotelId) {
    return _eventsRef(hotelId).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return PrivateEvent.fromJson(data);
      }).toList()..sort((a, b) => b.date.compareTo(a.date));
    });
  }

  /// Save event
  Future<void> saveEvent(PrivateEvent event) async {
    await _eventsRef(event.hotelId).doc(event.id).set(event.toJson());
  }

  /// Update event status
  Future<void> updateEventStatus(
    String hotelId,
    String eventId,
    EventStatus status,
  ) async {
    await _eventsRef(hotelId).doc(eventId).update({
      'status': status.name,
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  /// Stream POs for an event (real-time)
  Stream<List<EventPO>> streamEventPOs(String hotelId, String eventId) {
    return _eventPOsRef(
      hotelId,
    ).where('eventId', isEqualTo: eventId).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return EventPO.fromJson(data);
      }).toList();
    });
  }

  /// Save Event PO
  Future<void> saveEventPO(EventPO po) async {
    await _eventPOsRef(po.hotelId).doc(po.id).set(po.toJson());
  }

  /// Delete Event PO
  Future<void> deleteEventPO(String hotelId, String poId) async {
    await _eventPOsRef(hotelId).doc(poId).delete();
  }

  /// Stream Staff Assignments for an event
  Stream<List<EventStaffAssignment>> streamStaffAssignments(
    String hotelId,
    String eventId,
  ) {
    return _eventStaffRef(
      hotelId,
    ).where('eventId', isEqualTo: eventId).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return EventStaffAssignment.fromJson(data);
      }).toList();
    });
  }

  /// Save Staff Assignment
  Future<void> saveStaffAssignment(EventStaffAssignment assignment) async {
    await _eventStaffRef(
      assignment.hotelId,
    ).doc(assignment.id).set(assignment.toJson());
  }

  /// Stream Event Tax Rules
  Stream<List<TaxRule>> streamEventTaxRules(String hotelId) {
    return _eventTaxesRef(hotelId).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return TaxRule.fromJson(data);
      }).toList();
    });
  }

  /// On-demand fetch all halls
  Future<List<Hall>> fetchHalls(String hotelId) async {
    final snapshot = await _hallsRef(hotelId).get();
    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return Hall.fromJson(data);
    }).toList();
  }

  /// On-demand fetch all events
  Future<List<PrivateEvent>> fetchEvents(String hotelId) async {
    final snapshot = await _eventsRef(hotelId).get();
    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return PrivateEvent.fromJson(data);
    }).toList()..sort((a, b) => b.date.compareTo(a.date));
  }

  /// On-demand fetch POs for an event
  Future<List<EventPO>> fetchEventPOs(String hotelId, String eventId) async {
    final snapshot = await _eventPOsRef(
      hotelId,
    ).where('eventId', isEqualTo: eventId).get();
    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return EventPO.fromJson(data);
    }).toList();
  }

  /// On-demand fetch event taxes
  Future<List<TaxRule>> fetchEventTaxRules(String hotelId) async {
    final snapshot = await _eventTaxesRef(hotelId).get();
    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return TaxRule.fromJson(data);
    }).toList();
  }
}
