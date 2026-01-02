part of '../database_service.dart';

extension DatabaseCustomers on DatabaseService {
  DatabaseReference get customersRef => _ref('customers');

  /// Stream all customers (real-time)
  Stream<List<Customer>> streamCustomers() {
    return customersRef.onValue.map((event) {
      if (event.snapshot.value == null) return <Customer>[];
      final dynamic value = event.snapshot.value;
      if (value == null) return <Customer>[];
      final Map<dynamic, dynamic> data = (value is Map)
          ? value
          : (value is List ? value.asMap() : {});

      return data.entries.map((e) {
        final customerData = _toMap(e.value);
        return Customer.fromJson(customerData);
      }).toList();
    });
  }

  /// Get customer by phone
  Future<Customer?> getCustomerByPhone(String phone) async {
    final snapshot = await customersRef
        .orderByChild('phone')
        .equalTo(phone)
        .get();
    if (!snapshot.exists || snapshot.value == null) return null;

    final Map<dynamic, dynamic> data = _toMap(snapshot.value);
    if (data.isEmpty) return null;

    // orderByChild returns a map with keys, so we take the first entry
    final firstEntry = data.entries.first.value;
    return Customer.fromJson(_toMap(firstEntry));
  }

  /// Save or update customer
  Future<void> saveCustomer(Customer customer) async {
    await customersRef.child(customer.id).set(customer.toJson());
  }

  /// Update customer analytics (visit count, total spent, etc.)
  Future<void> updateCustomerAnalytics(
    String customerId,
    double amountSpend,
  ) async {
    final customerSnapshot = await customersRef.child(customerId).get();
    if (!customerSnapshot.exists) return;

    final customer = Customer.fromJson(_toMap(customerSnapshot.value));
    final updatedCustomer = customer.copyWith(
      lastVisit: DateTime.now(),
      totalBookings: customer.totalBookings + 1,
      totalSpent: customer.totalSpent + amountSpend,
    );

    await saveCustomer(updatedCustomer);
  }
}
