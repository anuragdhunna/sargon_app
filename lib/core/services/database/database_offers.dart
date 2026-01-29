part of '../database_service.dart';

extension DatabaseOffers on DatabaseService {
  DatabaseReference get offersRef => _ref('offers');
  DatabaseReference get happyHoursRef => _ref('happyHours');

  /// Get all active offers (one-time fetch)
  Future<List<Offer>> getOffers() async {
    final snapshot = await offersRef.get();
    if (snapshot.value == null) return [];
    final data = _toMap(snapshot.value);
    return data.entries.map((e) => Offer.fromJson(_toMap(e.value))).toList();
  }

  /// Stream active offers
  Stream<List<Offer>> streamOffers() {
    return offersRef.onValue.map((event) {
      if (event.snapshot.value == null) return [];
      final data = _toMap(event.snapshot.value);
      return data.entries.map((e) => Offer.fromJson(_toMap(e.value))).toList();
    });
  }

  /// Save or Update an Offer
  Future<void> saveOffer(Offer offer) async {
    await offersRef.child(offer.id).set(offer.toJson());
  }

  /// Get all active happy hours (one-time fetch)
  Future<List<HappyHour>> getHappyHours() async {
    final snapshot = await happyHoursRef.get();
    if (snapshot.value == null) return [];
    final data = _toMap(snapshot.value);
    return data.entries
        .map((e) => HappyHour.fromJson(_toMap(e.value)))
        .toList();
  }

  /// Stream active happy hours
  Stream<List<HappyHour>> streamHappyHours() {
    return happyHoursRef.onValue.map((event) {
      if (event.snapshot.value == null) return [];
      final data = _toMap(event.snapshot.value);
      return data.entries
          .map((e) => HappyHour.fromJson(_toMap(e.value)))
          .toList();
    });
  }

  /// Save or Update a Happy Hour
  Future<void> saveHappyHour(HappyHour happyHour) async {
    await happyHoursRef.child(happyHour.id).set(happyHour.toJson());
  }
}
