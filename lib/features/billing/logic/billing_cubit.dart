import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hotel_manager/core/models/models.dart';
import 'package:hotel_manager/core/services/database_service.dart';
import 'package:hotel_manager/core/services/audit_service.dart';
import 'package:hotel_manager/features/billing/logic/billing_state.dart';

class BillingCubit extends Cubit<BillingState> {
  final DatabaseService _databaseService;
  List<Bill> _bills = [];
  List<TaxRule> _taxRules = [];
  List<ServiceChargeRule> _scRules = [];
  StreamSubscription? _billsSubscription;
  StreamSubscription? _taxSubscription;
  StreamSubscription? _scSubscription;

  BillingCubit({required DatabaseService databaseService})
    : _databaseService = databaseService,
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
  Future<void> createBill({
    required String tableId,
    required List<Order> orders,
    required String taxRuleId,
    String? serviceChargeRuleId,
    String? roomId,
    String? bookingId,
  }) async {
    final subTotal = orders.fold(0.0, (sum, o) => sum + o.totalPrice);

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

    final scAmount = (serviceChargeRuleId != null && scRule != null)
        ? (subTotal * scRule.percent / 100)
        : 0.0;
    final taxableAmount = subTotal + scAmount;
    final cgst = taxableAmount * taxRule.cgstPercent / 100;
    final sgst = taxableAmount * taxRule.sgstPercent / 100;
    final totalTax = cgst + sgst;
    final grandTotal = taxableAmount + totalTax;

    final taxSummary = BillTaxSummary(
      subTotal: subTotal,
      serviceChargeAmount: scAmount,
      taxableAmount: taxableAmount,
      cgstAmount: cgst,
      sgstAmount: sgst,
      igstAmount: 0,
      totalTax: totalTax,
      grandTotal: grandTotal,
    );

    final bill = Bill(
      id: 'bill_${DateTime.now().millisecondsSinceEpoch}',
      tableId: tableId,
      roomId: roomId,
      bookingId: bookingId,
      orderIds: orders.map((o) => o.id).toList(),
      subTotal: subTotal,
      taxRuleId: taxRuleId,
      serviceChargeRuleId: serviceChargeRuleId,
      taxSummary: taxSummary,
      openedAt: DateTime.now(),
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
    await AuditService().log(
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
      paymentStatus: totalPaid >= bill.grandTotal
          ? PaymentStatus.paid
          : PaymentStatus.partially_paid,
      closedAt: totalPaid >= bill.grandTotal ? DateTime.now() : null,
    );

    await _databaseService.saveBill(updatedBill);

    // If fully paid or billed to room, handle downstream updates
    if (totalPaid >= updatedBill.grandTotal ||
        method == PaymentMethod.bill_to_room) {
      // If billed to room, attach to folio
      if (method == PaymentMethod.bill_to_room && bookingId != null) {
        await _attachBillToFolio(bookingId, updatedBill);
      }

      for (final orderId in bill.orderIds) {
        await _databaseService.updateOrderPaymentStatus(
          orderId,
          PaymentStatus.paid,
        );
      }
      await _databaseService.updateTableStatus(
        bill.tableId,
        TableStatus.cleaning,
      );
    }

    // Audit Log
    await AuditService().log(
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
    // Check if folio exists
    final snapshot = await _databaseService.foliosRef
        .orderByChild('bookingId')
        .equalTo(bookingId)
        .get();

    RoomFolio folio;
    if (snapshot.value != null) {
      final data = (snapshot.value as Map).values.first;
      final existingFolio = RoomFolio.fromJson(_databaseService.toMap(data));
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
