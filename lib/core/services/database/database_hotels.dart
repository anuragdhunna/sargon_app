part of '../database_service.dart';

extension DatabaseHotels on DatabaseService {
  /// Stream all hotels
  Stream<List<Hotel>> streamAllHotels() {
    return firestore.collection('hotels').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Hotel.fromJson(doc.data());
      }).toList();
    });
  }

  /// Stream a specific hotel by ID
  Stream<Hotel?> streamHotel(String hotelId) {
    return firestore.collection('hotels').doc(hotelId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return Hotel.fromJson(doc.data()!);
    });
  }

  /// Get paginated hotels
  Future<List<Hotel>> getHotelsPaginated({
    int limit = 10,
    DocumentSnapshot? startAfter,
  }) async {
    Query query = firestore.collection('hotels').orderBy('name').limit(limit);
    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }
    final snapshot = await query.get();
    return snapshot.docs
        .map((doc) => Hotel.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  }

  /// Get a specific hotel by ID
  Future<Hotel?> getHotel(String hotelId) async {
    final doc = await firestore.collection('hotels').doc(hotelId).get();
    if (!doc.exists) return null;
    return Hotel.fromJson(doc.data()!);
  }

  /// Create or update a hotel
  Future<void> saveHotel(Hotel hotel) async {
    await firestore
        .collection('hotels')
        .doc(hotel.id)
        .set(hotel.toJson(), SetOptions(merge: true));
  }

  /// Assign an owner to a hotel
  Future<void> assignOwnerToHotel({
    required String hotelId,
    required String ownerId,
  }) async {
    await firestore.collection('hotels').doc(hotelId).update({
      'ownerIds': FieldValue.arrayUnion([ownerId]),
    });
  }

  /// Remove an owner from a hotel
  Future<void> removeOwnerFromHotel({
    required String hotelId,
    required String ownerId,
  }) async {
    await firestore.collection('hotels').doc(hotelId).update({
      'ownerIds': FieldValue.arrayRemove([ownerId]),
    });
  }

  /// Delete a hotel
  Future<void> deleteHotel(String hotelId) async {
    await firestore.collection('hotels').doc(hotelId).delete();
  }
}
