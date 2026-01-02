import 'package:equatable/equatable.dart';
import 'package:hotel_manager/core/models/payment_models.dart';

/// Booking status enum
enum BookingStatus { confirmed, checkedIn, checkedOut, cancelled }

/// Extension for BookingStatus
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

/// Booking model for guest reservations
///
/// This model is synced with Firebase Realtime Database.
/// Schema version: 1
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
  final String bookedBy;
  final DateTime createdAt;
  final String? notes;
  final String? idProofType;
  final String? idProofNumber;
  final int numberOfGuests;
  final List<Map<String, dynamic>>? accompanyingPersons;
  final String? customerId;
  final String? idProofImageUrl;
  final double paidAmount;
  final PaymentMethod? paymentMethod;
  final String? paymentReference;

  // Schema version for migrations
  static const int schemaVersion = 2;

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
    this.notes,
    this.idProofType,
    this.idProofNumber,
    this.numberOfGuests = 1,
    this.accompanyingPersons,
    this.customerId,
    this.idProofImageUrl,
    this.paidAmount = 0.0,
    this.paymentMethod,
    this.paymentReference,
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
    notes,
    idProofType,
    idProofNumber,
    numberOfGuests,
    accompanyingPersons,
    customerId,
    idProofImageUrl,
    paidAmount,
    paymentMethod,
    paymentReference,
  ];

  int get nights => checkOut.difference(checkIn).inDays;

  Booking copyWith({
    String? id,
    String? guestName,
    String? guestPhone,
    String? guestEmail,
    String? roomId,
    DateTime? checkIn,
    DateTime? checkOut,
    double? totalAmount,
    BookingStatus? status,
    String? bookedBy,
    DateTime? createdAt,
    String? notes,
    String? idProofType,
    String? idProofNumber,
    int? numberOfGuests,
    List<Map<String, dynamic>>? accompanyingPersons,
    String? customerId,
    String? idProofImageUrl,
    double? paidAmount,
    PaymentMethod? paymentMethod,
    String? paymentReference,
  }) {
    return Booking(
      id: id ?? this.id,
      guestName: guestName ?? this.guestName,
      guestPhone: guestPhone ?? this.guestPhone,
      guestEmail: guestEmail ?? this.guestEmail,
      roomId: roomId ?? this.roomId,
      checkIn: checkIn ?? this.checkIn,
      checkOut: checkOut ?? this.checkOut,
      totalAmount: totalAmount ?? this.totalAmount,
      status: status ?? this.status,
      bookedBy: bookedBy ?? this.bookedBy,
      createdAt: createdAt ?? this.createdAt,
      notes: notes ?? this.notes,
      idProofType: idProofType ?? this.idProofType,
      idProofNumber: idProofNumber ?? this.idProofNumber,
      numberOfGuests: numberOfGuests ?? this.numberOfGuests,
      accompanyingPersons: accompanyingPersons ?? this.accompanyingPersons,
      customerId: customerId ?? this.customerId,
      idProofImageUrl: idProofImageUrl ?? this.idProofImageUrl,
      paidAmount: paidAmount ?? this.paidAmount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentReference: paymentReference ?? this.paymentReference,
    );
  }

  /// Convert to JSON for Firebase
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'guestName': guestName,
      'guestPhone': guestPhone,
      'guestEmail': guestEmail,
      'roomId': roomId,
      'checkIn': checkIn.toIso8601String(),
      'checkOut': checkOut.toIso8601String(),
      'totalAmount': totalAmount,
      'status': status.name,
      'bookedBy': bookedBy,
      'createdAt': createdAt.toIso8601String(),
      'notes': notes,
      'idProofType': idProofType,
      'idProofNumber': idProofNumber,
      'numberOfGuests': numberOfGuests,
      'accompanyingPersons': accompanyingPersons,
      'customerId': customerId,
      'idProofImageUrl': idProofImageUrl,
      'paidAmount': paidAmount,
      'paymentMethod': paymentMethod?.name,
      'paymentReference': paymentReference,
      '_schemaVersion': schemaVersion,
    };
  }

  /// Create from Firebase JSON
  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'] as String,
      guestName: json['guestName'] as String,
      guestPhone: json['guestPhone'] as String,
      guestEmail: json['guestEmail'] as String?,
      roomId: json['roomId'] as String,
      checkIn: DateTime.parse(json['checkIn'] as String),
      checkOut: DateTime.parse(json['checkOut'] as String),
      totalAmount: (json['totalAmount'] as num).toDouble(),
      status: BookingStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => BookingStatus.confirmed,
      ),
      bookedBy: json['bookedBy'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      notes: json['notes'] as String?,
      idProofType: json['idProofType'] as String?,
      idProofNumber: json['idProofNumber'] as String?,
      numberOfGuests: json['numberOfGuests'] as int? ?? 1,
      accompanyingPersons: (json['accompanyingPersons'] as List?)
          ?.map((e) => Map<String, dynamic>.from(e as Map))
          .toList(),
      customerId: json['customerId'] as String?,
      idProofImageUrl: json['idProofImageUrl'] as String?,
      paidAmount: (json['paidAmount'] as num?)?.toDouble() ?? 0.0,
      paymentMethod: json['paymentMethod'] != null
          ? PaymentMethod.values.firstWhere(
              (e) => e.name == json['paymentMethod'],
              orElse: () => PaymentMethod.cash,
            )
          : null,
      paymentReference: json['paymentReference'] as String?,
    );
  }
}
