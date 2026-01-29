import 'package:equatable/equatable.dart';

class DashboardData extends Equatable {
  // KPI Strip
  final int openTables;
  final int openBills;
  final int activeOrders;
  final int kitchenDelays;
  final double roomChargesPending;

  // Sales Snapshot (Today)
  final double grossSales;
  final double netSales;
  final double totalDiscounts;
  final double serviceChargeCollected;
  final double gstCollected;
  final double avgBillValue;
  final int billsCount;

  // Order & KDS Summary
  final int ordersCooking;
  final int ordersReady;
  final int delayedItems;
  final int vipRushOrders;
  final int cancelledItemsToday;

  // Payment & Billing
  final int unpaidBillsCount;
  final int partialPaymentsCount;
  final double cashTotal;
  final double cardTotal;
  final double onlineTotal;
  final double billToRoomTotal;

  // Room Ops
  final int occupiedRooms;
  final int checkoutToday;
  final int roomServiceOrders;
  final int pendingRoomFolios;

  // Discounts & Loyalty
  final int discountedBillsCount;
  final double totalDiscountValue;
  final int complimentaryItemsCount;
  final double pointsIssuedToday;
  final double pointsRedeemedToday;

  // Inventory & Staff
  final int lowStockItems;
  final int criticalStockItems;
  final int staffOnShift;

  // Best Selling Dishes
  final List<Map<String, dynamic>> topDishes;

  const DashboardData({
    this.openTables = 0,
    this.openBills = 0,
    this.activeOrders = 0,
    this.kitchenDelays = 0,
    this.roomChargesPending = 0.0,
    this.grossSales = 0.0,
    this.netSales = 0.0,
    this.totalDiscounts = 0.0,
    this.serviceChargeCollected = 0.0,
    this.gstCollected = 0.0,
    this.avgBillValue = 0.0,
    this.billsCount = 0,
    this.ordersCooking = 0,
    this.ordersReady = 0,
    this.delayedItems = 0,
    this.vipRushOrders = 0,
    this.cancelledItemsToday = 0,
    this.unpaidBillsCount = 0,
    this.partialPaymentsCount = 0,
    this.cashTotal = 0.0,
    this.cardTotal = 0.0,
    this.onlineTotal = 0.0,
    this.billToRoomTotal = 0.0,
    this.occupiedRooms = 0,
    this.checkoutToday = 0,
    this.roomServiceOrders = 0,
    this.pendingRoomFolios = 0,
    this.discountedBillsCount = 0,
    this.totalDiscountValue = 0.0,
    this.complimentaryItemsCount = 0,
    this.pointsIssuedToday = 0.0,
    this.pointsRedeemedToday = 0.0,
    this.lowStockItems = 0,
    this.criticalStockItems = 0,
    this.staffOnShift = 0,
    this.topDishes = const [],
  });

  @override
  List<Object?> get props => [
    openTables,
    openBills,
    activeOrders,
    kitchenDelays,
    roomChargesPending,
    grossSales,
    netSales,
    totalDiscounts,
    serviceChargeCollected,
    gstCollected,
    avgBillValue,
    billsCount,
    ordersCooking,
    ordersReady,
    delayedItems,
    vipRushOrders,
    cancelledItemsToday,
    unpaidBillsCount,
    partialPaymentsCount,
    cashTotal,
    cardTotal,
    onlineTotal,
    billToRoomTotal,
    occupiedRooms,
    checkoutToday,
    roomServiceOrders,
    pendingRoomFolios,
    discountedBillsCount,
    totalDiscountValue,
    complimentaryItemsCount,
    pointsIssuedToday,
    pointsRedeemedToday,
    lowStockItems,
    criticalStockItems,
    staffOnShift,
    topDishes,
  ];
}

abstract class DashboardState extends Equatable {
  const DashboardState();
  @override
  List<Object?> get props => [];
}

class DashboardInitial extends DashboardState {}

class DashboardLoading extends DashboardState {}

class DashboardError extends DashboardState {
  final String message;
  const DashboardError(this.message);
  @override
  List<Object?> get props => [message];
}

class DashboardLoaded extends DashboardState {
  final DashboardData data;
  final DateTime lastRefreshed;

  const DashboardLoaded({required this.data, required this.lastRefreshed});

  @override
  List<Object?> get props => [data, lastRefreshed];
}
