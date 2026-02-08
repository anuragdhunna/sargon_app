import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:hotel_manager/features/inventory/inventory_index.dart';
import 'dart:async';

class MockInventoryRepository extends Mock implements InventoryRepository {}

class MockAuditService extends Mock implements AuditService {}

class FakeVendor extends Fake implements Vendor {}

class FakePurchaseOrder extends Fake implements PurchaseOrder {}

class FakeGoodsReceiptNote extends Fake implements GoodsReceiptNote {}

class FakeInventoryItem extends Fake implements InventoryItem {}

void main() {
  late MockInventoryRepository mockRepo;
  late MockAuditService mockAudit;
  late VendorCubit vendorCubit;
  late PurchaseOrderCubit poCubit;
  late InventoryCubit inventoryCubit;
  late GoodsReceiptCubit grnCubit;

  setUpAll(() {
    registerFallbackValue(FakeVendor());
    registerFallbackValue(FakePurchaseOrder());
    registerFallbackValue(FakeGoodsReceiptNote());
    registerFallbackValue(FakeInventoryItem());
    registerFallbackValue(AuditAction.createPO);
  });

  setUp(() {
    mockRepo = MockInventoryRepository();
    mockAudit = MockAuditService();

    // Setup default responses
    when(() => mockRepo.getVendors()).thenAnswer((_) async => []);
    when(() => mockRepo.getPurchaseOrders()).thenAnswer((_) async => []);
    when(() => mockRepo.getGoodsReceipts()).thenAnswer((_) async => []);
    when(() => mockRepo.streamInventory()).thenAnswer((_) => Stream.value([]));
    when(() => mockRepo.saveVendor(any())).thenAnswer((_) async => {});
    when(() => mockRepo.savePurchaseOrder(any())).thenAnswer((_) async => {});
    when(() => mockRepo.saveGoodsReceipt(any())).thenAnswer((_) async => {});
    when(() => mockRepo.addStock(any(), any())).thenAnswer((_) async => {});
    when(
      () => mockRepo.updateInventoryQuantity(any(), any()),
    ).thenAnswer((_) async => {});

    when(
      () => mockAudit.log(
        userId: any(named: 'userId'),
        userName: any(named: 'userName'),
        userRole: any(named: 'userRole'),
        action: any(named: 'action'),
        entity: any(named: 'entity'),
        entityId: any(named: 'entityId'),
        description: any(named: 'description'),
        metadata: any(named: 'metadata'),
      ),
    ).thenAnswer((_) async => {});

    vendorCubit = VendorCubit(repository: mockRepo);
    poCubit = PurchaseOrderCubit(repository: mockRepo, auditService: mockAudit);
    inventoryCubit = InventoryCubit(
      repository: mockRepo,
      auditService: mockAudit,
    );
    grnCubit = GoodsReceiptCubit(
      inventoryCubit: inventoryCubit,
      purchaseOrderCubit: poCubit,
      repository: mockRepo,
      auditService: mockAudit,
    );
  });

  tearDown(() {
    vendorCubit.close();
    poCubit.close();
    inventoryCubit.close();
    grnCubit.close();
  });

  test(
    'End-to-End Inventory Flow: Vendor -> PO -> GRN -> Stock Update',
    () async {
      // 1. Create a Vendor
      await vendorCubit.createVendor(
        name: 'Fresh Dairy',
        category: VendorCategory.dairy,
        contactPerson: 'John Milk',
        phoneNumber: '1234567890',
      );

      final vendor = (vendorCubit.state as VendorLoaded).vendors.first;
      expect(vendor.name, 'Fresh Dairy');
      verify(() => mockRepo.saveVendor(any())).called(1);

      // 2. Setup mock inventory items
      final milkItem = InventoryItem(
        id: 'item_milk',
        name: 'Milk',
        category: ItemCategory.food,
        unit: UnitType.liters,
        quantity: 10.0,
        minQuantity: 5.0,
        pricePerUnit: 50.0,
      );

      // Push inventory data to inventoryCubit
      when(
        () => mockRepo.streamInventory(),
      ).thenAnswer((_) => Stream.value([milkItem]));
      inventoryCubit.loadInventory();
      await expectLater(
        inventoryCubit.stream,
        emitsThrough(isA<InventoryLoaded>()),
      );

      // 3. Create a Purchase Order
      final poLineItem = POLineItem(
        id: 'poli_1',
        inventoryItemId: 'item_milk',
        itemName: 'Milk',
        unit: UnitType.liters,
        orderedQuantity: 20.0,
        receivedQuantity: 0.0,
        pricePerUnit: 45.0,
      );

      await poCubit.createPurchaseOrder(
        vendorId: vendor.id,
        vendorName: vendor.name,
        lineItems: [poLineItem],
        createdBy: 'Admin',
        userId: 'user_1',
        userName: 'Admin',
        userRole: 'admin',
      );

      final po = (poCubit.state as PurchaseOrderLoaded).orders.first;
      expect(po.vendorId, vendor.id);
      expect(po.lineItems.first.orderedQuantity, 20.0);
      verify(() => mockRepo.savePurchaseOrder(any())).called(1);
      verify(
        () => mockAudit.log(
          userId: 'user_1',
          action: AuditAction.createPO,
          entity: 'purchase_order',
          entityId: po.id,
          description: any(named: 'description'),
          userName: any(named: 'userName'),
          userRole: any(named: 'userRole'),
        ),
      ).called(1);

      // 4. Receive Goods (GRN)
      final grnLineItem = GRNLineItem(
        id: 'grnli_1',
        inventoryItemId: 'item_milk',
        itemName: 'Milk',
        unit: UnitType.liters,
        quantityReceived: 15.0, // Partial delivery
        pricePerUnit: 45.0,
        qualityCheckPassed: true,
      );

      await grnCubit.createGoodsReceipt(
        purchaseOrderId: po.id,
        vendorId: vendor.id,
        vendorName: vendor.name,
        lineItems: [grnLineItem],
        receivedBy: 'user_1',
        receivedByName: 'Admin',
        userId: 'user_1',
        userName: 'Admin',
        userRole: 'admin',
      );

      // Verify GRN saved
      verify(() => mockRepo.saveGoodsReceipt(any())).called(1);

      // Verify Stock updated in database
      verify(() => mockRepo.addStock('item_milk', 15.0)).called(1);

      // Verify PO partially updated
      final updatedPO = (poCubit.state as PurchaseOrderLoaded).orders.first;
      expect(updatedPO.status, POStatus.partial);
      expect(updatedPO.lineItems.first.receivedQuantity, 15.0);
      expect(updatedPO.lineItems.first.pendingQuantity, 5.0);

      // 5. Receive remaining goods
      final remainingGrnLineItem = GRNLineItem(
        id: 'grnli_2',
        inventoryItemId: 'item_milk',
        itemName: 'Milk',
        unit: UnitType.liters,
        quantityReceived: 5.0, // Full delivery now
        pricePerUnit: 45.0,
        qualityCheckPassed: true,
      );

      await grnCubit.createGoodsReceipt(
        purchaseOrderId: po.id,
        vendorId: vendor.id,
        vendorName: vendor.name,
        lineItems: [remainingGrnLineItem],
        receivedBy: 'user_1',
        receivedByName: 'Admin',
        userId: 'user_1',
        userName: 'Admin',
        userRole: 'admin',
      );

      // Verify PO completed
      final finalPO = (poCubit.state as PurchaseOrderLoaded).orders.first;
      expect(finalPO.status, POStatus.completed);
      expect(finalPO.lineItems.first.receivedQuantity, 20.0);
      expect(finalPO.lineItems.first.pendingQuantity, 0.0);

      // Verify Audit logs for receipt
      verify(
        () => mockAudit.log(
          userId: 'user_1',
          action: AuditAction.receive,
          entity: 'goods_receipt',
          entityId: any(named: 'entityId'),
          description: any(named: 'description'),
          userName: any(named: 'userName'),
          userRole: any(named: 'userRole'),
        ),
      ).called(2);
    },
  );
}
