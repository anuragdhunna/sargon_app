part of '../database_service.dart';

extension DatabaseCustomers on DatabaseService {
  CollectionReference _customersRef(String hotelId) =>
      _hotelDoc(hotelId).collection('customers');

  /// Get customer by ID
  Future<Customer?> getCustomer(String hotelId, String customerId) async {
    final doc = await _customersRef(hotelId).doc(customerId).get();
    if (!doc.exists) return null;
    return Customer.fromJson(doc.data() as Map<String, dynamic>);
  }

  /// Stream all customers (real-time)
  Stream<List<Customer>> streamCustomers(String hotelId) {
    return _customersRef(hotelId).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Customer.fromJson(data);
      }).toList();
    });
  }

  /// Get customer by phone
  Future<Customer?> getCustomerByPhone(String hotelId, String phone) async {
    final snapshot = await _customersRef(
      hotelId,
    ).where('phone', isEqualTo: phone).get();

    if (snapshot.docs.isEmpty) return null;

    final data = snapshot.docs.first.data() as Map<String, dynamic>;
    return Customer.fromJson(data);
  }

  /// Save or update customer
  Future<void> saveCustomer(Customer customer) async {
    await _customersRef(
      customer.hotelId,
    ).doc(customer.id).set(customer.toJson());
  }

  /// Update customer analytics (visit count, total spent, etc.)
  Future<void> updateCustomerAnalytics(
    String hotelId,
    String customerId,
    double amountSpend,
  ) async {
    final doc = await _customersRef(hotelId).doc(customerId).get();
    if (!doc.exists) return;

    final customer = Customer.fromJson(doc.data() as Map<String, dynamic>);
    final updatedCustomer = customer.copyWith(
      lastVisit: DateTime.now(),
      totalBookings: customer.totalBookings + 1,
      totalSpent: customer.totalSpent + amountSpend,
    );

    await saveCustomer(updatedCustomer);
  }
}
