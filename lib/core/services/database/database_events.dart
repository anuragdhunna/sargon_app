part of '../database_service.dart';

extension DatabaseEvents on DatabaseService {
  DatabaseReference get hallsRef => _ref('halls');
  DatabaseReference get eventsRef => _ref('events');
  DatabaseReference get eventPOsRef => _ref('event_pos');
  DatabaseReference get eventStaffRef => _ref('event_staff');
  DatabaseReference get eventTaxesRef => _ref('event_taxes');
  DatabaseReference get eventIncidentsRef => _ref('event_incidents');
  DatabaseReference get hallFeaturesRef => _ref('hall_features');

  /// Stream all incidents for an event
  Stream<List<EventIncident>> streamEventIncidents(String eventId) {
    return eventIncidentsRef.child(eventId).onValue.map((event) {
      try {
        if (event.snapshot.value == null) return <EventIncident>[];
        final Map<dynamic, dynamic> data = _toMap(event.snapshot.value);
        return data.entries
            .map((e) {
              try {
                return EventIncident.fromJson(_toMap(e.value));
              } catch (e) {
                return null;
              }
            })
            .whereType<EventIncident>()
            .toList()
          ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
      } catch (e) {
        return <EventIncident>[];
      }
    });
  }

  /// Save Event Incident
  Future<void> saveEventIncident(EventIncident incident) async {
    await eventIncidentsRef
        .child(incident.eventId)
        .child(incident.id)
        .set(incident.toJson());
  }

  /// On-demand fetch incidents
  Future<List<EventIncident>> fetchEventIncidents(String eventId) async {
    final snapshot = await eventIncidentsRef.child(eventId).get();
    if (!snapshot.exists || snapshot.value == null) return [];
    final Map<dynamic, dynamic> data = _toMap(snapshot.value);
    return data.entries
        .map((e) {
          try {
            return EventIncident.fromJson(_toMap(e.value));
          } catch (e) {
            return null;
          }
        })
        .whereType<EventIncident>()
        .toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  /// Stream all halls (real-time)
  Stream<List<Hall>> streamHalls() {
    return hallsRef.onValue.map((event) {
      try {
        if (event.snapshot.value == null) return <Hall>[];
        final dynamic value = event.snapshot.value;
        Map<dynamic, dynamic> data;

        if (value is Map) {
          data = value;
        } else if (value is List) {
          data = value.asMap();
        } else {
          return <Hall>[];
        }

        return data.entries
            .where((e) => e.value != null)
            .map((e) {
              try {
                final hallData = _toMap(e.value);
                return Hall.fromJson(hallData);
              } catch (e) {
                debugPrint('Error parsing hall: $e');
                return null;
              }
            })
            .whereType<Hall>()
            .toList();
      } catch (e) {
        debugPrint('Error in streamHalls: $e');
        return <Hall>[];
      }
    });
  }

  /// Save hall
  Future<void> saveHall(Hall hall) async {
    await hallsRef.child(hall.id).set(hall.toJson());
  }

  /// Delete hall
  Future<void> deleteHall(String id) async {
    await hallsRef.child(id).remove();
  }

  /// Stream all hall features
  Stream<List<HallFeature>> streamHallFeatures() {
    return hallFeaturesRef.onValue.map((event) {
      if (event.snapshot.value == null) return <HallFeature>[];
      final dynamic value = event.snapshot.value;
      Map<dynamic, dynamic> data;

      if (value is Map) {
        data = value;
      } else if (value is List) {
        data = value.asMap();
      } else {
        return <HallFeature>[];
      }

      return data.entries
          .where((e) => e.value != null)
          .map((e) {
            try {
              final featureData = _toMap(e.value);
              return HallFeature.fromJson(featureData);
            } catch (e) {
              debugPrint('Error parsing hall feature: $e');
              return null;
            }
          })
          .whereType<HallFeature>()
          .toList();
    });
  }

  /// Save hall feature
  Future<void> saveHallFeature(HallFeature feature) async {
    await hallFeaturesRef.child(feature.id).set(feature.toJson());
  }

  /// Delete hall feature
  Future<void> deleteHallFeature(String id) async {
    await hallFeaturesRef.child(id).remove();
  }

  /// Stream all events (real-time)
  Stream<List<PrivateEvent>> streamEvents() {
    return eventsRef.onValue.map((event) {
      try {
        if (event.snapshot.value == null) return <PrivateEvent>[];
        final dynamic value = event.snapshot.value;
        Map<dynamic, dynamic> data;

        if (value is Map) {
          data = value;
        } else if (value is List) {
          data = value.asMap();
        } else {
          return <PrivateEvent>[];
        }

        return data.entries
            .where((e) => e.value != null)
            .map((e) {
              try {
                final eventData = _toMap(e.value);
                return PrivateEvent.fromJson(eventData);
              } catch (e) {
                debugPrint('Error parsing event: $e');
                return null;
              }
            })
            .whereType<PrivateEvent>()
            .toList()
          ..sort((a, b) => b.date.compareTo(a.date));
      } catch (e) {
        debugPrint('Error in streamEvents: $e');
        return <PrivateEvent>[];
      }
    });
  }

  /// Save event
  Future<void> saveEvent(PrivateEvent event) async {
    await eventsRef.child(event.id).set(event.toJson());
  }

  /// Update event status
  Future<void> updateEventStatus(String eventId, EventStatus status) async {
    await eventsRef.child(eventId).update({
      'status': status.name,
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  /// Stream POs for an event (real-time)
  Stream<List<EventPO>> streamEventPOs(String eventId) {
    return eventPOsRef.child(eventId).onValue.map((event) {
      try {
        if (event.snapshot.value == null) return <EventPO>[];
        final dynamic value = event.snapshot.value;
        Map<dynamic, dynamic> data;

        if (value is Map) {
          data = value;
        } else if (value is List) {
          data = value.asMap();
        } else {
          return <EventPO>[];
        }

        return data.entries
            .where((e) => e.value != null)
            .map((e) {
              try {
                final poData = _toMap(e.value);
                return EventPO.fromJson(poData);
              } catch (e) {
                debugPrint('Error parsing event PO: $e');
                return null;
              }
            })
            .whereType<EventPO>()
            .toList();
      } catch (e) {
        debugPrint('Error in streamEventPOs: $e');
        return <EventPO>[];
      }
    });
  }

  /// Save Event PO
  Future<void> saveEventPO(EventPO po) async {
    await eventPOsRef.child(po.eventId).child(po.id).set(po.toJson());
  }

  /// Delete Event PO
  Future<void> deleteEventPO(String eventId, String poId) async {
    await eventPOsRef.child(eventId).child(poId).remove();
  }

  /// Stream Staff Assignments for an event
  Stream<List<EventStaffAssignment>> streamStaffAssignments(String eventId) {
    return eventStaffRef.child(eventId).onValue.map((event) {
      try {
        if (event.snapshot.value == null) return <EventStaffAssignment>[];
        final dynamic value = event.snapshot.value;
        Map<dynamic, dynamic> data;

        if (value is Map) {
          data = value;
        } else if (value is List) {
          data = value.asMap();
        } else {
          return <EventStaffAssignment>[];
        }

        return data.entries
            .where((e) => e.value != null)
            .map((e) {
              try {
                final assignmentData = _toMap(e.value);
                return EventStaffAssignment.fromJson(assignmentData);
              } catch (e) {
                debugPrint('Error parsing staff assignment: $e');
                return null;
              }
            })
            .whereType<EventStaffAssignment>()
            .toList();
      } catch (e) {
        debugPrint('Error in streamStaffAssignments: $e');
        return <EventStaffAssignment>[];
      }
    });
  }

  /// Save Staff Assignment
  Future<void> saveStaffAssignment(EventStaffAssignment assignment) async {
    await eventStaffRef
        .child(assignment.eventId)
        .child(assignment.id)
        .set(assignment.toJson());
  }

  /// Stream Event Tax Rules
  Stream<List<TaxRule>> streamEventTaxRules() {
    return eventTaxesRef.onValue.map((event) {
      try {
        if (event.snapshot.value == null) return <TaxRule>[];
        final dynamic value = event.snapshot.value;
        Map<dynamic, dynamic> data;

        if (value is Map) {
          data = value;
        } else if (value is List) {
          data = value.asMap();
        } else {
          return <TaxRule>[];
        }

        return data.entries
            .where((e) => e.value != null)
            .map((e) {
              try {
                final taxData = _toMap(e.value);
                return TaxRule.fromJson(taxData);
              } catch (e) {
                debugPrint('Error parsing event tax rule: $e');
                return null;
              }
            })
            .whereType<TaxRule>()
            .toList();
      } catch (e) {
        debugPrint('Error in streamEventTaxRules: $e');
        return <TaxRule>[];
      }
    });
  }

  /// On-demand fetch all halls
  Future<List<Hall>> fetchHalls() async {
    final snapshot = await hallsRef.get();
    if (!snapshot.exists || snapshot.value == null) return [];
    final Map<dynamic, dynamic> data = _toMap(snapshot.value);
    return data.entries
        .map((e) {
          try {
            return Hall.fromJson(_toMap(e.value));
          } catch (e) {
            return null;
          }
        })
        .whereType<Hall>()
        .toList();
  }

  /// On-demand fetch all events
  Future<List<PrivateEvent>> fetchEvents() async {
    final snapshot = await eventsRef.get();
    if (!snapshot.exists || snapshot.value == null) return [];
    final Map<dynamic, dynamic> data = _toMap(snapshot.value);
    return data.entries
        .map((e) {
          try {
            return PrivateEvent.fromJson(_toMap(e.value));
          } catch (e) {
            return null;
          }
        })
        .whereType<PrivateEvent>()
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  /// On-demand fetch POs for an event
  Future<List<EventPO>> fetchEventPOs(String eventId) async {
    final snapshot = await eventPOsRef.child(eventId).get();
    if (!snapshot.exists || snapshot.value == null) return [];
    final Map<dynamic, dynamic> data = _toMap(snapshot.value);
    return data.entries
        .map((e) {
          try {
            return EventPO.fromJson(_toMap(e.value));
          } catch (e) {
            return null;
          }
        })
        .whereType<EventPO>()
        .toList();
  }

  /// On-demand fetch event taxes
  Future<List<TaxRule>> fetchEventTaxRules() async {
    final snapshot = await eventTaxesRef.get();
    if (!snapshot.exists || snapshot.value == null) return [];
    final Map<dynamic, dynamic> data = _toMap(snapshot.value);
    return data.entries
        .map((e) {
          try {
            return TaxRule.fromJson(_toMap(e.value));
          } catch (e) {
            return null;
          }
        })
        .whereType<TaxRule>()
        .toList();
  }
}
