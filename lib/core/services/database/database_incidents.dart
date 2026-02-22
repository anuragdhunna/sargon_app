part of '../database_service.dart';

extension DatabaseIncidents on DatabaseService {
  CollectionReference _incidentsRef(String hotelId) =>
      _hotelDoc(hotelId).collection('incidents');

  /// Stream all incidents (real-time)
  Stream<List<Incident>> streamIncidents(String hotelId) {
    return _incidentsRef(hotelId).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Incident.fromJson(data);
      }).toList();
    });
  }

  /// Save incident
  Future<void> saveIncident(Incident incident) async {
    await _incidentsRef(
      incident.hotelId,
    ).doc(incident.id).set(incident.toJson());
  }

  /// Update incident status
  Future<void> updateIncidentStatus(
    String hotelId,
    String id,
    String status,
  ) async {
    await _incidentsRef(hotelId).doc(id).update({
      'status': status,
      if (status == IncidentStatus.resolved.name)
        'resolvedAt': DateTime.now().toIso8601String(),
    });
  }
}
