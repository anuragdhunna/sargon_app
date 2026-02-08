import 'package:hotel_manager/core/models/models.dart';
import 'package:hotel_manager/core/services/database_service.dart';

class StockManagerService {
  final DatabaseService _databaseService;

  StockManagerService(this._databaseService);

  /// Deduct stock for an order
  Future<void> deductStockForOrder(Order order) async {
    await deductStockForItems(order.items);
  }

  /// Deduct stock for specific items
  Future<void> deductStockForItems(List<OrderItem> items) async {
    for (final item in items) {
      final menuItem = await _databaseService.getMenuItem(item.menuItemId);
      if (menuItem != null && menuItem.recipe != null) {
        for (final ingredient in menuItem.recipe!) {
          await _databaseService.deductStock(
            ingredient.inventoryItemId,
            ingredient.quantity * item.quantity,
          );
        }
      }
    }
  }

  /// Revert stock for an order
  Future<void> revertStockForOrder(Order order) async {
    await revertStockForItems(order.items);
  }

  /// Revert stock for specific items
  Future<void> revertStockForItems(List<OrderItem> items) async {
    for (final item in items) {
      final menuItem = await _databaseService.getMenuItem(item.menuItemId);
      if (menuItem != null && menuItem.recipe != null) {
        for (final ingredient in menuItem.recipe!) {
          await _databaseService.addStock(
            ingredient.inventoryItemId,
            ingredient.quantity * item.quantity,
          );
        }
      }
    }
  }
}
