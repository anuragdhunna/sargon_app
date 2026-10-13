import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hotel_manager/core/models/models.dart';
import 'package:hotel_manager/core/services/database/interfaces/billing_database.dart';
import 'package:hotel_manager/core/services/database_service.dart';
import 'package:hotel_manager/core/services/audit_service.dart';
import 'package:hotel_manager/features/billing/logic/billing_settlement_processor.dart';
import 'package:hotel_manager/features/billing/logic/billing_state.dart';
import 'package:hotel_manager/features/billing/logic/discount_calculator.dart';

class BillingCubit extends Cubit<BillingState> {
  final IBillingDatabase _databaseService;
  final AuditService _auditService;
  final BillingSettlementProcessor _settlementProcessor;
  List<Bill> _bills = [];
  List<TaxRule> _taxRules = [];
  List<ServiceChargeRule> _scRules = [];
  List<Offer> _offers = [];
  StreamSubscription? _billsSubscription;
  StreamSubscription? _taxSubscription;
  StreamSubscription? _scSubscription;
  StreamSubscription? _offersSubscription;

  BillingCubit({
    required IBillingDatabase databaseService,
    AuditService? auditService,
    BillingSettlementProcessor? settlementProcessor,
  }) : _databaseService = databaseService,
       _auditService = auditService ?? AuditService(),
       _settlementProcessor =
           settlementProcessor ?? const BillingSettlementProcessor(),
       super(BillingInitial());

  Future<void> loadBillingData({required String hotelId}) async {
    // Proactively set defaults to avoid any "not loaded" state
    _taxRules = [
      TaxRule(
        id: 'gst_5',
        hotelId: hotelId,
        name: 'GST 5%',
        cgstPercent: 2.5,
        sgstPercent: 2.5,
      ),
    ];
    _scRules = [
      ServiceChargeRule(
        id: 'sc_10',
        hotelId: hotelId,
        name: 'Service Charge 10%',
        percent: 10.0,
      ),
    ];
    _emitLoaded();

    _billsSubscription?.cancel();
    _offersSubscription?.cancel();

    try {
      // Attempt to fetch live rules, but don't crash if it fails (permission-denied fallback)
      final taxRules = await _databaseService
          .getTaxRules(hotelId)
          .catchError((e) => <TaxRule>[]);
      final scRules = await _databaseService
          .getServiceChargeRules(hotelId)
          .catchError((e) => <ServiceChargeRule>[]);

      if (taxRules.isNotEmpty) _taxRules = taxRules;
      if (scRules.isNotEmpty) _scRules = scRules;

      // Stream Bills (safely)
      _billsSubscription = _databaseService
          .streamBills(hotelId)
          .listen(
            (bills) {
              _bills = bills;
              _emitLoaded();
            },
            onError: (e) {
              debugPrint('Bill stream permission issue (non-fatal): $e');
              _emitLoaded(); // Keep using defaults
            },
          );

      // Stream Offers (safely)
      if (_databaseService is DatabaseService) {
        _offersSubscription = (_databaseService).streamOffers(hotelId).listen((
          offers,
        ) {
          _offers = offers;
          _emitLoaded();
        });
      }

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
        offers: _offers,
      ),
    );
  }

  /// Create a bill from one or more orders
  Future<String> createBill({
    required String hotelId,
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

    // Consolidate order-level discounts for tracking
    final List<BillDiscount> trackingDiscounts = [];
    for (var order in orders) {
      if (order.appliedOfferId != null &&
          !manualDiscounts.any((o) => o.id == order.appliedOfferId)) {
        trackingDiscounts.add(
          BillDiscount(
            id: 'disc_tr_${order.id}_${DateTime.now().millisecondsSinceEpoch}',
            offerId: order.appliedOfferId!,
            name: order.appliedOfferName ?? 'Order Offer',
            discountType: DiscountType.flat, // Amount already in items
            discountValue: 0,
            discountAmount: order.items.fold(
              0.0,
              (s, i) => s + i.discountAmount,
            ),
            reason: 'Applied at order level',
            appliedAt: DateTime.now(),
            appliedBy: 'system',
          ),
        );
      }
    }

    final bill = Bill(
      hotelId: hotelId,
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
      discounts: [
        ...trackingDiscounts,
        ...manualDiscounts.map((o) {
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
        }),
      ],
    );

    await _databaseService.saveBill(bill);

    // If it's a room bill, attach to folio
    if (bookingId != null) {
      await _settlementProcessor.attachBillToFolio(
        databaseService: _databaseService,
        hotelId: hotelId,
        bookingId: bookingId,
        bill: bill,
      );
    }

    // Update order statuses to billed
    for (final orderId in orders.map((o) => o.id)) {
      await _databaseService.updateOrderPaymentStatus(
        hotelId,
        orderId,
        PaymentStatus.billed,
      );
    }

    // Update table status to billed
    await _databaseService.updateTableStatus(
      hotelId,
      tableId,
      TableStatus.billed,
    );

    // Audit Log
    await _auditService.logUserAction(
      performer: const User(
        id: 'system',
        name: 'System',
        phoneNumber: '',
        role: UserRole.staff,
      ), // Fallback to system for automated bills
      action: AuditAction.create,
      targetUserId: bill.id,
      description:
          'System generated bill for Table $tableId. Total: ₹${bill.grandTotal}',
      newData: bill.toJson(),
    );

    return bill.id;
  }

  /// Manually apply a discount to an existing bill
  Future<void> applyBillDiscount(
    String billId,
    Offer offer,
    String userId,
    String hotelId,
  ) async {
    final currentState = state;
    if (currentState is! BillingLoaded) return;

    final bill = currentState.bills.firstWhere((b) => b.id == billId);

    // Check if discount already applied
    if (bill.discounts.any((d) => d.offerId == offer.id)) return;

    final updatedDiscounts = [...bill.discounts];

    // For manual application, we need to recalculate the whole tax summary
    // Since manual discounts are usually bill-level
    final orders = await _databaseService.getOrdersByIds(
      hotelId,
      bill.orderIds,
    );
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
          hotelId: hotelId,
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
      hotelId: hotelId,
      performedBy: userId,
      performedByRole: 'finance',
      action: AuditAction.update,
      targetUserId: billId,
      description: 'Applied discount ${offer.name} to bill $billId',
      newData: newBillDiscount.toJson(),
    );
  }

  /// Add a payment to an existing bill
  Future<void> addPayment({
    required String billId,
    required double amount,
    required PaymentMethod method,
    required String hotelId,
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
      paymentStatus: method == PaymentMethod.billToRoom
          ? PaymentStatus.toRoom
          : (totalPaid >= bill.grandTotal
                ? PaymentStatus.paid
                : PaymentStatus.partiallyPaid),
      closedAt: totalPaid >= bill.grandTotal ? DateTime.now() : null,
    );

    await _databaseService.saveBill(updatedBill);

    // If fully paid, award loyalty points
    if (totalPaid >= updatedBill.grandTotal && updatedBill.customerId != null) {
      await _settlementProcessor.awardLoyaltyPoints(
        databaseService: _databaseService,
        hotelId: hotelId,
        bill: updatedBill,
      );
    }

    // If fully paid or billed to room, handle downstream updates
    if (totalPaid >= updatedBill.grandTotal ||
        method == PaymentMethod.billToRoom) {
      // If billed to room, attach to folio
      if (method == PaymentMethod.billToRoom && bookingId != null) {
        await _settlementProcessor.attachBillToFolio(
          databaseService: _databaseService,
          hotelId: hotelId,
          bookingId: bookingId,
          bill: updatedBill,
        );
      }

      // Update order statuses
      final orderStatus = method == PaymentMethod.billToRoom
          ? PaymentStatus.toRoom
          : PaymentStatus.paid;

      for (final orderId in bill.orderIds) {
        await _databaseService.updateOrderPaymentStatus(
          hotelId,
          orderId,
          orderStatus,
        );
      }

      // Table status: cleaning if settled, but if billed to room it might also be free
      await _databaseService.updateTableStatus(
        hotelId,
        bill.tableId,
        TableStatus.cleaning,
      );
    }

    // Audit Log
    await _auditService.log(
      hotelId: hotelId,
      performedBy: 'system',
      performedByRole: 'finance',
      action: AuditAction.update,
      targetUserId: updatedBill.id,
      description:
          'Payment of ₹$amount received via ${method.name} for Bill $billId',
      newData: payment.toJson(),
    );
  }

  /// Settle all charges in a folio
  Future<void> settleFolio({
    required String bookingId,
    required String hotelId,
    required PaymentMethod method,
    String? reference,
  }) async {
    final currentState = state;
    if (currentState is! BillingLoaded) return;

    await _settlementProcessor.settleFolio(
      databaseService: _databaseService,
      auditService: _auditService,
      hotelId: hotelId,
      bookingId: bookingId,
      method: method,
      bills: currentState.bills,
      reference: reference,
    );
  }

  Future<void> deleteServiceChargeRule(String hotelId, String id) async {
    try {
      await _databaseService.deleteServiceChargeRule(hotelId, id);
      // Local state is updated via subscription if active, otherwise we fetch
      if (_scSubscription == null) {
        final rules = await _databaseService.getServiceChargeRules(hotelId);
        _scRules = rules;
        _emitLoaded();
      }
    } catch (e) {
      debugPrint('Error deleting service charge rule: $e');
    }
  }

  @override
  Future<void> close() {
    _billsSubscription?.cancel();
    _taxSubscription?.cancel();
    _scSubscription?.cancel();
    _offersSubscription?.cancel();
    return super.close();
  }
}
