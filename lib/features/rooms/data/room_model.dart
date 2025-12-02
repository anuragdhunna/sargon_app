import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:hotel_manager/theme/app_theme.dart';

/// Room model for Property Management System
class Room extends Equatable {
  final String id;
  final String roomNumber;
  final RoomType type;
  final RoomStatus status;
  final double pricePerNight;
  final int floor;
  final int capacity;
  final List<String> amenities;

  const Room({
    required this.id,
    required this.roomNumber,
    required this.type,
    required this.status,
    required this.pricePerNight,
    required this.floor,
    required this.capacity,
    this.amenities = const [],
  });

  @override
  List<Object?> get props => [id, roomNumber, type, status, pricePerNight, floor, capacity, amenities];

  Room copyWith({
    RoomStatus? status,
    double? pricePerNight,
  }) {
    return Room(
      id: id,
      roomNumber: roomNumber,
      type: type,
      status: status ?? this.status,
      pricePerNight: pricePerNight ?? this.pricePerNight,
      floor: floor,
      capacity: capacity,
      amenities: amenities,
    );
  }
}

enum RoomType { single, double, suite, deluxe }
enum RoomStatus { available, occupied, maintenance, cleaning, reserved }

extension RoomTypeExtension on RoomType {
  String get displayName {
    switch (this) {
      case RoomType.single:
        return 'Single';
      case RoomType.double:
        return 'Double';
      case RoomType.suite:
        return 'Suite';
      case RoomType.deluxe:
        return 'Deluxe';
    }
  }

  IconData get icon {
    switch (this) {
      case RoomType.single:
        return Icons.single_bed;
      case RoomType.double:
        return Icons.king_bed;
      case RoomType.suite:
      case RoomType.deluxe:
        return Icons.bedroom_parent;
    }
  }
}

extension RoomStatusExtension on RoomStatus {
  String get displayName {
    switch (this) {
      case RoomStatus.available:
        return 'Available';
      case RoomStatus.occupied:
        return 'Occupied';
      case RoomStatus.maintenance:
        return 'Maintenance';
      case RoomStatus.cleaning:
        return 'Cleaning';
      case RoomStatus.reserved:
        return 'Reserved';
    }
  }

  Color get color {
    switch (this) {
      case RoomStatus.available:
        return AppColors.roomAvailable;
      case RoomStatus.occupied:
        return AppColors.roomOccupied;
      case RoomStatus.maintenance:
        return AppColors.roomMaintenance;
      case RoomStatus.cleaning:
        return AppColors.roomCleaning;
      case RoomStatus.reserved:
        return AppColors.roomReserved;
    }
  }
}

/// Booking model for guest reservations
class Booking extends Equatable {
  final String id;
  final String guestName;
  final String guestPhone;
  final String? guestEmail;
  final String roomId;
  final DateTime checkIn;
  final DateTime checkOut;
  final double totalAmount;
  final BookingStatus status;
  final String bookedBy;  // User ID who created booking
  final DateTime createdAt;

  const Booking({
    required this.id,
    required this.guestName,
    required this.guestPhone,
    this.guestEmail,
    required this.roomId,
    required this.checkIn,
    required this.checkOut,
    required this.totalAmount,
    required this.status,
    required this.bookedBy,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        guestName,
        guestPhone,
        guestEmail,
        roomId,
        checkIn,
        checkOut,
        totalAmount,
        status,
        bookedBy,
        createdAt,
      ];

  Booking copyWith({
    BookingStatus? status,
    DateTime? checkIn,
    DateTime? checkOut,
  }) {
    return Booking(
      id: id,
      guestName: guestName,
      guestPhone: guestPhone,
      guestEmail: guestEmail,
      roomId: roomId,
      checkIn: checkIn ?? this.checkIn,
      checkOut: checkOut ?? this.checkOut,
      totalAmount: totalAmount,
      status: status ?? this.status,
      bookedBy: bookedBy,
      createdAt: createdAt,
    );
  }

  int get nights => checkOut.difference(checkIn).inDays;
}

enum BookingStatus { confirmed, checkedIn, checkedOut, cancelled }

extension BookingStatusExtension on BookingStatus {
  String get displayName {
    switch (this) {
      case BookingStatus.confirmed:
        return 'Confirmed';
      case BookingStatus.checkedIn:
        return 'Checked In';
      case BookingStatus.checkedOut:
        return 'Checked Out';
      case BookingStatus.cancelled:
        return 'Cancelled';
    }
  }
}
