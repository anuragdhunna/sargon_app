part of '../database_service.dart';

extension DatabaseIncidents on DatabaseService {
  DatabaseReference get incidentsRef => _ref('incidents');

  /// Stream all incidents (real-time)
  Stream<List<Incident>> streamIncidents() {
    return incidentsRef.onValue.map((event) {
      if (event.snapshot.value == null) return <Incident>[];
      final dynamic value = event.snapshot.value;
      if (value == null) return <Incident>[];
      final Map<dynamic, dynamic> data = (value is Map)
          ? value
          : (value is List ? value.asMap() : {});

      return data.entries.map((e) {
        final incidentData = _toMap(e.value);
        return Incident.fromJson(incidentData);
      }).toList();
    });
  }

  /// Save incident
  Future<void> saveIncident(Incident incident) async {
    await incidentsRef.child(incident.id).set(incident.toJson());
  }
}
