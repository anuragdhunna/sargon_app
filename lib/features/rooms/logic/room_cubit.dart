import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hotel_manager/core/models/models.dart';
import 'package:hotel_manager/core/services/database_service.dart';
import 'package:hotel_manager/features/checklists/logic/checklist_cubit.dart';
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
  final List<Booking> allBookings;
  final Map<String, Booking> activeBookings; // Current check-ins/reservations
  final DateTime? filterFrom;
  final DateTime? filterTo;
  final bool availableOnly;

  const RoomLoaded({
    required this.rooms,
    required this.allBookings,
    required this.activeBookings,
    this.filterFrom,
    this.filterTo,
    this.availableOnly = false,
  });

  @override
  List<Object?> get props => [
    rooms,
    allBookings,
    activeBookings,
    filterFrom,
    filterTo,
    availableOnly,
  ];

  RoomLoaded copyWith({
    List<Room>? rooms,
    List<Booking>? allBookings,
    Map<String, Booking>? activeBookings,
    DateTime? filterFrom,
    DateTime? filterTo,
    bool? availableOnly,
  }) {
    return RoomLoaded(
      rooms: rooms ?? this.rooms,
      allBookings: allBookings ?? this.allBookings,
      activeBookings: activeBookings ?? this.activeBookings,
      filterFrom: filterFrom ?? this.filterFrom,
      filterTo: filterTo ?? this.filterTo,
      availableOnly: availableOnly ?? this.availableOnly,
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
  final DatabaseService _databaseService;
  final ChecklistCubit checklistCubit;
  final Uuid _uuid = const Uuid();
  StreamSubscription? _roomsSubscription;
  StreamSubscription? _bookingsSubscription;

  RoomCubit({
    required DatabaseService databaseService,
    required this.checklistCubit,
  }) : _databaseService = databaseService,
       super(RoomInitial()) {
    loadRooms();
  }

  /// Load all rooms and bookings in real-time
  void loadRooms() {
    emit(RoomLoading());
    _roomsSubscription?.cancel();
    _bookingsSubscription?.cancel();

    // Combined stream would be better but let's handle them separately for now
    _roomsSubscription = _databaseService.streamRooms().listen((rooms) {
      final currentState = state;
      if (currentState is RoomLoaded) {
        emit(currentState.copyWith(rooms: rooms));
      } else {
        _updateState(rooms: rooms);
      }
    }, onError: (e) => emit(RoomError('Failed to load rooms: $e')));

    _bookingsSubscription = _databaseService.streamBookings().listen((
      bookings,
    ) {
      final currentState = state;
      if (currentState is RoomLoaded) {
        emit(
          currentState.copyWith(
            allBookings: bookings,
            activeBookings: _getActiveBookings(bookings),
          ),
        );
      } else {
        _updateState(allBookings: bookings);
      }
    }, onError: (e) => emit(RoomError('Failed to load bookings: $e')));
  }

  void _updateState({List<Room>? rooms, List<Booking>? allBookings}) {
    final curRooms =
        rooms ?? (state is RoomLoaded ? (state as RoomLoaded).rooms : <Room>[]);
    final curBookings =
        allBookings ??
        (state is RoomLoaded ? (state as RoomLoaded).allBookings : <Booking>[]);

    emit(
      RoomLoaded(
        rooms: curRooms,
        allBookings: curBookings,
        activeBookings: _getActiveBookings(curBookings),
      ),
    );
  }

  Map<String, Booking> _getActiveBookings(List<Booking> bookings) {
    final map = <String, Booking>{};
    for (var b in bookings) {
      if (b.status == BookingStatus.checkedIn ||
          b.status == BookingStatus.confirmed) {
        map[b.roomId] = b;
      }
    }
    return map;
  }

  /// Set availability filters
  void setFilters({DateTime? from, DateTime? to, bool? availableOnly}) {
    final currentState = state;
    if (currentState is RoomLoaded) {
      emit(
        currentState.copyWith(
          filterFrom: from,
          filterTo: to,
          availableOnly: availableOnly,
        ),
      );
    }
  }

  /// Check if a room is available for a given date range
  bool isRoomAvailable(String roomId, DateTime from, DateTime to) {
    final currentState = state;
    if (currentState is! RoomLoaded) return false;

    return !currentState.allBookings.any((b) {
      if (b.roomId != roomId) return false;
      if (b.status == BookingStatus.cancelled ||
          b.status == BookingStatus.checkedOut) {
        return false;
      }

      // Check for overlap
      return (from.isBefore(b.checkOut) && to.isAfter(b.checkIn));
    });
  }

  /// Filtered rooms based on UI selection
  List<Room> getFilteredRooms() {
    final currentState = state;
    if (currentState is! RoomLoaded) return [];

    var rooms = currentState.rooms;

    if (currentState.availableOnly &&
        currentState.filterFrom != null &&
        currentState.filterTo != null) {
      rooms = rooms
          .where(
            (r) => isRoomAvailable(
              r.id,
              currentState.filterFrom!,
              currentState.filterTo!,
            ),
          )
          .toList();
    } else if (currentState.availableOnly) {
      rooms = rooms.where((r) => r.status == RoomStatus.available).toList();
    }

    return rooms;
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
    String? notes,
    String? idProofType,
    String? idProofNumber,
    int numberOfGuests = 1,
    List<Map<String, dynamic>>? accompanyingPersons,
    String? customerId,
    String? idProofImageUrl,
    double paidAmount = 0.0,
    PaymentMethod? paymentMethod,
    String? paymentReference,
  }) async {
    // Zero out time part for date-only bookings
    final cleanCheckIn = DateTime(checkIn.year, checkIn.month, checkIn.day);
    final cleanCheckOut = DateTime(checkOut.year, checkOut.month, checkOut.day);

    // Validate phone number (mandatory)
    if (guestPhone.trim().isEmpty) {
      emit(const RoomError('Phone number is mandatory for booking'));
      return;
    }

    try {
      final booking = Booking(
        id: _uuid.v4(),
        guestName: guestName,
        guestPhone: guestPhone,
        guestEmail: guestEmail,
        roomId: roomId,
        checkIn: cleanCheckIn,
        checkOut: cleanCheckOut,
        totalAmount: totalAmount,
        status: BookingStatus.confirmed,
        bookedBy: bookedByUserName,
        createdAt: DateTime.now(),
        notes: notes,
        idProofType: idProofType,
        idProofNumber: idProofNumber,
        numberOfGuests: numberOfGuests,
        accompanyingPersons: accompanyingPersons,
        customerId: customerId,
        idProofImageUrl: idProofImageUrl,
        paidAmount: paidAmount,
        paymentMethod: paymentMethod,
        paymentReference: paymentReference,
      );

      await _databaseService.saveBooking(booking);

      // Update room status if it's for today
      final now = DateTime.now();
      if (checkIn.year == now.year &&
          checkIn.month == now.month &&
          checkIn.day == now.day) {
        await _databaseService.updateRoomStatus(roomId, RoomStatus.reserved);
      }
    } catch (e) {
      emit(RoomError('Failed to create booking: $e'));
    }
  }

  /// Check-in a guest
  Future<void> checkIn({
    required String bookingId,
    required String roomId,
    required String userId,
    required String userName,
    required String userRole,
  }) async {
    try {
      await _databaseService.bookingsRef.child(bookingId).update({
        'status': BookingStatus.checkedIn.name,
      });
      await _databaseService.updateRoomStatus(roomId, RoomStatus.occupied);
    } catch (e) {
      emit(RoomError('Failed to check in: $e'));
    }
  }

  /// Check-out a guest
  Future<void> checkOut({
    required String bookingId,
    required String roomId,
    required String userId,
    required String userName,
    required String userRole,
  }) async {
    try {
      await _databaseService.bookingsRef.child(bookingId).update({
        'status': BookingStatus.checkedOut.name,
      });
      await _databaseService.updateRoomStatus(roomId, RoomStatus.cleaning);

      // Create cleaning checklist
      final currentState = state;
      if (currentState is RoomLoaded) {
        final room = currentState.rooms.firstWhere((r) => r.id == roomId);
        checklistCubit.createCleaningChecklist(
          roomId: roomId,
          roomNumber: room.roomNumber,
        );
      }
    } catch (e) {
      emit(RoomError('Failed to check out: $e'));
    }
  }

  /// Update room status manually
  Future<void> updateRoomStatus({
    required String roomId,
    required RoomStatus newStatus,
    required String userId,
    required String userName,
    required String userRole,
  }) async {
    try {
      await _databaseService.updateRoomStatus(roomId, newStatus);
    } catch (e) {
      emit(RoomError('Failed to update room status: $e'));
    }
  }

  /// Check if a phone number already has an active overlapping booking
  bool isPhoneBooked(String phone, DateTime from, DateTime to) {
    if (state is! RoomLoaded) return false;
    final loaded = state as RoomLoaded;
    return loaded.allBookings.any(
      (b) =>
          b.guestPhone == phone &&
          (b.status == BookingStatus.confirmed ||
              b.status == BookingStatus.checkedIn) &&
          (from.isBefore(b.checkOut) && to.isAfter(b.checkIn)),
    );
  }

  @override
  Future<void> close() {
    _roomsSubscription?.cancel();
    _bookingsSubscription?.cancel();
    return super.close();
  }
}
