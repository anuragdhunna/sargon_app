/// Payment related enums and models
library;

/// Payment status for orders and bills
enum PaymentStatus {
  pending,
  billed,
  partially_paid,
  paid,
  cancelled,
  refunded,
}

extension PaymentStatusExtension on PaymentStatus {
  String get displayName {
    switch (this) {
      case PaymentStatus.pending:
        return 'Pending';
      case PaymentStatus.billed:
        return 'Billed';
      case PaymentStatus.partially_paid:
        return 'Partially Paid';
      case PaymentStatus.paid:
        return 'Paid';
      case PaymentStatus.cancelled:
        return 'Cancelled';
      case PaymentStatus.refunded:
        return 'Refunded';
    }
  }
}

/// Supported payment methods across the application
enum PaymentMethod {
  cash,
  upi,
  card,
  net_banking,
  bill_to_room,
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
      case PaymentMethod.net_banking:
        return 'Net Banking';
      case PaymentMethod.bill_to_room:
        return 'Bill to Room';
      case PaymentMethod.complimentary:
        return 'Complimentary (FOC)';
      case PaymentMethod.other:
        return 'Other / External';
    }
  }
}
