import '/core/models/models.dart';

abstract class IBillingDatabase {
  Future<List<Bill>> getBills();
  Stream<List<Bill>> streamBills();
  Future<void> saveBill(Bill bill);
  Stream<List<TaxRule>> streamTaxRules();
  Future<List<TaxRule>> getTaxRules();
  Stream<List<ServiceChargeRule>> streamServiceChargeRules();
  Future<List<ServiceChargeRule>> getServiceChargeRules();
  Future<Bill?> getBillById(String billId);
  Future<void> updateOrderPaymentStatus(String orderId, PaymentStatus status);
  Future<void> updateTableStatus(String tableId, TableStatus status);
  Future<RoomFolio?> getFolioByBookingId(String bookingId);
  Future<void> saveFolio(RoomFolio folio);
  Future<List<Order>> getOrdersByIds(List<String> orderIds);
}
