import 'package:hotel_manager/core/models/models.dart';
import 'package:hotel_manager/core/services/database_service.dart';

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
  Stream<List<Room>> streamRooms(String hotelId) =>
      _databaseService.streamRooms(hotelId);

  /// Stream all bookings from database
  Stream<List<Booking>> streamBookings(String hotelId) =>
      _databaseService.streamBookings(hotelId);

  /// Save a new booking
  Future<void> saveBooking(Booking booking) =>
      _databaseService.saveBooking(booking);

  /// Update room status
  Future<void> updateRoomStatus(
    String hotelId,
    String roomId,
    RoomStatus status,
  ) => _databaseService.updateRoomStatus(hotelId, roomId, status);

  /// Get booking by ID
  Future<Booking?> getBookingById(String hotelId, String bookingId) =>
      _databaseService.getBookingById(hotelId, bookingId);
}
