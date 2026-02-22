import 'package:equatable/equatable.dart';

/// Base class for all Firestore documents to support auditing.
/// These fields are mostly managed by Cloud Functions triggers.
abstract class BaseEntity extends Equatable {
  final String id;

  /// Multi-tenant identifier for the hotel
  final String hotelId;

  /// User ID who created the document (set by backend)
  final String? createdBy;

  /// Timestamp when the document was created (set by backend)
  final DateTime? createdOn;

  /// User ID who last updated the document (set by backend)
  final String? updatedBy;

  /// Timestamp when the document was last updated (set by backend)
  final DateTime? updatedOn;

  /// User ID who deleted the document (set by backend for soft delete)
  final String? deletedBy;

  /// Timestamp when the document was deleted (set by backend for soft delete)
  final DateTime? deletedOn;

  /// Flag for soft deletion
  final bool isDeleted;

  const BaseEntity({
    required this.id,
    required this.hotelId,
    this.createdBy,
    this.createdOn,
    this.updatedBy,
    this.updatedOn,
    this.deletedBy,
    this.deletedOn,
    this.isDeleted = false,
  });

  /// Must be implemented by subclasses to provide their data for Firestore.
  Map<String, dynamic> toJson();

  /// Map common audit fields to JSON for backend consumption.
  Map<String, dynamic> toAuditJson() => {
    'id': id,
    'hotelId': hotelId,
    'isDeleted': isDeleted,
    if (createdBy != null) 'createdBy': createdBy,
    if (createdOn != null) 'createdOn': createdOn!.toIso8601String(),
    if (updatedBy != null) 'updatedBy': updatedBy,
    if (updatedOn != null) 'updatedOn': updatedOn!.toIso8601String(),
    if (deletedBy != null) 'deletedBy': deletedBy,
    if (deletedOn != null) 'deletedOn': deletedOn!.toIso8601String(),
  };

  /// Helper to parse dates from Firestore (which can be Timestamp or String)
  static DateTime? parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    // Handle Firestore Timestamp without direct dependency if possible
    try {
      return (value as dynamic).toDate();
    } catch (_) {
      return null;
    }
  }

  @override
  List<Object?> get props => [
    id,
    hotelId,
    createdBy,
    createdOn,
    updatedBy,
    updatedOn,
    deletedBy,
    deletedOn,
    isDeleted,
  ];
}
