import 'package:hotel_manager/core/models/models.dart';
import 'package:hotel_manager/core/services/database_service.dart';

class StockManagerService {
  final DatabaseService _databaseService;

  StockManagerService(this._databaseService);

  /// Deduct stock for an order
  Future<void> deductStockForOrder(String hotelId, Order order) async {
    await deductStockForItems(hotelId, order.items);
  }

  /// Deduct stock for specific items
  Future<void> deductStockForItems(
    String hotelId,
    List<OrderItem> items,
  ) async {
    for (final item in items) {
      final menuItem = await _databaseService.getMenuItem(
        hotelId,
        item.menuItemId,
      );
      if (menuItem != null && menuItem.recipe != null) {
        for (final ingredient in menuItem.recipe!) {
          await _databaseService.deductStock(
            hotelId,
            ingredient.inventoryItemId,
            ingredient.quantity * item.quantity,
          );
        }
      }
    }
  }

  /// Revert stock for an order
  Future<void> revertStockForOrder(String hotelId, Order order) async {
    await revertStockForItems(hotelId, order.items);
  }

  /// Revert stock for specific items
  Future<void> revertStockForItems(
    String hotelId,
    List<OrderItem> items,
  ) async {
    for (final item in items) {
      final menuItem = await _databaseService.getMenuItem(
        hotelId,
        item.menuItemId,
      );
      if (menuItem != null && menuItem.recipe != null) {
        for (final ingredient in menuItem.recipe!) {
          await _databaseService.addStock(
            hotelId,
            ingredient.inventoryItemId,
            ingredient.quantity * item.quantity,
          );
        }
      }
    }
  }
}
