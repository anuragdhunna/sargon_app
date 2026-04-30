class AppFeatures {
  static const String dashboard = 'dashboard';
  static const String floorView = 'floorView';
  static const String staff = 'staff';
  static const String customers = 'customers';
  static const String rooms = 'rooms';
  static const String events = 'events';
  static const String inventory = 'inventory';
  static const String orders = 'orders';
  static const String kds = 'kds';
  static const String orderHistory = 'orderHistory';
  static const String checklists = 'checklists';
  static const String attendance = 'attendance';
  static const String incidents = 'incidents';
  static const String performance = 'performance';
  static const String auditLogs = 'auditLogs';
  static const String offers = 'offers';
  static const String loyalty = 'loyalty';

  static const List<String> allFeatures = [
    dashboard,
    floorView,
    staff,
    customers,
    rooms,
    events,
    inventory,
    orders,
    kds,
    orderHistory,
    checklists,
    attendance,
    incidents,
    performance,
    auditLogs,
    offers,
    loyalty,
  ];

  static String getFeatureName(String feature) {
    switch (feature) {
      case dashboard:
        return 'Dashboard';
      case floorView:
        return 'Floor View';
      case staff:
        return 'Staff Management';
      case customers:
        return 'Customer Analytics';
      case rooms:
        return 'Rooms';
      case events:
        return 'Events';
      case inventory:
        return 'Inventory';
      case orders:
        return 'Order Taking';
      case kds:
        return 'Kitchen Display System (KDS)';
      case orderHistory:
        return 'Order History';
      case checklists:
        return 'Checklists';
      case attendance:
        return 'Attendance';
      case incidents:
        return 'Incidents';
      case performance:
        return 'Performance';
      case auditLogs:
        return 'Audit Logs';
      case offers:
        return 'Offers';
      case loyalty:
        return 'Loyalty Points';
      default:
        return feature;
    }
  }

  /// Evaluates dependencies: Ex. orderHistory requires orders and kds to be enabled.
  static List<String> withEnforcedDependencies(List<String> current) {
    final updated = Set<String>.from(current);

    // Dependency Rule: If Order History is enabled, Orders and KDS must be enabled
    if (updated.contains(orderHistory)) {
      updated.add(orders);
      updated.add(kds);
    }

    // Dependency Rule: If KDS is enabled, Orders must be enabled
    if (updated.contains(kds)) {
      updated.add(orders);
    }

    return updated.toList();
  }

  /// Inverse Dependency Rule: Ex. removing Orders removes KDS and Order History
  static List<String> withEnforcedRemovals(
    List<String> current,
    String removedItem,
  ) {
    final updated = Set<String>.from(current);

    // Inverse Dependency: Removing orders removes KDS and Order History
    if (removedItem == orders) {
      updated.remove(kds);
      updated.remove(orderHistory);
    }

    // Inverse Dependency: Removing KDS removes Order History
    if (removedItem == kds) {
      updated.remove(orderHistory);
    }

    return updated.toList();
  }
}
