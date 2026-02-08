import 'package:equatable/equatable.dart';
import 'payment_models.dart';
import 'offer_model.dart';

/// Tax calculation rule model
class TaxRule extends Equatable {
  final String id;
  final String name; // e.g., "GST 5%", "GST 18%"
  final double cgstPercent;
  final double sgstPercent;
  final double igstPercent;
  final bool isActive;

  const TaxRule({
    required this.id,
    required this.name,
    required this.cgstPercent,
    required this.sgstPercent,
    this.igstPercent = 0,
    this.isActive = true,
  });

  double getEffectiveTax() {
    return cgstPercent + sgstPercent + igstPercent;
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'cgstPercent': cgstPercent,
    'sgstPercent': sgstPercent,
    'igstPercent': igstPercent,
    'isActive': isActive,
  };

  factory TaxRule.fromJson(Map<String, dynamic> json) => TaxRule(
    id: json['id'],
    name: json['name'],
    cgstPercent: (json['cgstPercent'] as num).toDouble(),
    sgstPercent: (json['sgstPercent'] as num).toDouble(),
    igstPercent: (json['igstPercent'] as num).toDouble(),
    isActive: json['isActive'] ?? true,
  );

  @override
  List<Object?> get props => [
    id,
    name,
    cgstPercent,
    sgstPercent,
    igstPercent,
    isActive,
  ];
}

/// Service charge rule model
class ServiceChargeRule extends Equatable {
  final String id;
  final String name; // e.g., "Service Charge 10%"
  final double percent;
  final bool isOptional;
  final bool isActive;

  const ServiceChargeRule({
    required this.id,
    required this.name,
    required this.percent,
    this.isOptional = true,
    this.isActive = true,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'percent': percent,
    'isOptional': isOptional,
    'isActive': isActive,
  };

  factory ServiceChargeRule.fromJson(Map<String, dynamic> json) =>
      ServiceChargeRule(
        id: json['id'],
        name: json['name'],
        percent: (json['percent'] as num).toDouble(),
        isOptional: json['isOptional'] ?? true,
        isActive: json['isActive'] ?? true,
      );

  @override
  List<Object?> get props => [id, name, percent, isOptional, isActive];
}

/// Summary of taxes applied to a bill
class BillTaxSummary extends Equatable {
  final double subTotal;
  final double serviceChargeAmount;
  final double taxableAmount;
  final double cgstAmount;
  final double sgstAmount;
  final double igstAmount;
  final double totalDiscountAmount;
  final double totalTax;
  final double grandTotal;

  const BillTaxSummary({
    required this.subTotal,
    required this.serviceChargeAmount,
    required this.taxableAmount,
    required this.cgstAmount,
    required this.sgstAmount,
    required this.igstAmount,
    required this.totalDiscountAmount,
    required this.totalTax,
    required this.grandTotal,
  });

  Map<String, dynamic> toJson() => {
    'subTotal': subTotal,
    'serviceChargeAmount': serviceChargeAmount,
    'taxableAmount': taxableAmount,
    'cgstAmount': cgstAmount,
    'sgstAmount': sgstAmount,
    'igstAmount': igstAmount,
    'totalDiscountAmount': totalDiscountAmount,
    'totalTax': totalTax,
    'grandTotal': grandTotal,
  };

  factory BillTaxSummary.fromJson(Map<String, dynamic> json) => BillTaxSummary(
    subTotal: (json['subTotal'] as num).toDouble(),
    serviceChargeAmount: (json['serviceChargeAmount'] as num).toDouble(),
    taxableAmount: (json['taxableAmount'] as num).toDouble(),
    cgstAmount: (json['cgstAmount'] as num).toDouble(),
    sgstAmount: (json['sgstAmount'] as num).toDouble(),
    igstAmount: (json['igstAmount'] as num).toDouble(),
    totalDiscountAmount:
        (json['totalDiscountAmount'] as num?)?.toDouble() ?? 0.0,
    totalTax: (json['totalTax'] as num).toDouble(),
    grandTotal: (json['grandTotal'] as num).toDouble(),
  );

  @override
  List<Object?> get props => [
    subTotal,
    serviceChargeAmount,
    taxableAmount,
    cgstAmount,
    sgstAmount,
    igstAmount,
    totalDiscountAmount,
    totalTax,
    grandTotal,
  ];
}

/// Financial Bill entity
class Bill extends Equatable {
  final String id;
  final String tableId;
  final String? roomId;
  final String? bookingId;
  final List<String> orderIds;
  final double subTotal;
  final String taxRuleId;
  final String? serviceChargeRuleId;
  final BillTaxSummary taxSummary;
  final PaymentStatus paymentStatus;
  final PaymentMethod? paymentMethod;
  final DateTime openedAt;
  final DateTime? closedAt;
  final bool serviceChargeApplied;
  final String? serviceChargeRemovedBy;
  final String? serviceChargeRemovalReason;
  final List<BillDiscount> discounts;
  final List<BillPayment> payments;
  final String? customerId;
  final int redeemedPoints;

  const Bill({
    required this.id,
    required this.tableId,
    this.roomId,
    this.bookingId,
    required this.orderIds,
    required this.subTotal,
    required this.taxRuleId,
    this.serviceChargeRuleId,
    required this.taxSummary,
    this.paymentStatus = PaymentStatus.pending,
    this.paymentMethod,
    required this.openedAt,
    this.closedAt,
    this.serviceChargeApplied = true,
    this.serviceChargeRemovedBy,
    this.serviceChargeRemovalReason,
    this.discounts = const [],
    this.payments = const [],
    this.customerId,
    this.redeemedPoints = 0,
  });

  Bill copyWith({
    String? id,
    String? tableId,
    String? roomId,
    String? bookingId,
    List<String>? orderIds,
    double? subTotal,
    String? taxRuleId,
    String? serviceChargeRuleId,
    BillTaxSummary? taxSummary,
    PaymentStatus? paymentStatus,
    PaymentMethod? paymentMethod,
    DateTime? openedAt,
    DateTime? closedAt,
    bool? serviceChargeApplied,
    String? serviceChargeRemovedBy,
    String? serviceChargeRemovalReason,
    List<BillDiscount>? discounts,
    List<BillPayment>? payments,
    String? customerId,
    int? redeemedPoints,
  }) {
    return Bill(
      id: id ?? this.id,
      tableId: tableId ?? this.tableId,
      roomId: roomId ?? this.roomId,
      bookingId: bookingId ?? this.bookingId,
      orderIds: orderIds ?? this.orderIds,
      subTotal: subTotal ?? this.subTotal,
      taxRuleId: taxRuleId ?? this.taxRuleId,
      serviceChargeRuleId: serviceChargeRuleId ?? this.serviceChargeRuleId,
      taxSummary: taxSummary ?? this.taxSummary,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      openedAt: openedAt ?? this.openedAt,
      closedAt: closedAt ?? this.closedAt,
      serviceChargeApplied: serviceChargeApplied ?? this.serviceChargeApplied,
      serviceChargeRemovedBy:
          serviceChargeRemovedBy ?? this.serviceChargeRemovedBy,
      serviceChargeRemovalReason:
          serviceChargeRemovalReason ?? this.serviceChargeRemovalReason,
      discounts: discounts ?? this.discounts,
      payments: payments ?? this.payments,
      customerId: customerId ?? this.customerId,
      redeemedPoints: redeemedPoints ?? this.redeemedPoints,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'tableId': tableId,
    if (roomId != null) 'roomId': roomId,
    if (bookingId != null) 'bookingId': bookingId,
    'orderIds': orderIds,
    'subTotal': subTotal,
    'taxRuleId': taxRuleId,
    if (serviceChargeRuleId != null) 'serviceChargeRuleId': serviceChargeRuleId,
    'taxSummary': taxSummary.toJson(),
    'paymentStatus': paymentStatus.name,
    if (paymentMethod != null) 'paymentMethod': paymentMethod?.name,
    'openedAt': openedAt.toIso8601String(),
    if (closedAt != null) 'closedAt': closedAt?.toIso8601String(),
    'serviceChargeApplied': serviceChargeApplied,
    if (serviceChargeRemovedBy != null)
      'serviceChargeRemovedBy': serviceChargeRemovedBy,
    if (serviceChargeRemovalReason != null)
      'serviceChargeRemovalReason': serviceChargeRemovalReason,
    'discounts': discounts.map((d) => d.toJson()).toList(),
    'payments': payments.map((p) => p.toJson()).toList(),
    if (customerId != null) 'customerId': customerId,
    'redeemedPoints': redeemedPoints,
  };

  factory Bill.fromJson(Map<String, dynamic> json) => Bill(
    id: json['id'],
    tableId: json['tableId'],
    roomId: json['roomId'],
    bookingId: json['bookingId'],
    orderIds: List<String>.from(json['orderIds'] ?? []),
    subTotal: (json['subTotal'] as num).toDouble(),
    taxRuleId: json['taxRuleId'],
    serviceChargeRuleId: json['serviceChargeRuleId'],
    taxSummary: BillTaxSummary.fromJson(json['taxSummary']),
    paymentStatus: PaymentStatus.values.firstWhere(
      (e) => e.name == json['paymentStatus'],
      orElse: () => PaymentStatus.pending,
    ),
    paymentMethod: json['paymentMethod'] != null
        ? PaymentMethod.values.firstWhere(
            (e) => e.name == json['paymentMethod'],
            orElse: () => PaymentMethod.cash,
          )
        : null,
    openedAt: DateTime.parse(json['openedAt']),
    closedAt: json['closedAt'] != null
        ? DateTime.parse(json['closedAt'])
        : null,
    serviceChargeApplied: json['serviceChargeApplied'] ?? true,
    serviceChargeRemovedBy: json['serviceChargeRemovedBy'],
    serviceChargeRemovalReason: json['serviceChargeRemovalReason'],
    discounts:
        (json['discounts'] as List?)
            ?.map((d) => BillDiscount.fromJson(Map<String, dynamic>.from(d)))
            .toList() ??
        [],
    payments:
        (json['payments'] as List?)
            ?.map((p) => BillPayment.fromJson(Map<String, dynamic>.from(p)))
            .toList() ??
        [],
    customerId: json['customerId'],
    redeemedPoints: json['redeemedPoints'] ?? 0,
  );

  @override
  List<Object?> get props => [id, tableId, orderIds, paymentStatus, grandTotal];

  double get grandTotal => taxSummary.grandTotal;

  double get paidAmount => payments.fold(0.0, (sum, p) => sum + p.amount);

  double get remainingBalance => grandTotal - paidAmount;
}

/// Payment transaction for a bill
class BillPayment extends Equatable {
  final String id;
  final double amount;
  final PaymentMethod method;
  final DateTime timestamp;
  final String? reference; // Trans ID, etc.

  const BillPayment({
    required this.id,
    required this.amount,
    required this.method,
    required this.timestamp,
    this.reference,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'amount': amount,
    'method': method.name,
    'timestamp': timestamp.toIso8601String(),
    if (reference != null) 'reference': reference,
  };

  factory BillPayment.fromJson(Map<String, dynamic> json) => BillPayment(
    id: json['id'],
    amount: (json['amount'] as num).toDouble(),
    method: PaymentMethod.values.firstWhere((e) => e.name == json['method']),
    timestamp: DateTime.parse(json['timestamp']),
    reference: json['reference'],
  );

  @override
  List<Object?> get props => [id, amount, method, timestamp];
}

/// Guest Room Folio for consolidated checkout settlement
class RoomFolio extends Equatable {
  final String id;
  final String roomId;
  final String bookingId;
  final List<String> billIds; // attached restaurant/bar bills
  final double totalAmount;
  final PaymentStatus paymentStatus;

  const RoomFolio({
    required this.id,
    required this.roomId,
    required this.bookingId,
    required this.billIds,
    required this.totalAmount,
    this.paymentStatus = PaymentStatus.pending,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'roomId': roomId,
    'bookingId': bookingId,
    'billIds': billIds,
    'totalAmount': totalAmount,
    'paymentStatus': paymentStatus.name,
  };

  factory RoomFolio.fromJson(Map<String, dynamic> json) => RoomFolio(
    id: json['id'],
    roomId: json['roomId'],
    bookingId: json['bookingId'],
    billIds: List<String>.from(json['billIds'] ?? []),
    totalAmount: (json['totalAmount'] as num).toDouble(),
    paymentStatus: PaymentStatus.values.firstWhere(
      (e) => e.name == json['paymentStatus'],
      orElse: () => PaymentStatus.pending,
    ),
  );

  @override
  List<Object?> get props => [id, roomId, bookingId, billIds, paymentStatus];
}
