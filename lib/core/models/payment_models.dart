/// Payment related enums and models
library;

/// Payment status for orders and bills
enum PaymentStatus {
  pending,
  billed,
  partiallyPaid,
  paid,
  cancelled,
  refunded,
  toRoom,
}

extension PaymentStatusExtension on PaymentStatus {
  String get displayName {
    switch (this) {
      case PaymentStatus.pending:
        return 'Pending';
      case PaymentStatus.billed:
        return 'Billed';
      case PaymentStatus.partiallyPaid:
        return 'Partially Paid';
      case PaymentStatus.paid:
        return 'Paid';
      case PaymentStatus.cancelled:
        return 'Cancelled';
      case PaymentStatus.refunded:
        return 'Refunded';
      case PaymentStatus.toRoom:
        return 'Billed to Room';
    }
  }
}

/// Supported payment methods across the application
enum PaymentMethod {
  cash,
  upi,
  card,
  netBanking,
  billToRoom,
  complimentary,
  other,
}

extension PaymentMethodExtension on PaymentMethod {
  String get displayName {
    switch (this) {
      case PaymentMethod.cash:
        return 'Cash';
      case PaymentMethod.upi:
        return 'UPI / QR Scan';
      case PaymentMethod.card:
        return 'Credit/Debit Card';
      case PaymentMethod.netBanking:
        return 'Net Banking';
      case PaymentMethod.billToRoom:
        return 'Bill to Room';
      case PaymentMethod.complimentary:
        return 'Complimentary (FOC)';
      case PaymentMethod.other:
        return 'Other / External';
    }
  }
}
