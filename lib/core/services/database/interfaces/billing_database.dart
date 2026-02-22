import '/core/models/models.dart';

abstract class IBillingDatabase {
  Future<List<Bill>> getBills(String hotelId);
  Stream<List<Bill>> streamBills(String hotelId);
  Future<void> saveBill(Bill bill);
  Stream<List<TaxRule>> streamTaxRules(String hotelId);
  Future<List<TaxRule>> getTaxRules(String hotelId);
  Stream<List<ServiceChargeRule>> streamServiceChargeRules(String hotelId);
  Future<List<ServiceChargeRule>> getServiceChargeRules(String hotelId);
  Future<Bill?> getBillById(String hotelId, String billId);
  Future<void> updateOrderPaymentStatus(
    String hotelId,
    String orderId,
    PaymentStatus status,
  );
  Future<void> updateTableStatus(
    String hotelId,
    String tableId,
    TableStatus status,
  );
  Future<RoomFolio?> getFolioByBookingId(String hotelId, String bookingId);
  Future<void> saveFolio(RoomFolio folio);
  Future<List<Order>> getOrdersByIds(String hotelId, List<String> orderIds);
  Future<void> deleteServiceChargeRule(String hotelId, String id);
}
