import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hotel_manager/core/models/audit_log.dart';
import 'package:hotel_manager/core/services/audit_service.dart';
import 'package:hotel_manager/features/inventory/stock/data/inventory_model.dart';
import 'package:hotel_manager/features/inventory/stock/logic/inventory_state.dart';

/// Cubit for managing inventory operations
class InventoryCubit extends Cubit<InventoryState> {
  InventoryCubit() : super(InventoryInitial()) {
    loadInventory();
  }

  final List<InventoryItem> _mockItems = [
    const InventoryItem(id: '1', name: 'Tomato Sauce', category: ItemCategory.food, quantity: 5, minQuantity: 10, unit: UnitType.bottles, pricePerUnit: 150.0),
    const InventoryItem(id: '2', name: 'Vodka (Absolut)', category: ItemCategory.beverage, quantity: 12, minQuantity: 5, unit: UnitType.bottles, pricePerUnit: 2500.0),
    const InventoryItem(id: '3', name: 'Toilet Paper', category: ItemCategory.housekeeping, quantity: 20, minQuantity: 50, unit: UnitType.pieces, pricePerUnit: 40.0),
    const InventoryItem(id: '4', name: 'Pool Chlorine', category: ItemCategory.maintenance, quantity: 15, minQuantity: 10, unit: UnitType.kg, pricePerUnit: 800.0),
  ];

  void loadInventory() async {
    emit(InventoryLoading());
    await Future.delayed(const Duration(seconds: 1));
    emit(InventoryLoaded(List.from(_mockItems)));
  }

  void addItem(InventoryItem item, {required String userId, required String userName, required String userRole}) {
    _mockItems.add(item);
    emit(InventoryLoaded(List.from(_mockItems)));
    
    AuditService().log(
      userId: userId,
      userName: userName,
      userRole: userRole,
      action: AuditAction.create,
      entity: 'inventory',
      entityId: item.id,
      description: 'Added new inventory item: ${item.name}',
    );
  }

  void updateStock(String id, double newQuantity, {required String userId, required String userName, required String userRole}) {
    final index = _mockItems.indexWhere((i) => i.id == id);
    if (index != -1) {
      final item = _mockItems[index];
      final diff = newQuantity - item.quantity;
      
      _mockItems[index] = InventoryItem(
        id: item.id,
        name: item.name,
        category: item.category,
        quantity: newQuantity,
        minQuantity: item.minQuantity,
        unit: item.unit,
        pricePerUnit: item.pricePerUnit,
        imageUrl: item.imageUrl,
      );
      emit(InventoryLoaded(List.from(_mockItems)));
      
      AuditService().log(
        userId: userId,
        userName: userName,
        userRole: userRole,
        action: AuditAction.update,
        entity: 'inventory',
        entityId: id,
        description: 'Updated stock for ${item.name}: ${diff > 0 ? '+' : ''}$diff ${item.unit.name}',
      );
    }
  }

  void receiveStock({
    required String inventoryItemId,
    required double quantity,
    required String grnNumber,
    required String userId,
    required String userName,
    required String userRole,
  }) {
    final index = _mockItems.indexWhere((i) => i.id == inventoryItemId);
    if (index != -1) {
      final item = _mockItems[index];
      final newQuantity = item.quantity + quantity;
      
      _mockItems[index] = InventoryItem(
        id: item.id,
        name: item.name,
        category: item.category,
        quantity: newQuantity,
        minQuantity: item.minQuantity,
        unit: item.unit,
        pricePerUnit: item.pricePerUnit,
        imageUrl: item.imageUrl,
      );
      emit(InventoryLoaded(List.from(_mockItems)));
      
      AuditService().log(
        userId: userId,
        userName: userName,
        userRole: userRole,
        action: AuditAction.receive,
        entity: 'inventory',
        entityId: inventoryItemId,
        description: 'Received stock for ${item.name}: +$quantity ${item.unit.name} via $grnNumber',
        metadata: {
          'grnNumber': grnNumber,
          'quantityReceived': quantity,
          'newStock': newQuantity,
        },
      );
    }
  }
}

