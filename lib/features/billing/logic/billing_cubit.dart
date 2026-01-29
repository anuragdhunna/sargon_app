import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hotel_manager/core/models/models.dart';
import 'package:hotel_manager/core/services/database/interfaces/billing_database.dart';
import 'package:hotel_manager/core/services/database_service.dart';
import 'package:hotel_manager/core/services/audit_service.dart';
import 'package:hotel_manager/features/billing/logic/billing_state.dart';
import 'package:hotel_manager/features/billing/logic/discount_calculator.dart';

class BillingCubit extends Cubit<BillingState> {
  final IBillingDatabase _databaseService;
  final AuditService _auditService;
  List<Bill> _bills = [];
  List<TaxRule> _taxRules = [];
  List<ServiceChargeRule> _scRules = [];
  StreamSubscription? _billsSubscription;
  StreamSubscription? _taxSubscription;
  StreamSubscription? _scSubscription;

  BillingCubit({
    required IBillingDatabase databaseService,
    AuditService? auditService,
  }) : _databaseService = databaseService,
       _auditService = auditService ?? AuditService(),
       super(BillingInitial());

  Future<void> loadBillingData() async {
    // Proactively set defaults to avoid any "not loaded" state
    _taxRules = [
      TaxRule(id: 'gst_5', name: 'GST 5%', cgstPercent: 2.5, sgstPercent: 2.5),
    ];
    _scRules = [
      ServiceChargeRule(id: 'sc_10', name: 'Service Charge 10%', percent: 10.0),
    ];
    _emitLoaded();

    _billsSubscription?.cancel();

    try {
      // Attempt to fetch live rules, but don't crash if it fails (permission-denied fallback)
      final taxRules = await _databaseService.getTaxRules().catchError(
        (e) => <TaxRule>[],
      );
      final scRules = await _databaseService.getServiceChargeRules().catchError(
        (e) => <ServiceChargeRule>[],
      );

      if (taxRules.isNotEmpty) _taxRules = taxRules;
      if (scRules.isNotEmpty) _scRules = scRules;

      // Stream Bills (safely)
      _billsSubscription = _databaseService.streamBills().listen(
        (bills) {
          _bills = bills;
          _emitLoaded();
        },
        onError: (e) {
          debugPrint('Bill stream permission issue (non-fatal): $e');
          _emitLoaded(); // Keep using defaults
        },
      );

      _emitLoaded();
    } catch (e) {
      debugPrint('Billing data initialization failed, using defaults: $e');
      _emitLoaded();
    }
  }

  void _emitLoaded() {
    emit(
      BillingLoaded(
        bills: _bills,
        taxRules: _taxRules,
        serviceChargeRules: _scRules,
      ),
    );
  }

  /// Create a bill from one or more orders
  Future<String> createBill({
    required String tableId,
    required List<Order> orders,
    required String taxRuleId,
    String? serviceChargeRuleId,
    String? roomId,
    String? bookingId,
    List<Offer> manualDiscounts = const [],
    String? customerId,
    int redeemedPoints = 0,
  }) async {
    final currentState = state;
    if (currentState is! BillingLoaded) {
      throw Exception('Billing data not loaded');
    }

    final taxRule = currentState.taxRules.firstWhere(
      (r) => r.id == taxRuleId,
      orElse: () => currentState.taxRules.first,
    );

    final scRule = serviceChargeRuleId != null
        ? currentState.serviceChargeRules.firstWhere(
            (r) => r.id == serviceChargeRuleId,
            orElse: () => currentState.serviceChargeRules.first,
          )
        : null;

    final taxSummary = DiscountCalculator.calculateTaxSummary(
      orders: orders,
      taxRule: taxRule,
      scRule: scRule,
      manualDiscounts: manualDiscounts,
      loyaltyPointsRedeemed: redeemedPoints,
    );

    final bill = Bill(
      id: 'bill_${DateTime.now().millisecondsSinceEpoch}',
      tableId: tableId,
      roomId: roomId,
      bookingId: bookingId,
      orderIds: orders.map((o) => o.id).toList(),
      subTotal: taxSummary.subTotal,
      taxRuleId: taxRuleId,
      serviceChargeRuleId: serviceChargeRuleId,
      taxSummary: taxSummary,
      openedAt: DateTime.now(),
      customerId: customerId,
      redeemedPoints: redeemedPoints,
      discounts: manualDiscounts.map((o) {
        double discountAmount = 0.0;
        if (o.discountType == DiscountType.percent) {
          // Discount is calculated on taxable subtotal (pre-tax)
          discountAmount =
              (taxSummary.taxableAmount - taxSummary.serviceChargeAmount) *
              (o.discountValue / 100);
        } else {
          discountAmount = o.discountValue;
        }

        return BillDiscount(
          id: 'disc_${DateTime.now().millisecondsSinceEpoch}',
          offerId: o.id,
          name: o.name,
          discountType: o.discountType,
          discountValue: o.discountValue,
          discountAmount: discountAmount,
          reason: o.description ?? 'Applied',
          appliedAt: DateTime.now(),
          appliedBy: 'system', // Replace with actual user ID
        );
      }).toList(),
    );

    await _databaseService.saveBill(bill);

    // If it's a room bill, attach to folio
    if (bookingId != null) {
      await _attachBillToFolio(bookingId, bill);
    }

    // Update order statuses to billed
    for (final orderId in orders.map((o) => o.id)) {
      await _databaseService.updateOrderPaymentStatus(
        orderId,
        PaymentStatus.billed,
      );
    }

    // Update table status to billed
    await _databaseService.updateTableStatus(tableId, TableStatus.billed);

    // Audit Log
    await _auditService.log(
      userId: 'system',
      userName: 'Billing System',
      userRole: 'finance',
      action: AuditAction.create,
      entity: 'bill',
      entityId: bill.id,
      description:
          'System generated bill for Table $tableId. Total: ₹${bill.grandTotal}',
      metadata: bill.toJson(),
    );

    return bill.id;
  }

  /// Manually apply a discount to an existing bill
  Future<void> applyBillDiscount(
    String billId,
    Offer offer,
    String userId,
  ) async {
    final currentState = state;
    if (currentState is! BillingLoaded) return;

    final bill = currentState.bills.firstWhere((b) => b.id == billId);

    // Check if discount already applied
    if (bill.discounts.any((d) => d.offerId == offer.id)) return;

    final updatedDiscounts = [...bill.discounts];

    // For manual application, we need to recalculate the whole tax summary
    // Since manual discounts are usually bill-level
    final orders = await _databaseService.getOrdersByIds(bill.orderIds);
    final taxRule = currentState.taxRules.firstWhere(
      (r) => r.id == bill.taxRuleId,
    );
    final scRule = bill.serviceChargeRuleId != null
        ? currentState.serviceChargeRules.firstWhere(
            (r) => r.id == bill.serviceChargeRuleId,
          )
        : null;

    final manualOffers = [
      ...updatedDiscounts.map(
        (d) => Offer(
          id: d.offerId,
          name: d.name,
          offerType: OfferType.bill,
          discountType: d.discountType,
          discountValue: d.discountValue,
        ),
      ),
      offer,
    ];

    final newTaxSummary = DiscountCalculator.calculateTaxSummary(
      orders: orders,
      taxRule: taxRule,
      scRule: scRule,
      manualDiscounts: manualOffers,
    );

    double discountAmount = 0.0;
    if (offer.discountType == DiscountType.percent) {
      discountAmount =
          (newTaxSummary.taxableAmount - newTaxSummary.serviceChargeAmount) *
          (offer.discountValue / 100);
    } else {
      discountAmount = offer.discountValue;
    }

    final newBillDiscount = BillDiscount(
      id: 'disc_${DateTime.now().millisecondsSinceEpoch}',
      offerId: offer.id,
      name: offer.name,
      discountType: offer.discountType,
      discountValue: offer.discountValue,
      discountAmount: discountAmount,
      reason: offer.description ?? 'Manual override',
      appliedAt: DateTime.now(),
      appliedBy: userId,
    );

    final updatedBill = bill.copyWith(
      discounts: [...bill.discounts, newBillDiscount],
      taxSummary: newTaxSummary,
      subTotal: newTaxSummary.subTotal,
    );

    await _databaseService.saveBill(updatedBill);

    // Audit Log
    await _auditService.log(
      userId: userId,
      userName: 'Staff',
      userRole: 'finance',
      action: AuditAction.update,
      entity: 'bill_discount',
      entityId: billId,
      description: 'Applied discount ${offer.name} to bill $billId',
      metadata: newBillDiscount.toJson(),
    );
  }

  /// Add a payment to an existing bill
  Future<void> addPayment({
    required String billId,
    required double amount,
    required PaymentMethod method,
    String? reference,
    String? roomId,
    String? bookingId,
  }) async {
    final currentState = state;
    if (currentState is! BillingLoaded) return;

    final bill = currentState.bills.firstWhere((b) => b.id == billId);
    final payment = BillPayment(
      id: 'pay_${DateTime.now().millisecondsSinceEpoch}',
      amount: amount,
      method: method,
      timestamp: DateTime.now(),
      reference: reference,
    );

    final updatedPayments = [...bill.payments, payment];
    final totalPaid = updatedPayments.fold(0.0, (sum, p) => sum + p.amount);

    final updatedBill = bill.copyWith(
      payments: updatedPayments,
      roomId: roomId ?? bill.roomId,
      bookingId: bookingId ?? bill.bookingId,
      paymentStatus: method == PaymentMethod.bill_to_room
          ? PaymentStatus.toRoom
          : (totalPaid >= bill.grandTotal
                ? PaymentStatus.paid
                : PaymentStatus.partially_paid),
      closedAt: totalPaid >= bill.grandTotal ? DateTime.now() : null,
    );

    await _databaseService.saveBill(updatedBill);

    // If fully paid, award loyalty points
    if (totalPaid >= updatedBill.grandTotal && updatedBill.customerId != null) {
      try {
        final db =
            _databaseService
                as DatabaseService; // Cast to access loyalty methods
        final points = (updatedBill.grandTotal / 100).floor();
        if (points > 0) {
          // Fetch current loyalty info or start fresh
          final customerSnap = await db.customersRef
              .child(updatedBill.customerId!)
              .get();
          if (customerSnap.exists) {
            final customerData = db.toMap(customerSnap.value);
            final customer = Customer.fromJson(customerData);
            final currentLoyalty =
                customer.loyaltyInfo ??
                const LoyaltyInfo(
                  tierId: 'bronze',
                  totalPoints: 0,
                  availablePoints: 0,
                  lifetimeSpend: 0,
                );

            final newLoyalty = currentLoyalty.copyWith(
              totalPoints: currentLoyalty.totalPoints + points,
              availablePoints: currentLoyalty.availablePoints + points,
              lifetimeSpend:
                  currentLoyalty.lifetimeSpend + updatedBill.grandTotal,
            );

            final updatedCustomer = customer.copyWith(loyaltyInfo: newLoyalty);

            await db.saveCustomer(updatedCustomer);
            debugPrint(
              'Loyalty points awarded: $points to customer ${updatedBill.customerId}',
            );
          }
        }
      } catch (e) {
        debugPrint('Error awarding loyalty points: $e');
      }
    }

    // If fully paid or billed to room, handle downstream updates
    if (totalPaid >= updatedBill.grandTotal ||
        method == PaymentMethod.bill_to_room) {
      // If billed to room, attach to folio
      if (method == PaymentMethod.bill_to_room && bookingId != null) {
        await _attachBillToFolio(bookingId, updatedBill);
      }

      // Update order statuses
      final orderStatus = method == PaymentMethod.bill_to_room
          ? PaymentStatus.toRoom
          : PaymentStatus.paid;

      for (final orderId in bill.orderIds) {
        await _databaseService.updateOrderPaymentStatus(orderId, orderStatus);
      }

      // Table status: cleaning if settled, but if billed to room it might also be free
      await _databaseService.updateTableStatus(
        bill.tableId,
        TableStatus.cleaning,
      );
    }

    // Audit Log
    await _auditService.log(
      userId: 'system',
      userName: 'Billing System',
      userRole: 'finance',
      action: AuditAction.update,
      entity: 'payment',
      entityId: updatedBill.id,
      description:
          'Payment of ₹$amount received via ${method.name} for Bill $billId',
      metadata: payment.toJson(),
    );
  }

  Future<void> _attachBillToFolio(String bookingId, Bill bill) async {
    final existingFolio = await _databaseService.getFolioByBookingId(bookingId);

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
        roomId: bill.roomId ?? 'unknown',
        bookingId: bookingId,
        billIds: [bill.id],
        totalAmount: bill.grandTotal,
      );
    }

    await _databaseService.saveFolio(folio);
  }

  /// Settle all charges in a folio
  Future<void> settleFolio({
    required String bookingId,
    required PaymentMethod method,
    String? reference,
  }) async {
    final folio = await _databaseService.getFolioByBookingId(bookingId);
    if (folio == null) return;

    final currentState = state;
    if (currentState is! BillingLoaded) return;

    // Get all bills linked to this folio that are not 'paid'
    final billsToSettle = currentState.bills
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

      await _databaseService.saveBill(updatedBill);

      // Update order statuses to paid
      for (final orderId in bill.orderIds) {
        await _databaseService.updateOrderPaymentStatus(
          orderId,
          PaymentStatus.paid,
        );
      }
    }

    // Update folio status
    final updatedFolio = folio.copyWith(paymentStatus: PaymentStatus.paid);
    await _databaseService.saveFolio(updatedFolio);

    // Audit Log
    await _auditService.log(
      userId: 'system',
      userName: 'Billing System',
      userRole: 'finance',
      action: AuditAction.update,
      entity: 'folio',
      entityId: bookingId,
      description: 'Folio $bookingId settled via ${method.name}',
    );
  }

  @override
  Future<void> close() {
    _billsSubscription?.cancel();
    _taxSubscription?.cancel();
    _scSubscription?.cancel();
    return super.close();
  }
}

extension on RoomFolio {
  RoomFolio copyWith({
    List<String>? billIds,
    double? totalAmount,
    PaymentStatus? paymentStatus,
  }) {
    return RoomFolio(
      id: id,
      roomId: roomId,
      bookingId: bookingId,
      billIds: billIds ?? this.billIds,
      totalAmount: totalAmount ?? this.totalAmount,
      paymentStatus: paymentStatus ?? this.paymentStatus,
    );
  }
}
