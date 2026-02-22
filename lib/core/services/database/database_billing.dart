part of '../database_service.dart';

extension DatabaseBilling on DatabaseService {
  CollectionReference _billsRef(String hotelId) =>
      _hotelDoc(hotelId).collection('bills');
  CollectionReference _taxRulesRef(String hotelId) =>
      _hotelDoc(hotelId).collection('taxRules');
  CollectionReference _serviceChargeRulesRef(String hotelId) =>
      _hotelDoc(hotelId).collection('serviceChargeRules');
  CollectionReference _foliosRef(String hotelId) =>
      _hotelDoc(hotelId).collection('folios');

  /// Get all bills (one-time fetch)
  Future<List<Bill>> getBills(String hotelId) async {
    final snapshot = await _billsRef(hotelId).get();
    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return Bill.fromJson(data);
    }).toList();
  }

  /// Stream all bills
  Stream<List<Bill>> streamBills(String hotelId) {
    return _billsRef(hotelId).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Bill.fromJson(data);
      }).toList();
    });
  }

  /// Save or Update a Bill
  Future<void> saveBill(Bill bill) async {
    await _billsRef(bill.hotelId).doc(bill.id).set(bill.toJson());
  }

  /// Save or Update Tax Rule
  Future<void> saveTaxRule(TaxRule rule) async {
    await _taxRulesRef(rule.hotelId).doc(rule.id).set(rule.toJson());
  }

  /// Delete Tax Rule (or mark inactive)
  Future<void> deleteTaxRule(String hotelId, String id) async {
    await _taxRulesRef(hotelId).doc(id).delete();
  }

  /// stream tax rules
  Stream<List<TaxRule>> streamTaxRules(String hotelId) {
    return _taxRulesRef(hotelId).snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => TaxRule.fromJson(doc.data() as Map<String, dynamic>))
          .where((rule) => rule.isActive)
          .toList();
    });
  }

  /// Get tax rules (one-time fetch)
  Future<List<TaxRule>> getTaxRules(String hotelId) async {
    final snapshot = await _taxRulesRef(hotelId).get();
    return snapshot.docs
        .map((doc) => TaxRule.fromJson(doc.data() as Map<String, dynamic>))
        .where((rule) => rule.isActive)
        .toList();
  }

  /// Get service charge rules (one-time fetch)
  Future<List<ServiceChargeRule>> getServiceChargeRules(String hotelId) async {
    final snapshot = await _serviceChargeRulesRef(hotelId).get();
    return snapshot.docs
        .map(
          (doc) =>
              ServiceChargeRule.fromJson(doc.data() as Map<String, dynamic>),
        )
        .toList();
  }

  /// Initialize default tax and service charge rules
  Future<void> initializeBillingDefaults(String hotelId) async {
    try {
      final taxSnapshot = await _taxRulesRef(hotelId).limit(1).get();
      if (taxSnapshot.docs.isEmpty) {
        final defaultGst = TaxRule(
          id: 'gst_5',
          hotelId: hotelId,
          name: 'GST 5%',
          cgstPercent: 2.5,
          sgstPercent: 2.5,
        );
        await _taxRulesRef(hotelId).doc(defaultGst.id).set(defaultGst.toJson());
      }

      final scSnapshot = await _serviceChargeRulesRef(hotelId).limit(1).get();
      if (scSnapshot.docs.isEmpty) {
        final defaultSc = ServiceChargeRule(
          id: 'sc_10',
          hotelId: hotelId,
          name: 'Service Charge 10%',
          percent: 10.0,
        );
        await _serviceChargeRulesRef(
          hotelId,
        ).doc(defaultSc.id).set(defaultSc.toJson());
      }
    } catch (e) {
      debugPrint('Error initializing billing defaults: $e');
    }
  }

  /// Stream Room Folio for a booking
  Stream<RoomFolio?> streamFolio(String hotelId, String bookingId) {
    return _foliosRef(
      hotelId,
    ).where('bookingId', isEqualTo: bookingId).snapshots().map((snapshot) {
      if (snapshot.docs.isEmpty) return null;
      return RoomFolio.fromJson(
        snapshot.docs.first.data() as Map<String, dynamic>,
      );
    });
  }

  /// Save or Update Folio
  Future<void> saveFolio(RoomFolio folio) async {
    await _foliosRef(folio.hotelId).doc(folio.id).set(folio.toJson());
  }

  /// stream service charge rules
  Stream<List<ServiceChargeRule>> streamServiceChargeRules(String hotelId) {
    return _serviceChargeRulesRef(hotelId).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return ServiceChargeRule.fromJson(data);
      }).toList();
    });
  }

  /// Save or Update Service Charge Rule
  Future<void> saveServiceChargeRule(ServiceChargeRule rule) async {
    await _serviceChargeRulesRef(rule.hotelId).doc(rule.id).set(rule.toJson());
  }

  /// Delete or Deactivate Service Charge Rule
  Future<void> deleteServiceChargeRule(String hotelId, String id) async {
    await _serviceChargeRulesRef(hotelId).doc(id).update({
      'isActive': false,
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  /// Get a bill by ID
  Future<Bill?> getBillById(String hotelId, String billId) async {
    final doc = await _billsRef(hotelId).doc(billId).get();
    if (!doc.exists) return null;
    return Bill.fromJson(doc.data() as Map<String, dynamic>);
  }

  /// Get Room Folio for a booking (one-time fetch)
  Future<RoomFolio?> getFolioByBookingId(
    String hotelId,
    String bookingId,
  ) async {
    final snapshot = await _foliosRef(
      hotelId,
    ).where('bookingId', isEqualTo: bookingId).limit(1).get();
    if (snapshot.docs.isEmpty) return null;
    return RoomFolio.fromJson(
      snapshot.docs.first.data() as Map<String, dynamic>,
    );
  }

  /// Get all bills for a customer
  Future<List<Bill>> getBillsByCustomerId(
    String hotelId,
    String customerId,
  ) async {
    final snapshot = await _billsRef(
      hotelId,
    ).where('customerId', isEqualTo: customerId).get();
    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return Bill.fromJson(data);
    }).toList();
  }
}
