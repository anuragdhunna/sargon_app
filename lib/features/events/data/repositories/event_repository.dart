import '../../../../core/models/models.dart';
import '../../../../core/repositories/base_firestore_repository.dart';

class EventRepository extends BaseFirestoreRepository<PrivateEvent> {
  EventRepository({super.firestore, super.auth})
    : super(collectionPath: 'events');

  @override
  PrivateEvent fromJson(Map<String, dynamic> json) =>
      PrivateEvent.fromJson(json);

  // Halls (Moved to Firestore as well)
  Future<List<Hall>> fetchHalls(String hotelId) async {
    final query = firestore
        .collection('halls')
        .where('hotelId', isEqualTo: hotelId)
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
  Future<List<HallFeature>> fetchHallFeatures(String hotelId) async {
    final query = firestore
        .collection('hallFeatures')
        .where('hotelId', isEqualTo: hotelId)
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
  Stream<List<PrivateEvent>> streamEvents(String hotelId) =>
      streamAll(hotelId: hotelId);
  Future<List<PrivateEvent>> fetchEvents(String hotelId) =>
      getAll(hotelId: hotelId);
  Future<void> saveEvent(PrivateEvent event) => create(event);

  Future<void> updateEventStatus(String eventId, EventStatus status) async {
    await updateFields(eventId, {'status': status.name});
  }

  // Utility
  String nextId(String path, {String? hotelId}) =>
      firestore.collection(path).doc().id;

  // Backward compatibility for methods used in screens
  Stream<List<Hall>> streamHalls(String hotelId) {
    return firestore
        .collection('halls')
        .where('hotelId', isEqualTo: hotelId)
        .where('isDeleted', isEqualTo: false)
        .snapshots()
        .map((s) => s.docs.map((d) => Hall.fromJson(d.data())).toList());
  }

  Stream<List<HallFeature>> streamHallFeatures(String hotelId) {
    return firestore
        .collection('hallFeatures')
        .where('hotelId', isEqualTo: hotelId)
        .where('isDeleted', isEqualTo: false)
        .snapshots()
        .map((s) => s.docs.map((d) => HallFeature.fromJson(d.data())).toList());
  }

  // Missing methods to satisfy EventCubit
  Stream<List<User>> streamStaff(String hotelId) {
    return firestore
        .collection('users')
        .where('hotelId', isEqualTo: hotelId)
        .where('isDeleted', isEqualTo: false)
        .snapshots()
        .map((s) => s.docs.map((d) => User.fromJson(d.data())).toList());
  }

  Future<void> saveVendor(Vendor vendor) async {
    await firestore.collection('vendors').doc(vendor.id).set({
      ...vendor.toJson(),
      'hotelId': vendor.hotelId,
    });
  }

  Future<void> saveEventPO(EventPO po) async {
    await firestore.collection('event_pos').doc(po.id).set(po.toJson());
  }

  Stream<List<EventPO>> streamEventPOs(String eventId) => const Stream.empty();
  Stream<List<EventStaffAssignment>> streamStaffAssignments(String eventId) =>
      const Stream.empty();
  Future<void> saveStaffAssignment(EventStaffAssignment assignment) async {}
  Stream<List<TaxRule>> streamEventTaxRules(String hotelId) {
    return firestore
        .collection('event_tax_rules')
        .where('hotelId', isEqualTo: hotelId)
        .where('isDeleted', isEqualTo: false)
        .snapshots()
        .map((s) => s.docs.map((d) => TaxRule.fromJson(d.data())).toList());
  }

  Future<List<TaxRule>> fetchEventTaxRules(String hotelId) async {
    final query = firestore
        .collection('event_tax_rules')
        .where('hotelId', isEqualTo: hotelId)
        .where('isDeleted', isEqualTo: false);
    final snapshot = await query.get();
    return snapshot.docs.map((doc) => TaxRule.fromJson(doc.data())).toList();
  }

  Stream<List<EventIncident>> streamEventIncidents(String eventId) =>
      const Stream.empty();
  Future<void> saveEventIncident(EventIncident incident) async {}
  Future<List<EventIncident>> fetchEventIncidents(String eventId) async {
    final query = firestore
        .collection('event_incidents')
        .where('eventId', isEqualTo: eventId)
        .where('isDeleted', isEqualTo: false);
    final snapshot = await query.get();
    return snapshot.docs
        .map((doc) => EventIncident.fromJson(doc.data()))
        .toList();
  }

  Future<void> deleteHallFeature(String id) => delete(id);
  Stream<List<MenuItem>> streamMenuItems(String hotelId) {
    return firestore
        .collection('menu_items')
        .where('hotelId', isEqualTo: hotelId)
        .where('isDeleted', isEqualTo: false)
        .snapshots()
        .map((s) => s.docs.map((d) => MenuItem.fromJson(d.data())).toList());
  }

  Stream<List<Vendor>> streamVendors(String hotelId) {
    return firestore
        .collection('vendors')
        .where('hotelId', isEqualTo: hotelId)
        .where('isDeleted', isEqualTo: false)
        .snapshots()
        .map((s) => s.docs.map((d) => Vendor.fromJson(d.data())).toList());
  }
}
