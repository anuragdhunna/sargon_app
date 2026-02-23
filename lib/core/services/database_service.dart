import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
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
part 'database/database_settings.dart';
part 'database/database_events.dart';
part 'database/database_hotels.dart';

/// Firebase Cloud Firestore service
class DatabaseService implements IBillingDatabase {
  final FirebaseFirestore _firestore;

  DatabaseService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Root document for a specific hotel/tenant
  FirebaseFirestore get firestore => _firestore;

  DocumentReference hotelDoc(String hotelId) => _hotelDoc(hotelId);

  DocumentReference _hotelDoc(String hotelId) =>
      _firestore.collection('hotels').doc(hotelId);

  // Implement IBillingDatabase (Requires hotelId context where possible,
  // or will be updated in sub-extensions to handle it)

  // NOTE: For methods that don't take hotelId, we might need to rely on
  // current auth context or update the interface. For now, delegating to extensions.

  @override
  Future<List<Bill>> getBills(String hotelId) =>
      DatabaseBilling(this).getBills(hotelId);
  @override
  Stream<List<Bill>> streamBills(String hotelId) =>
      DatabaseBilling(this).streamBills(hotelId);
  @override
  Future<void> saveBill(Bill bill) => DatabaseBilling(this).saveBill(bill);
  @override
  Stream<List<TaxRule>> streamTaxRules(String hotelId) =>
      DatabaseBilling(this).streamTaxRules(hotelId);
  @override
  Future<List<TaxRule>> getTaxRules(String hotelId) =>
      DatabaseBilling(this).getTaxRules(hotelId);
  @override
  Stream<List<ServiceChargeRule>> streamServiceChargeRules(String hotelId) =>
      DatabaseBilling(this).streamServiceChargeRules(hotelId);
  @override
  Future<List<ServiceChargeRule>> getServiceChargeRules(String hotelId) =>
      DatabaseBilling(this).getServiceChargeRules(hotelId);
  @override
  Future<Bill?> getBillById(String hotelId, String billId) =>
      DatabaseBilling(this).getBillById(hotelId, billId);
  @override
  Future<void> updateOrderPaymentStatus(
    String hotelId,
    String orderId,
    PaymentStatus status,
  ) => DatabaseOrders(this).updateOrderPaymentStatus(hotelId, orderId, status);
  @override
  Future<void> updateTableStatus(
    String hotelId,
    String tableId,
    TableStatus status,
  ) => DatabaseTables(this).updateTableStatus(hotelId, tableId, status);
  @override
  Future<RoomFolio?> getFolioByBookingId(String hotelId, String bookingId) =>
      DatabaseBilling(this).getFolioByBookingId(hotelId, bookingId);
  @override
  Future<void> saveFolio(RoomFolio folio) =>
      DatabaseBilling(this).saveFolio(folio);
  @override
  Future<List<Order>> getOrdersByIds(String hotelId, List<String> orderIds) =>
      DatabaseOrders(this).getOrdersByIds(hotelId, orderIds);

  @override
  Future<void> deleteServiceChargeRule(String hotelId, String id) =>
      DatabaseBilling(this).deleteServiceChargeRule(hotelId, id);

  // Added missing wrappers (Standardized to take hotelId)
  Future<List<Bill>> getBillsByCustomerId(String hotelId, String customerId) =>
      DatabaseBilling(this).getBillsByCustomerId(hotelId, customerId);
  Stream<RoomFolio?> streamFolio(String hotelId, String bookingId) =>
      DatabaseBilling(this).streamFolio(hotelId, bookingId);

  Future<void> saveTaxRule(TaxRule rule) =>
      DatabaseBilling(this).saveTaxRule(rule);
  Future<void> deleteTaxRule(String hotelId, String id) =>
      DatabaseBilling(this).deleteTaxRule(hotelId, id);
  Future<void> saveServiceChargeRule(ServiceChargeRule rule) =>
      DatabaseBilling(this).saveServiceChargeRule(rule);

  // Tables
  // Tables
  Stream<List<TableEntity>> streamTables(String hotelId) =>
      DatabaseTables(this).streamTables(hotelId);
  Future<List<TableEntity>> getTables(String hotelId) =>
      DatabaseTables(this).getTables(hotelId);
  Future<void> saveTable(TableEntity table) =>
      DatabaseTables(this).saveTable(table);
  Future<void> deleteTable(String hotelId, String id) =>
      DatabaseTables(this).deleteTable(hotelId, id);

  // Menu
  Stream<List<MenuItem>> streamMenuItems(String hotelId) =>
      DatabaseMenu(this).streamMenuItems(hotelId);
  Future<void> saveMenuItem(MenuItem item) =>
      DatabaseMenu(this).saveMenuItem(item);
  Future<void> deleteMenuItem(String hotelId, String id) =>
      DatabaseMenu(this).deleteMenuItem(hotelId, id);
  Future<MenuItem?> getMenuItem(String hotelId, String id) =>
      DatabaseMenu(this).getMenuItem(hotelId, id);

  // Customers
  Future<Customer?> getCustomer(String hotelId, String id) =>
      DatabaseCustomers(this).getCustomer(hotelId, id);
  Future<void> saveCustomer(Customer customer) =>
      DatabaseCustomers(this).saveCustomer(customer);

  Future<void> deductStock(String hotelId, String itemId, double qty) =>
      DatabaseInventory(this).deductStock(hotelId, itemId, qty);

  Future<void> addStock(String hotelId, String itemId, double qty) =>
      DatabaseInventory(this).addStock(hotelId, itemId, qty);

  // Settings
  Future<AppSettings> getAppSettings(String hotelId) =>
      DatabaseSettings(this).getAppSettings(hotelId);
  Stream<AppSettings> streamAppSettings(String hotelId) =>
      DatabaseSettings(this).streamAppSettings(hotelId);
  Future<void> updateAppSettings(AppSettings settings) =>
      DatabaseSettings(this).updateAppSettings(settings);

  // Incidents
  Stream<List<Incident>> streamIncidents(String hotelId) =>
      DatabaseIncidents(this).streamIncidents(hotelId);
  Future<void> saveIncident(Incident incident) =>
      DatabaseIncidents(this).saveIncident(incident);
  Future<void> updateIncidentStatus(String hotelId, String id, String status) =>
      DatabaseIncidents(this).updateIncidentStatus(hotelId, id, status);

  // Audit
  Stream<List<AuditLog>> streamAuditLogs(String hotelId) =>
      DatabaseAudit(this).streamAuditLogs(hotelId);
  Future<void> saveAuditLog(AuditLog log) =>
      DatabaseAudit(this).saveAuditLog(log);

  // Rooms
  Stream<List<Room>> streamRooms(String hotelId) =>
      DatabaseRooms(this).streamRooms(hotelId);
  Future<List<Room>> getRooms(String hotelId) =>
      DatabaseRooms(this).getRooms(hotelId);
  Future<void> saveRoom(Room room) => DatabaseRooms(this).saveRoom(room);
  Future<void> updateRoomStatus(String hotelId, String id, RoomStatus status) =>
      DatabaseRooms(this).updateRoomStatus(hotelId, id, status);
  Stream<List<Booking>> streamBookings(String hotelId) =>
      DatabaseRooms(this).streamBookings(hotelId);
  Future<void> saveBooking(Booking booking) =>
      DatabaseRooms(this).saveBooking(booking);
  Future<List<Booking>> getBookingsByCustomerId(
    String hotelId,
    String customerId,
  ) => DatabaseRooms(this).getBookingsByCustomerId(hotelId, customerId);
  Future<Booking?> getBookingById(String hotelId, String id) =>
      DatabaseRooms(this).getBookingById(hotelId, id);

  // Inventory
  Stream<List<InventoryItem>> streamInventory(String hotelId) =>
      DatabaseInventory(this).streamInventory(hotelId);
  Future<List<InventoryItem>> getInventory(String hotelId) =>
      DatabaseInventory(this).getInventory(hotelId);
  Stream<List<InventoryItem>> streamLowStockItems(String hotelId) =>
      DatabaseInventory(this).streamLowStockItems(hotelId);
  Future<void> saveInventoryItem(InventoryItem item) =>
      DatabaseInventory(this).saveInventoryItem(item);
  Future<void> updateInventoryQuantity(String hotelId, String id, double qty) =>
      DatabaseInventory(this).updateInventoryQuantity(hotelId, id, qty);

  // Offers
  Future<List<Offer>> getOffers(String hotelId) =>
      DatabaseOffers(this).getOffers(hotelId);
  Stream<List<Offer>> streamOffers(String hotelId) =>
      DatabaseOffers(this).streamOffers(hotelId);
  Future<void> saveOffer(Offer offer) => DatabaseOffers(this).saveOffer(offer);

  // Loyalty
  Future<List<LoyaltyTier>> getLoyaltyTiers(String hotelId) =>
      DatabaseLoyalty(this).getLoyaltyTiers(hotelId);
  Stream<List<LoyaltyTier>> streamLoyaltyTiers(String hotelId) =>
      DatabaseLoyalty(this).streamLoyaltyTiers(hotelId);
  Future<void> saveLoyaltyTier(LoyaltyTier tier) =>
      DatabaseLoyalty(this).saveLoyaltyTier(tier);
  Future<List<PointRule>> getPointRules(String hotelId) =>
      DatabaseLoyalty(this).getPointRules(hotelId);
  Stream<List<PointRule>> streamPointRules(String hotelId) =>
      DatabaseLoyalty(this).streamPointRules(hotelId);
  Future<void> savePointRule(PointRule rule) =>
      DatabaseLoyalty(this).savePointRule(rule);
  Future<void> savePointRedemption(PointRedemption redemption) =>
      DatabaseLoyalty(this).savePointRedemption(redemption);

  // Events
  Stream<List<EventIncident>> streamEventIncidents(
    String hotelId,
    String eventId,
  ) => DatabaseEvents(this).streamEventIncidents(hotelId, eventId);
  Future<void> saveEventIncident(EventIncident incident) =>
      DatabaseEvents(this).saveEventIncident(incident);
  Stream<List<Hall>> streamHalls(String hotelId) =>
      DatabaseEvents(this).streamHalls(hotelId);
  Future<void> saveHall(Hall hall) => DatabaseEvents(this).saveHall(hall);
  Future<void> deleteHall(String hotelId, String id) =>
      DatabaseEvents(this).deleteHall(hotelId, id);
  Stream<List<PrivateEvent>> streamEvents(String hotelId) =>
      DatabaseEvents(this).streamEvents(hotelId);
  Future<void> saveEvent(PrivateEvent event) =>
      DatabaseEvents(this).saveEvent(event);
  Future<void> updateEventStatus(
    String hotelId,
    String eventId,
    EventStatus status,
  ) => DatabaseEvents(this).updateEventStatus(hotelId, eventId, status);
  Stream<List<EventPO>> streamEventPOs(String hotelId, String eventId) =>
      DatabaseEvents(this).streamEventPOs(hotelId, eventId);
  Future<void> saveEventPO(EventPO po) => DatabaseEvents(this).saveEventPO(po);
  Future<void> deleteEventPO(String hotelId, String poId) =>
      DatabaseEvents(this).deleteEventPO(hotelId, poId);
  Stream<List<EventStaffAssignment>> streamStaffAssignments(
    String hotelId,
    String eventId,
  ) => DatabaseEvents(this).streamStaffAssignments(hotelId, eventId);
  Future<void> saveStaffAssignment(EventStaffAssignment assignment) =>
      DatabaseEvents(this).saveStaffAssignment(assignment);
  Stream<List<TaxRule>> streamEventTaxRules(String hotelId) =>
      DatabaseEvents(this).streamEventTaxRules(hotelId);
  Future<List<Hall>> fetchHalls(String hotelId) =>
      DatabaseEvents(this).fetchHalls(hotelId);
  Future<List<PrivateEvent>> fetchEvents(String hotelId) =>
      DatabaseEvents(this).fetchEvents(hotelId);
  Future<List<EventPO>> fetchEventPOs(String hotelId, String eventId) =>
      DatabaseEvents(this).fetchEventPOs(hotelId, eventId);
  Future<List<TaxRule>> fetchEventTaxRules(String hotelId) =>
      DatabaseEvents(this).fetchEventTaxRules(hotelId);

  // Hotels
  Stream<List<Hotel>> streamAllHotels() =>
      DatabaseHotels(this).streamAllHotels();
  Future<List<Hotel>> getHotelsPaginated({
    int limit = 10,
    DocumentSnapshot? startAfter,
  }) => DatabaseHotels(
    this,
  ).getHotelsPaginated(limit: limit, startAfter: startAfter);
  Future<Hotel?> getHotel(String hotelId) =>
      DatabaseHotels(this).getHotel(hotelId);
  Future<void> saveHotel(Hotel hotel) => DatabaseHotels(this).saveHotel(hotel);
  Future<void> deleteHotel(String hotelId) =>
      DatabaseHotels(this).deleteHotel(hotelId);

  /// Initialize dummy orders for testing/demo (Stub for AuthCubit call)
  Future<void> initializeDummyOrders(String hotelId) async {
    // Current implementation is a stub to prevent NoSuchMethodError
    return;
  }
}
