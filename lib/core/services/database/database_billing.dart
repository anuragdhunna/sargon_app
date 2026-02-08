part of '../database_service.dart';

extension DatabaseBilling on DatabaseService {
  DatabaseReference get billsRef => _ref('bills');
  DatabaseReference get taxRulesRef => _ref('taxRules');
  DatabaseReference get serviceChargeRulesRef => _ref('serviceChargeRules');
  DatabaseReference get foliosRef => _ref('folios');

  /// Get all bills (one-time fetch)
  Future<List<Bill>> getBills() async {
    final snapshot = await billsRef.get();
    if (snapshot.value == null) return [];
    final data = _toMap(snapshot.value);
    return data.entries.map((e) => Bill.fromJson(_toMap(e.value))).toList();
  }

  /// Stream all bills
  Stream<List<Bill>> streamBills() {
    return billsRef.onValue.map((event) {
      if (event.snapshot.value == null) return [];
      final data = _toMap(event.snapshot.value);
      return data.entries.map((e) => Bill.fromJson(_toMap(e.value))).toList();
    });
  }

  /// Save or Update a Bill
  Future<void> saveBill(Bill bill) async {
    await billsRef.child(bill.id).set(bill.toJson());
  }

  /// Save or Update Tax Rule
  Future<void> saveTaxRule(TaxRule rule) async {
    await taxRulesRef.child(rule.id).set(rule.toJson());
  }

  /// Delete Tax Rule (or mark inactive)
  Future<void> deleteTaxRule(String id) async {
    await taxRulesRef.child(id).remove();
  }

  /// stream tax rules
  Stream<List<TaxRule>> streamTaxRules() {
    return taxRulesRef.onValue.map((event) {
      if (event.snapshot.value == null) return [];
      final data = _toMap(event.snapshot.value);
      return data.entries
          .map((e) => TaxRule.fromJson(_toMap(e.value)))
          .where((rule) => rule.isActive)
          .toList();
    });
  }

  /// Get tax rules (one-time fetch)
  Future<List<TaxRule>> getTaxRules() async {
    final snapshot = await taxRulesRef.get();
    if (snapshot.value == null) return [];
    final data = _toMap(snapshot.value);
    return data.entries
        .map((e) => TaxRule.fromJson(_toMap(e.value)))
        .where((rule) => rule.isActive)
        .toList();
  }

  /// Get service charge rules (one-time fetch)
  Future<List<ServiceChargeRule>> getServiceChargeRules() async {
    final snapshot = await serviceChargeRulesRef.get();
    if (snapshot.value == null) return [];
    final data = _toMap(snapshot.value);
    return data.entries
        .map((e) => ServiceChargeRule.fromJson(_toMap(e.value)))
        .toList();
  }

  /// Initialize default tax and service charge rules
  Future<void> initializeBillingDefaults() async {
    try {
      final taxSnapshot = await taxRulesRef.get();
      if (taxSnapshot.value == null) {
        final defaultGst = TaxRule(
          id: 'gst_5',
          name: 'GST 5%',
          cgstPercent: 2.5,
          sgstPercent: 2.5,
        );
        await taxRulesRef.child(defaultGst.id).set(defaultGst.toJson());
      }

      final scSnapshot = await serviceChargeRulesRef.get();
      if (scSnapshot.value == null) {
        final defaultSc = ServiceChargeRule(
          id: 'sc_10',
          name: 'Service Charge 10%',
          percent: 10.0,
        );
        await serviceChargeRulesRef.child(defaultSc.id).set(defaultSc.toJson());
      }
    } catch (e) {
      debugPrint('Error initializing billing defaults: $e');
    }
  }

  /// Stream Room Folio for a booking
  Stream<RoomFolio?> streamFolio(String bookingId) {
    return foliosRef.orderByChild('bookingId').equalTo(bookingId).onValue.map((
      event,
    ) {
      if (event.snapshot.value == null) return null;
      final data = _toMap(event.snapshot.value);
      if (data.isEmpty) return null;
      return RoomFolio.fromJson(_toMap(data.values.first));
    });
  }

  /// Save or Update Folio
  Future<void> saveFolio(RoomFolio folio) async {
    await foliosRef.child(folio.id).set(folio.toJson());
  }

  /// stream service charge rules
  Stream<List<ServiceChargeRule>> streamServiceChargeRules() {
    return serviceChargeRulesRef.onValue.map((event) {
      if (event.snapshot.value == null) return [];
      final data = _toMap(event.snapshot.value);
      return data.entries
          .map((e) => ServiceChargeRule.fromJson(_toMap(e.value)))
          .toList();
    });
  }

  /// Save or Update Service Charge Rule
  Future<void> saveServiceChargeRule(ServiceChargeRule rule) async {
    await serviceChargeRulesRef.child(rule.id).set(rule.toJson());
  }

  /// Get a bill by ID
  Future<Bill?> getBillById(String billId) async {
    final snapshot = await billsRef.child(billId).get();
    if (snapshot.value == null) return null;
    return Bill.fromJson(_toMap(snapshot.value));
  }

  /// Get Room Folio for a booking (one-time fetch)
  Future<RoomFolio?> getFolioByBookingId(String bookingId) async {
    final snapshot = await foliosRef
        .orderByChild('bookingId')
        .equalTo(bookingId)
        .get();
    if (snapshot.value == null) return null;
    final data = _toMap(snapshot.value);
    if (data.isEmpty) return null;
    return RoomFolio.fromJson(_toMap(data.values.first));
  }

  /// Get all bills for a customer
  Future<List<Bill>> getBillsByCustomerId(String customerId) async {
    final snapshot = await billsRef
        .orderByChild('customerId')
        .equalTo(customerId)
        .get();
    if (snapshot.value == null) return [];
    final data = _toMap(snapshot.value);
    return data.entries.map((e) => Bill.fromJson(_toMap(e.value))).toList();
  }
}
