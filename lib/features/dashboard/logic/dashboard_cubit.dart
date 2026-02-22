import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hotel_manager/core/services/database_service.dart';
import 'package:hotel_manager/core/models/models.dart';
import 'dashboard_state.dart';

class DashboardCubit extends Cubit<DashboardState> {
  final DatabaseService _db;

  DashboardCubit({required DatabaseService databaseService})
    : _db = databaseService,
      super(DashboardInitial());

  Future<void> refresh(String hotelId) async {
    emit(DashboardLoading());
    try {
      // Fetch Snapshots for all required data
      final tables = await _db.getTables(hotelId);
      final orders = await _db.getOrders(hotelId);
      final bills = await _db.getBills(hotelId);
      final rooms = await _db.getRooms(hotelId);
      final invItems = await _db.getInventory(hotelId);

      final now = DateTime.now();
      final todayBills = bills
          .where(
            (b) =>
                b.openedAt.year == now.year &&
                b.openedAt.month == now.month &&
                b.openedAt.day == now.day,
          )
          .toList();

      // Aggregates
      double grossSales = 0;
      double totalDiscounts = 0;
      double scCollected = 0;
      double gstCollected = 0;
      double cashTotal = 0;
      double cardTotal = 0;
      double upiTotal = 0;
      double billToRoomTotal = 0;

      for (var b in todayBills) {
        grossSales += b.subTotal;
        totalDiscounts += b.taxSummary.totalDiscountAmount;
        scCollected += b.taxSummary.serviceChargeAmount;
        gstCollected += b.taxSummary.totalTax;

        for (var p in b.payments) {
          if (p.method == PaymentMethod.cash) cashTotal += p.amount;
          if (p.method == PaymentMethod.card) cardTotal += p.amount;
          if (p.method == PaymentMethod.upi) upiTotal += p.amount;
          if (p.method == PaymentMethod.billToRoom) {
            billToRoomTotal += p.amount;
          }
        }
      }

      final activeOrders = orders
          .where(
            (o) =>
                o.status != OrderStatus.cancelled &&
                (o.paymentStatus == PaymentStatus.pending ||
                    o.paymentStatus == PaymentStatus.billed),
          )
          .toList();

      final openBillsCount = bills
          .where((b) => b.paymentStatus != PaymentStatus.paid)
          .length;

      // Dish popularity
      final dishMap = <String, Map<String, dynamic>>{};
      for (var o in orders) {
        if (o.status == OrderStatus.cancelled) continue;
        for (var item in o.items) {
          if (item.kdsStatus == KdsStatus.cancelled) continue;
          final current =
              dishMap[item.menuItemId] ??
              {'name': item.name, 'qty': 0, 'sales': 0.0};
          dishMap[item.menuItemId] = {
            'name': item.name,
            'qty': (current['qty'] as int) + item.quantity,
            'sales': (current['sales'] as double) + item.totalPrice,
          };
        }
      }
      final sortedDishes = dishMap.values.toList()
        ..sort((a, b) => (b['qty'] as int).compareTo(a['qty'] as int));
      final topDishes = sortedDishes.take(5).toList();

      // KDS Performance
      int delayedItems = 0;
      int vipRushCount = 0;
      for (var o in activeOrders) {
        if (o.priority == OrderPriority.vip ||
            o.priority == OrderPriority.rush) {
          vipRushCount++;
        }
        for (var item in o.items) {
          if (item.isDelayed) delayedItems++;
        }
      }

      final data = DashboardData(
        openTables: tables
            .where((t) => t.status != TableStatus.available)
            .length,
        openBills: openBillsCount,
        activeOrders: activeOrders.length,
        kitchenDelays: activeOrders
            .where((o) => o.items.any((i) => i.isDelayed))
            .length,
        grossSales: grossSales,
        netSales: grossSales - totalDiscounts,
        totalDiscounts: totalDiscounts,
        serviceChargeCollected: scCollected,
        gstCollected: gstCollected,
        billsCount: todayBills.length,
        avgBillValue: todayBills.isEmpty ? 0 : (grossSales / todayBills.length),
        ordersCooking: activeOrders
            .where((o) => o.status == OrderStatus.cooking)
            .length,
        ordersReady: activeOrders
            .where((o) => o.status == OrderStatus.ready)
            .length,
        delayedItems: delayedItems,
        vipRushOrders: vipRushCount,
        unpaidBillsCount: openBillsCount,
        cashTotal: cashTotal,
        cardTotal: cardTotal,
        onlineTotal: upiTotal,
        billToRoomTotal: billToRoomTotal,
        occupiedRooms: rooms
            .where((r) => r.status == RoomStatus.occupied)
            .length,
        roomServiceOrders: orders.where((o) => o.roomId != null).length,
        lowStockItems: invItems
            .where((i) => i.isLowStock && !i.isOutOfStock)
            .length,
        criticalStockItems: invItems.where((i) => i.isOutOfStock).length,
        topDishes: topDishes,
      );

      emit(DashboardLoaded(data: data, lastRefreshed: DateTime.now()));
    } catch (e) {
      emit(DashboardError(e.toString()));
    }
  }

  // _mapList and recursive converters are no longer needed as the get methods already handle parsing
}
