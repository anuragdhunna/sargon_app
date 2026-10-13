import 'package:flutter/foundation.dart';
import 'package:hotel_manager/core/models/models.dart';
import 'package:hotel_manager/core/services/audit_service.dart';
import 'package:hotel_manager/core/services/database/interfaces/billing_database.dart';
import 'package:hotel_manager/core/services/database_service.dart';

/// Processor handling post-payment lifecycle side-effects:
/// loyalty point accrual, folio aggregation, and batch folio settlement.
class BillingSettlementProcessor {
  const BillingSettlementProcessor();

  /// Award loyalty points for settled customer bills (1 point per ₹100)
  Future<void> awardLoyaltyPoints({
    required IBillingDatabase databaseService,
    required String hotelId,
    required Bill bill,
  }) async {
    if (bill.customerId == null) return;

    try {
      if (databaseService is! DatabaseService) return;
      final db = databaseService;
      final points = (bill.grandTotal / 100).floor();
      if (points <= 0) return;

      final customer = await db.getCustomer(hotelId, bill.customerId!);
      if (customer == null) return;

      final currentLoyalty = customer.loyaltyInfo ??
          const LoyaltyInfo(
            tierId: 'bronze',
            totalPoints: 0,
            availablePoints: 0,
            lifetimeSpend: 0,
          );

      final newLoyalty = currentLoyalty.copyWith(
        totalPoints: currentLoyalty.totalPoints + points,
        availablePoints: currentLoyalty.availablePoints + points,
        lifetimeSpend: currentLoyalty.lifetimeSpend + bill.grandTotal,
      );

      final updatedCustomer = customer.copyWith(loyaltyInfo: newLoyalty);
      await db.saveCustomer(updatedCustomer);
      debugPrint(
        'Loyalty points awarded: $points to customer ${bill.customerId}',
      );
    } catch (e) {
      debugPrint('Error awarding loyalty points: $e');
    }
  }

  /// Attach a room-service bill to the guest booking folio
  Future<void> attachBillToFolio({
    required IBillingDatabase databaseService,
    required String hotelId,
    required String bookingId,
    required Bill bill,
  }) async {
    final existingFolio = await databaseService.getFolioByBookingId(
      hotelId,
      bookingId,
    );

    RoomFolio folio;
    if (existingFolio != null) {
      final updatedBillIds = [...existingFolio.billIds, bill.id];
      folio = existingFolio.copyWith(
        billIds: updatedBillIds,
        totalAmount: existingFolio.totalAmount + bill.grandTotal,
      );
    } else {
      folio = RoomFolio(
        id: 'folio_${DateTime.now().millisecondsSinceEpoch}',
        hotelId: hotelId,
        roomId: bill.roomId ?? 'unknown',
        bookingId: bookingId,
        billIds: [bill.id],
        totalAmount: bill.grandTotal,
      );
    }

    await databaseService.saveFolio(folio);
  }

  /// Settle all outstanding bills tied to a booking folio
  Future<void> settleFolio({
    required IBillingDatabase databaseService,
    required AuditService auditService,
    required String hotelId,
    required String bookingId,
    required PaymentMethod method,
    required List<Bill> bills,
    String? reference,
  }) async {
    final folio = await databaseService.getFolioByBookingId(
      hotelId,
      bookingId,
    );
    if (folio == null) return;

    final billsToSettle = bills
        .where(
          (b) =>
              folio.billIds.contains(b.id) &&
              b.paymentStatus != PaymentStatus.paid,
        )
        .toList();

    for (final bill in billsToSettle) {
      final payment = BillPayment(
        id: 'pay_${DateTime.now().millisecondsSinceEpoch}_${bill.id}',
        amount: bill.remainingBalance,
        method: method,
        timestamp: DateTime.now(),
        reference: reference ?? 'Folio Settlement',
      );

      final updatedBill = bill.copyWith(
        payments: [...bill.payments, payment],
        paymentStatus: PaymentStatus.paid,
        closedAt: DateTime.now(),
      );

      await databaseService.saveBill(updatedBill);

      for (final orderId in bill.orderIds) {
        await databaseService.updateOrderPaymentStatus(
          hotelId,
          orderId,
          PaymentStatus.paid,
        );
      }
    }

    final updatedFolio = folio.copyWith(paymentStatus: PaymentStatus.paid);
    await databaseService.saveFolio(updatedFolio);

    await auditService.log(
      hotelId: hotelId,
      performedBy: 'system',
      performedByRole: 'finance',
      action: AuditAction.update,
      targetUserId: bookingId,
      description: 'Folio $bookingId settled via ${method.name}',
    );
  }
}
