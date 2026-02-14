import 'base_entity.dart';
import 'package:flutter/material.dart';

/// Room type enum
enum RoomType { single, double, suite, deluxe }

/// Room status enum
enum RoomStatus { available, occupied, maintenance, cleaning, reserved }

/// Extension for RoomType
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

/// Extension for RoomStatus
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
        return const Color(0xFF4CAF50);
      case RoomStatus.occupied:
        return const Color(0xFFF44336);
      case RoomStatus.maintenance:
        return const Color(0xFFFF9800);
      case RoomStatus.cleaning:
        return const Color(0xFF2196F3);
      case RoomStatus.reserved:
        return const Color(0xFF9C27B0);
    }
  }
}

/// Room model for Property Management System
///
/// This model is synced with Firebase Realtime Database.
/// Schema version: 1
class Room extends BaseEntity {
  final String roomNumber;
  final RoomType type;
  final RoomStatus status;
  final double pricePerNight;
  final int floor;
  final int capacity;
  final List<String> amenities;

  // Schema version for migrations
  static const int schemaVersion = 1;

  const Room({
    required super.id,
    required this.roomNumber,
    required this.type,
    required this.status,
    required this.pricePerNight,
    required this.floor,
    required this.capacity,
    this.amenities = const [],
    super.createdBy,
    super.createdOn,
    super.updatedBy,
    super.updatedOn,
    super.isDeleted,
  });

  @override
  List<Object?> get props => [
    ...super.props,
    roomNumber,
    type,
    status,
    pricePerNight,
    floor,
    capacity,
    amenities,
  ];

  Room copyWith({
    String? id,
    String? roomNumber,
    RoomType? type,
    RoomStatus? status,
    double? pricePerNight,
    int? floor,
    int? capacity,
    List<String>? amenities,
  }) {
    return Room(
      id: id ?? this.id,
      roomNumber: roomNumber ?? this.roomNumber,
      type: type ?? this.type,
      status: status ?? this.status,
      pricePerNight: pricePerNight ?? this.pricePerNight,
      floor: floor ?? this.floor,
      capacity: capacity ?? this.capacity,
      amenities: amenities ?? this.amenities,
      createdBy: createdBy,
      createdOn: createdOn,
      updatedBy: updatedBy,
      updatedOn: updatedOn,
      isDeleted: isDeleted,
    );
  }

  /// Convert to JSON for Firebase
  Map<String, dynamic> toJson() {
    return {
      ...super.toAuditJson(),
      'roomNumber': roomNumber,
      'type': type.name,
      'status': status.name,
      'pricePerNight': pricePerNight,
      'floor': floor,
      'capacity': capacity,
      'amenities': amenities,
      '_schemaVersion': schemaVersion,
    };
  }

  /// Create from Firebase JSON
  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(
      id: json['id'] as String,
      roomNumber: json['roomNumber'] as String,
      type: RoomType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => RoomType.single,
      ),
      status: RoomStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => RoomStatus.available,
      ),
      pricePerNight: (json['pricePerNight'] as num).toDouble(),
      floor: json['floor'] as int,
      capacity: json['capacity'] as int,
      amenities: (json['amenities'] as List?)?.cast<String>() ?? [],
      createdBy: json['createdBy'] as String?,
      createdOn: BaseEntity.parseDateTime(json['createdOn']),
      updatedBy: json['updatedBy'] as String?,
      updatedOn: BaseEntity.parseDateTime(json['updatedOn']),
      isDeleted: json['isDeleted'] ?? false,
    );
  }
}
