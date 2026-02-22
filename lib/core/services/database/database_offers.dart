part of '../database_service.dart';

extension DatabaseOffers on DatabaseService {
  CollectionReference _offersRef(String hotelId) =>
      _hotelDoc(hotelId).collection('offers');
  CollectionReference _happyHoursRef(String hotelId) =>
      _hotelDoc(hotelId).collection('happy_hours');

  /// Get all active offers (one-time fetch)
  Future<List<Offer>> getOffers(String hotelId) async {
    final snapshot = await _offersRef(hotelId).get();
    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return Offer.fromJson(data);
    }).toList();
  }

  /// Stream active offers
  Stream<List<Offer>> streamOffers(String hotelId) {
    return _offersRef(hotelId).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Offer.fromJson(data);
      }).toList();
    });
  }

  /// Save or Update an Offer
  Future<void> saveOffer(Offer offer) async {
    await _offersRef(offer.hotelId).doc(offer.id).set(offer.toJson());
  }

  /// Get all active happy hours (one-time fetch)
  Future<List<HappyHour>> getHappyHours(String hotelId) async {
    final snapshot = await _happyHoursRef(hotelId).get();
    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return HappyHour.fromJson(data);
    }).toList();
  }

  /// Stream active happy hours
  Stream<List<HappyHour>> streamHappyHours(String hotelId) {
    return _happyHoursRef(hotelId).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return HappyHour.fromJson(data);
      }).toList();
    });
  }

  /// Save or Update a Happy Hour
  Future<void> saveHappyHour(HappyHour happyHour) async {
    await _happyHoursRef(
      happyHour.hotelId,
    ).doc(happyHour.id).set(happyHour.toJson());
  }
}
