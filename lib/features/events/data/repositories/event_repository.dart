import '../../../../core/models/models.dart';
import '../../../../core/repositories/base_firestore_repository.dart';

class EventRepository extends BaseFirestoreRepository<PrivateEvent> {
  EventRepository({super.firestore, super.auth})
    : super(collectionPath: 'events');

  @override
  PrivateEvent fromJson(Map<String, dynamic> json) =>
      PrivateEvent.fromJson(json);

  // Halls (Moved to Firestore as well)
  Future<List<Hall>> fetchHalls() async {
    final query = firestore
        .collection('halls')
        .where('isDeleted', isEqualTo: false);
    final snapshot = await query.get();
    return snapshot.docs.map((doc) => Hall.fromJson(doc.data())).toList();
  }

  Future<void> saveHall(Hall hall) async {
    await firestore.collection('halls').doc(hall.id).set({
      ...hall.toJson(),
      '_userId': auth.currentUser?.uid,
    });
  }

  // Hall Features
  Future<List<HallFeature>> fetchHallFeatures() async {
    final query = firestore
        .collection('hallFeatures')
        .where('isDeleted', isEqualTo: false);
    final snapshot = await query.get();
    return snapshot.docs
        .map((doc) => HallFeature.fromJson(doc.data()))
        .toList();
  }

  Future<void> saveHallFeature(HallFeature feature) async {
    await firestore.collection('hallFeatures').doc(feature.id).set({
      ...feature.toJson(),
      '_userId': auth.currentUser?.uid,
    });
  }

  // Events
  Stream<List<PrivateEvent>> streamEvents() => streamAll();
  Future<List<PrivateEvent>> fetchEvents() => getAll();
  Future<void> saveEvent(PrivateEvent event) => create(event);

  Future<void> updateEventStatus(String eventId, EventStatus status) async {
    await updateFields(eventId, {'status': status.name});
  }

  // Utility
  String nextId(String path) => firestore.collection(path).doc().id;

  // Backward compatibility for methods used in screens
  Stream<List<Hall>> streamHalls() {
    return firestore
        .collection('halls')
        .where('isDeleted', isEqualTo: false)
        .snapshots()
        .map((s) => s.docs.map((d) => Hall.fromJson(d.data())).toList());
  }

  Stream<List<HallFeature>> streamHallFeatures() {
    return firestore
        .collection('hallFeatures')
        .where('isDeleted', isEqualTo: false)
        .snapshots()
        .map((s) => s.docs.map((d) => HallFeature.fromJson(d.data())).toList());
  }

  // Missing methods to satisfy EventCubit
  Stream<List<User>> streamStaff() => const Stream.empty();
  Future<void> saveVendor(Vendor vendor) async {}
  Future<void> saveEventPO(EventPO po) async {}
  Stream<List<EventPO>> streamEventPOs(String eventId) => const Stream.empty();
  Stream<List<EventStaffAssignment>> streamStaffAssignments(String eventId) =>
      const Stream.empty();
  Future<void> saveStaffAssignment(EventStaffAssignment assignment) async {}
  Stream<List<TaxRule>> streamEventTaxRules() => const Stream.empty();
  Future<List<TaxRule>> fetchEventTaxRules() async => [];
  Stream<List<EventIncident>> streamEventIncidents(String eventId) =>
      const Stream.empty();
  Future<void> saveEventIncident(EventIncident incident) async {}
  Future<List<EventIncident>> fetchEventIncidents(String eventId) async => [];
  Future<void> deleteHallFeature(String id) => delete(id);
  Stream<List<MenuItem>> streamMenuItems() => const Stream.empty();
  Stream<List<Vendor>> streamVendors() => const Stream.empty();
}
