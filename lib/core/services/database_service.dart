import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../models/billing_models.dart';
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
class DatabaseService implements IBillingDatabase {
  final FirebaseDatabase _database;

  DatabaseService({FirebaseDatabase? database})
    : _database = database ?? FirebaseDatabase.instance;

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

  Future<void> saveTaxRule(TaxRule rule) =>
      DatabaseBilling(this).saveTaxRule(rule);
  Future<void> deleteTaxRule(String id) =>
      DatabaseBilling(this).deleteTaxRule(id);
  Future<void> saveServiceChargeRule(ServiceChargeRule rule) =>
      DatabaseBilling(this).saveServiceChargeRule(rule);

  // Tables
  Future<void> saveTable(TableEntity table) =>
      DatabaseTables(this).saveTable(table);
  Future<void> deleteTable(String id) => DatabaseTables(this).deleteTable(id);
  Stream<List<TableEntity>> streamTables() =>
      DatabaseTables(this).streamTables();

  // Menu
  Future<void> saveMenuItem(MenuItem item) =>
      DatabaseMenu(this).saveMenuItem(item);
  Future<void> deleteMenuItem(String id) =>
      DatabaseMenu(this).deleteMenuItem(id);
  Stream<List<MenuItem>> streamMenuItems() =>
      DatabaseMenu(this).streamMenuItems();
  Future<MenuItem?> getMenuItem(String id) =>
      DatabaseMenu(this).getMenuItem(id);

  // Inventory
  Future<void> deductStock(String itemId, double qty) =>
      DatabaseInventory(this).deductStock(itemId, qty);
  Future<void> addStock(String itemId, double qty) =>
      DatabaseInventory(this).addStock(itemId, qty);

  // Initialization Helpers
  Future<void> initializeBillingDefaults() =>
      DatabaseBilling(this).initializeBillingDefaults();
  Future<void> initializeDummyTables() =>
      DatabaseTables(this).initializeDummyTables();
  Future<void> initializeDummyRooms() =>
      DatabaseRooms(this).initializeDummyRooms();
}
