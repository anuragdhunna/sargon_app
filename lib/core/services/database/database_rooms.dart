part of '../database_service.dart';

extension DatabaseRooms on DatabaseService {
  CollectionReference _roomsRef(String hotelId) =>
      _hotelDoc(hotelId).collection('rooms');

  /// Stream all rooms (real-time)
  Stream<List<Room>> streamRooms(String hotelId) {
    return _roomsRef(hotelId).snapshots().map((snapshot) {
      try {
        return snapshot.docs
            .map((doc) {
              try {
                final roomData = doc.data() as Map<String, dynamic>;
                return Room.fromJson(roomData);
              } catch (e) {
                debugPrint('Error parsing room: $e');
                return null;
              }
            })
            .whereType<Room>()
            .toList();
      } catch (e) {
        debugPrint('Error in streamRooms: $e');
        return <Room>[];
      }
    });
  }

  /// Get rooms (one-time fetch)
  Future<List<Room>> getRooms(String hotelId) async {
    final snapshot = await _roomsRef(hotelId).get();
    return snapshot.docs
        .map((doc) {
          try {
            final data = doc.data() as Map<String, dynamic>;
            return Room.fromJson(data);
          } catch (e) {
            debugPrint('Error parsing room: $e');
            return null;
          }
        })
        .whereType<Room>()
        .toList();
  }

  /// Save room
  Future<void> saveRoom(Room room) async {
    await _roomsRef(room.hotelId).doc(room.id).set(room.toJson());
  }

  /// Update room status
  Future<void> updateRoomStatus(
    String hotelId,
    String roomId,
    RoomStatus status,
  ) async {
    await _roomsRef(hotelId).doc(roomId).update({'status': status.name});
  }

  // Bookings logic
  CollectionReference _bookingsRef(String hotelId) =>
      _hotelDoc(hotelId).collection('bookings');

  /// Stream all bookings (real-time)
  Stream<List<Booking>> streamBookings(String hotelId) {
    return _bookingsRef(hotelId).snapshots().map((snapshot) {
      try {
        return snapshot.docs
            .map((doc) {
              try {
                final bookingData = doc.data() as Map<String, dynamic>;
                return Booking.fromJson(bookingData);
              } catch (e) {
                debugPrint('Error parsing booking: $e');
                return null;
              }
            })
            .whereType<Booking>()
            .toList();
      } catch (e) {
        debugPrint('Error in streamBookings: $e');
        return <Booking>[];
      }
    });
  }

  /// Save booking
  Future<void> saveBooking(Booking booking) async {
    await _bookingsRef(booking.hotelId).doc(booking.id).set(booking.toJson());
  }

  /// Get all bookings for a customer
  Future<List<Booking>> getBookingsByCustomerId(
    String hotelId,
    String customerId,
  ) async {
    final snapshot = await _bookingsRef(
      hotelId,
    ).where('customerId', isEqualTo: customerId).get();
    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return Booking.fromJson(data);
    }).toList();
  }

  /// Get booking by ID
  Future<Booking?> getBookingById(String hotelId, String bookingId) async {
    try {
      final doc = await _bookingsRef(hotelId).doc(bookingId).get();
      if (!doc.exists) return null;
      return Booking.fromJson(doc.data() as Map<String, dynamic>);
    } catch (e) {
      debugPrint('Error getting booking by ID: $e');
      return null;
    }
  }
}
