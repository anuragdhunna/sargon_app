import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import '../models/models.dart';

import 'database/interfaces/billing_database.dart';

part 'database/database_users.dart';
part 'database/database_orders.dart';
part 'database/database_rooms.dart';
part 'database/database_inventory.dart';
part 'database/database_checklists.dart';
part 'database/database_incidents.dart';
part 'database/database_menu.dart';
part 'database/database_customers.dart';
part 'database/database_tables.dart';
part 'database/database_billing.dart';
part 'database/database_audit.dart';
part 'database/database_offers.dart';
part 'database/database_loyalty.dart';
part 'database/database_utils.dart';

/// Firebase Realtime Database service
///
/// Provides CRUD operations and real-time listeners for all data collections.
/// Now broken down into part files for better maintainability.
class DatabaseService implements IBillingDatabase {
  final FirebaseDatabase _database;

  DatabaseService({FirebaseDatabase? database})
    : _database = database ?? FirebaseDatabase.instance;

  /// Get database reference for a path
  DatabaseReference _ref(String path) => _database.ref(path);

  // Implement IBillingDatabase
  @override
  Future<List<Bill>> getBills() => DatabaseBilling(this).getBills();
  @override
  Stream<List<Bill>> streamBills() => DatabaseBilling(this).streamBills();
  @override
  Future<void> saveBill(Bill bill) => DatabaseBilling(this).saveBill(bill);
  @override
  Stream<List<TaxRule>> streamTaxRules() =>
      DatabaseBilling(this).streamTaxRules();
  @override
  Future<List<TaxRule>> getTaxRules() => DatabaseBilling(this).getTaxRules();
  @override
  Stream<List<ServiceChargeRule>> streamServiceChargeRules() =>
      DatabaseBilling(this).streamServiceChargeRules();
  @override
  Future<List<ServiceChargeRule>> getServiceChargeRules() =>
      DatabaseBilling(this).getServiceChargeRules();
  @override
  Future<Bill?> getBillById(String billId) =>
      DatabaseBilling(this).getBillById(billId);
  @override
  Future<void> updateOrderPaymentStatus(String orderId, PaymentStatus status) =>
      DatabaseOrders(this).updateOrderPaymentStatus(orderId, status);
  @override
  Future<void> updateTableStatus(String tableId, TableStatus status) =>
      DatabaseTables(this).updateTableStatus(tableId, status);
  @override
  Future<RoomFolio?> getFolioByBookingId(String bookingId) =>
      DatabaseBilling(this).getFolioByBookingId(bookingId);
  @override
  Future<void> saveFolio(RoomFolio folio) =>
      DatabaseBilling(this).saveFolio(folio);
  @override
  Future<List<Order>> getOrdersByIds(List<String> orderIds) =>
      DatabaseOrders(this).getOrdersByIds(orderIds);
}
