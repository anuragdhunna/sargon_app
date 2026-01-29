part of '../database_service.dart';

extension DatabaseRooms on DatabaseService {
  DatabaseReference get roomsRef => _ref('rooms');

  /// Stream all rooms (real-time)
  Stream<List<Room>> streamRooms() {
    return roomsRef.onValue.map((event) {
      try {
        if (event.snapshot.value == null) return <Room>[];
        final dynamic value = event.snapshot.value;
        Map<dynamic, dynamic> data;

        if (value is Map) {
          data = value;
        } else if (value is List) {
          data = value.asMap();
        } else {
          return <Room>[];
        }

        return data.entries
            .where((e) => e.value != null)
            .map((e) {
              try {
                final roomData = _toMap(e.value);
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

  /// Save room
  Future<void> saveRoom(Room room) async {
    await roomsRef.child(room.id).set(room.toJson());
  }

  /// Initialize dummy rooms if none exist
  Future<void> initializeDummyRooms() async {
    try {
      final snapshot = await roomsRef.get();
      if (snapshot.value != null) return;

      final rooms = [
        Room(
          id: 'room_101',
          roomNumber: '101',
          type: RoomType.deluxe,
          status: RoomStatus.available,
          floor: 1,
          pricePerNight: 2500,
          capacity: 2,
        ),
        Room(
          id: 'room_102',
          roomNumber: '102',
          type: RoomType.deluxe,
          status: RoomStatus.available,
          floor: 1,
          pricePerNight: 2500,
          capacity: 2,
        ),
        Room(
          id: 'room_201',
          roomNumber: '201',
          type: RoomType.suite,
          status: RoomStatus.available,
          floor: 2,
          pricePerNight: 5000,
          capacity: 4,
        ),
        Room(
          id: 'room_202',
          roomNumber: '202',
          type: RoomType.suite,
          status: RoomStatus.occupied,
          floor: 2,
          pricePerNight: 5000,
          capacity: 4,
        ),
        Room(
          id: 'room_301',
          roomNumber: '301',
          type: RoomType.single,
          status: RoomStatus.cleaning,
          floor: 3,
          pricePerNight: 1500,
          capacity: 2,
        ),
      ];

      for (final room in rooms) {
        await saveRoom(room);
      }
    } catch (e) {
      debugPrint('Error initializing dummy rooms: $e');
    }
  }

  /// Update room status
  Future<void> updateRoomStatus(String roomId, RoomStatus status) async {
    await roomsRef.child(roomId).update({'status': status.name});
  }

  // Bookings logic
  DatabaseReference get bookingsRef => _ref('bookings');

  /// Stream all bookings (real-time)
  Stream<List<Booking>> streamBookings() {
    return bookingsRef.onValue.map((event) {
      try {
        if (event.snapshot.value == null) return <Booking>[];
        final dynamic value = event.snapshot.value;
        Map<dynamic, dynamic> data;

        if (value is Map) {
          data = value;
        } else if (value is List) {
          data = value.asMap();
        } else {
          return <Booking>[];
        }

        return data.entries
            .where((e) => e.value != null)
            .map((e) {
              try {
                final bookingData = _toMap(e.value);
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
    await bookingsRef.child(booking.id).set(booking.toJson());
  }

  /// Get all bookings for a customer
  Future<List<Booking>> getBookingsByCustomerId(String customerId) async {
    final snapshot = await bookingsRef
        .orderByChild('customerId')
        .equalTo(customerId)
        .get();
    if (snapshot.value == null) return [];
    final data = _toMap(snapshot.value);
    return data.entries.map((e) => Booking.fromJson(_toMap(e.value))).toList();
  }

  /// Get booking by ID
  Future<Booking?> getBookingById(String bookingId) async {
    try {
      final snapshot = await bookingsRef.child(bookingId).get();
      if (snapshot.value == null) return null;
      final data = _toMap(snapshot.value);
      return Booking.fromJson(data);
    } catch (e) {
      debugPrint('Error getting booking by ID: $e');
      return null;
    }
  }
}
