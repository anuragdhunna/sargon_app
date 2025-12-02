import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hotel_manager/core/models/audit_log.dart';
import 'package:hotel_manager/core/services/audit_service.dart';
import 'package:hotel_manager/features/checklists/logic/checklist_cubit.dart';
import 'package:hotel_manager/features/rooms/data/room_model.dart';
import 'package:uuid/uuid.dart';

/// Room Cubit State
abstract class RoomState extends Equatable {
  const RoomState();
}

class RoomInitial extends RoomState {
  @override
  List<Object> get props => [];
}

class RoomLoading extends RoomState {
  @override
  List<Object> get props => [];
}

class RoomLoaded extends RoomState {
  final List<Room> rooms;
  final Map<String, Booking> bookings;

  const RoomLoaded({
    required this.rooms,
    required this.bookings,
  });

  @override
  List<Object> get props => [rooms, bookings];

  RoomLoaded copyWith({
    List<Room>? rooms,
    Map<String, Booking>? bookings,
  }) {
    return RoomLoaded(
      rooms: rooms ?? this.rooms,
      bookings: bookings ?? this.bookings,
    );
  }
}

class RoomError extends RoomState {
  final String message;

  const RoomError(this.message);

  @override
  List<Object> get props => [message];
}


/// Room Cubit - Manages room bookings and status
class RoomCubit extends Cubit<RoomState> {
  final AuditService _auditService = AuditService();
  final Uuid _uuid = const Uuid();
  final ChecklistCubit checklistCubit;

  RoomCubit({required this.checklistCubit}) : super(RoomInitial());

  /// Load all rooms and bookings
  void loadRooms() {
    emit(RoomLoading());
    
    // TODO: Replace with actual API call
    final rooms = _generateMockRooms();
    final bookings = _generateMockBookings();
    
    emit(RoomLoaded(rooms: rooms, bookings: bookings));
  }

  /// Create a new booking
  Future<void> createBooking({
    required String roomId,
    required String guestName,
    required String guestPhone,
    String? guestEmail,
    required DateTime checkIn,
    required DateTime checkOut,
    required double totalAmount,
    required String bookedByUserId,
    required String bookedByUserName,
    required String bookedByUserRole,
    Map<String, dynamic>? metadata,
  }) async {
    final currentState = state;
    if (currentState is! RoomLoaded) return;

    try {
      // Create booking
      final booking = Booking(
        id: _uuid.v4(),
        guestName: guestName,
        guestPhone: guestPhone,
        guestEmail: guestEmail,
        roomId: roomId,
        checkIn: checkIn,
        checkOut: checkOut,
        totalAmount: totalAmount,
        status: BookingStatus.confirmed,
        bookedBy: bookedByUserId,
        createdAt: DateTime.now(),
      );

      // Update room status to reserved
      final updatedRooms = currentState.rooms.map((room) {
        if (room.id == roomId) {
          return room.copyWith(status: RoomStatus.reserved);
        }
        return room;
      }).toList();

      final updatedBookings = Map<String, Booking>.from(currentState.bookings);
      updatedBookings[roomId] = booking;

      // Update state
      emit(currentState.copyWith(
        rooms: updatedRooms,
        bookings: updatedBookings,
      ));

      // Log audit
      await _auditService.log(
        userId: bookedByUserId,
        userName: bookedByUserName,
        userRole: bookedByUserRole,
        action: AuditAction.create,
        entity: 'booking',
        entityId: booking.id,
        description: 'Created booking for $guestName in room $roomId',
        metadata: {
          'roomId': roomId,
          'guestName': guestName,
          'checkIn': checkIn.toIso8601String(),
          'checkOut': checkOut.toIso8601String(),
          'totalAmount': totalAmount,
          ...?metadata,
        },
      );
    } catch (e) {
      emit(RoomError('Failed to create booking: $e'));
      emit(currentState);
    }
  }

  /// Check-in a guest
  Future<void> checkIn({
    required String bookingId,
    required String userId,
    required String userName,
    required String userRole,
  }) async {
    final currentState = state;
    if (currentState is! RoomLoaded) return;

    try {
      final updatedBookings = Map<String, Booking>.from(currentState.bookings);
      final booking = updatedBookings.values.firstWhere((b) => b.id == bookingId);
      
      // Update booking status
      final updatedBooking = booking.copyWith(status: BookingStatus.checkedIn);
      updatedBookings[booking.roomId] = updatedBooking;

      // Update room status to occupied
      final updatedRooms = currentState.rooms.map((room) {
        if (room.id == booking.roomId) {
          return room.copyWith(status: RoomStatus.occupied);
        }
        return room;
      }).toList();

      emit(currentState.copyWith(
        rooms: updatedRooms,
        bookings: updatedBookings,
      ));

      // Log audit
      await _auditService.log(
        userId: userId,
        userName: userName,
        userRole: userRole,
        action: AuditAction.checkIn,
        entity: 'booking',
        entityId: bookingId,
        description: 'Checked in guest ${booking.guestName} to room ${booking.roomId}',
        metadata: {'roomId': booking.roomId, 'guestName': booking.guestName},
      );
    } catch (e) {
      emit(RoomError('Failed to check in: $e'));
      emit(currentState);
    }
  }

  /// Check-out a guest
  Future<void> checkOut({
    required String bookingId,
    required String userId,
    required String userName,
    required String userRole,
  }) async {
    final currentState = state;
    if (currentState is! RoomLoaded) return;

    try {
      final updatedBookings = Map<String, Booking>.from(currentState.bookings);
      final booking = updatedBookings.values.firstWhere((b) => b.id == bookingId);
      
      // Update booking status
      final updatedBooking = booking.copyWith(status: BookingStatus.checkedOut);
      updatedBookings[booking.roomId] = updatedBooking;

      // Update room status to cleaning
      final updatedRooms = currentState.rooms.map((room) {
        if (room.id == booking.roomId) {
          return room.copyWith(status: RoomStatus.cleaning);
        }
        return room;
      }).toList();

      emit(currentState.copyWith(
        rooms: updatedRooms,
        bookings: updatedBookings,
      ));

      // Log audit
      await _auditService.log(
        userId: userId,
        userName: userName,
        userRole: userRole,
        action: AuditAction.checkOut,
        entity: 'booking',
        entityId: bookingId,
        description: 'Checked out guest ${booking.guestName} from room ${booking.roomId}',
        metadata: {'roomId': booking.roomId, 'guestName': booking.guestName},
      );

      // Auto-create cleaning checklist
      final room = currentState.rooms.firstWhere((r) => r.id == booking.roomId);
      checklistCubit.createCleaningChecklist(
        roomId: booking.roomId,
        roomNumber: room.roomNumber,
      );
    } catch (e) {
      emit(RoomError('Failed to check out: $e'));
      emit(currentState);
    }
  }

  /// Update room status (for housekeeping)
  Future<void> updateRoomStatus({
    required String roomId,
    required RoomStatus newStatus,
    required String userId,
    required String userName,
    required String userRole,
  }) async {
    final currentState = state;
    if (currentState is! RoomLoaded) return;

    try {
      final updatedRooms = currentState.rooms.map((room) {
        if (room.id == roomId) {
          return room.copyWith(status: newStatus);
        }
        return room;
      }).toList();

      emit(currentState.copyWith(rooms: updatedRooms));

      // Log audit
      await _auditService.log(
        userId: userId,
        userName: userName,
        userRole: userRole,
        action: AuditAction.update,
        entity: 'room',
        entityId: roomId,
        description: 'Updated room $roomId status to ${newStatus.displayName}',
        metadata: {'newStatus': newStatus.name},
      );
    } catch (e) {
      emit(RoomError('Failed to update room status: $e'));
      emit(currentState);
    }
  }

  /// Cancel a booking
  Future<void> cancelBooking({
    required String bookingId,
    required String userId,
    required String userName,
    required String userRole,
    String? reason,
  }) async {
    final currentState = state;
    if (currentState is! RoomLoaded) return;

    try {
      final updatedBookings = Map<String, Booking>.from(currentState.bookings);
      final booking = updatedBookings.values.firstWhere((b) => b.id == bookingId);
      
      // Update booking status
      final updatedBooking = booking.copyWith(status: BookingStatus.cancelled);
      updatedBookings[booking.roomId] = updatedBooking;

      // Update room status back to available
      final updatedRooms = currentState.rooms.map((room) {
        if (room.id == booking.roomId) {
          return room.copyWith(status: RoomStatus.available);
        }
        return room;
      }).toList();

      emit(currentState.copyWith(
        rooms: updatedRooms,
        bookings: updatedBookings,
      ));

      // Log audit
      await _auditService.log(
        userId: userId,
        userName: userName,
        userRole: userRole,
        action: AuditAction.delete,
        entity: 'booking',
        entityId: bookingId,
        description: 'Cancelled booking for ${booking.guestName}${reason != null ? ": $reason" : ""}',
        metadata: {'roomId': booking.roomId, 'reason': reason},
      );
    } catch (e) {
      emit(RoomError('Failed to cancel booking: $e'));
      emit(currentState);
    }
  }

  // Mock data generators
  List<Room> _generateMockRooms() {
    return List.generate(30, (index) {
      final roomNumber = '${(index ~/ 10) + 1}0${(index % 10) + 1}';
      final statuses = [
        RoomStatus.available,
        RoomStatus.occupied,
        RoomStatus.cleaning,
        RoomStatus.maintenance,
        RoomStatus.reserved,
      ];
      return Room(
        id: 'room_$index',
        roomNumber: roomNumber,
        type: RoomType.values[index % 4],
        status: statuses[index % 5],
        pricePerNight: 1000 + (index * 100),
        floor: (index ~/ 10) + 1,
        capacity: (RoomType.values[index % 4] == RoomType.single) ? 1 : 2,
        amenities: ['WiFi', 'AC', 'TV'],
      );
    });
  }

  Map<String, Booking> _generateMockBookings() {
    return {
      'room_1': Booking(
        id: 'booking_1',
        guestName: 'John Doe',
        guestPhone: '+91 9876543210',
        guestEmail: 'john@example.com',
        roomId: 'room_1',
        checkIn: DateTime.now().subtract(const Duration(days: 1)),
        checkOut: DateTime.now().add(const Duration(days: 2)),
        totalAmount: 3000,
        status: BookingStatus.checkedIn,
        bookedBy: 'front_desk_1',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      'room_6': Booking(
        id: 'booking_2',
        guestName: 'Jane Smith',
        guestPhone: '+91 9876543211',
        guestEmail: 'jane@example.com',
        roomId: 'room_6',
        checkIn: DateTime.now(),
        checkOut: DateTime.now().add(const Duration(days: 3)),
        totalAmount: 4500,
        status: BookingStatus.checkedIn,
        bookedBy: 'front_desk_1',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
    };
  }
}
