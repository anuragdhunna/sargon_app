import 'package:hotel_manager/core/models/models.dart';
import 'package:hotel_manager/core/services/database_service.dart';
import 'package:firebase_database/firebase_database.dart';

/// Repository for Room and Booking operations.
///
/// This class follows the User Rule:
/// "Network calls always go through Repositories → Services → Data providers."
/// It acts as a bridge between the Cubit and the DatabaseService.
class RoomRepository {
  final DatabaseService _databaseService;

  RoomRepository({required DatabaseService databaseService})
    : _databaseService = databaseService;

  /// Stream all rooms from database
  Stream<List<Room>> streamRooms() => _databaseService.streamRooms();

  /// Stream all bookings from database
  Stream<List<Booking>> streamBookings() => _databaseService.streamBookings();

  /// Save a new booking
  Future<void> saveBooking(Booking booking) =>
      _databaseService.saveBooking(booking);

  /// Update room status
  Future<void> updateRoomStatus(String roomId, RoomStatus status) =>
      _databaseService.updateRoomStatus(roomId, status);

  /// Reference to bookings for check-in/out updates
  DatabaseReference get bookingsRef => _databaseService.bookingsRef;
}
