import '/core/models/models.dart';
import 'package:intl/intl.dart';

class HappyHourService {
  /// Checks if a happy hour is active for a given item at a specific time
  static HappyHour? getActiveHappyHour(
    List<HappyHour> happyHours,
    MenuItem item,
    DateTime time,
  ) {
    final String currentDay = DateFormat('EEEE').format(time);
    final String currentTimeStr = DateFormat('HH:mm').format(time);

    List<HappyHour> applicableHH = happyHours.where((hh) {
      if (!hh.isActive) return false;

      // Day check
      if (!hh.applicableDays.contains(currentDay)) return false;

      // Time check (Handle midnight cross if needed, but simple range for now)
      if (currentTimeStr.compareTo(hh.startTime) < 0 ||
          currentTimeStr.compareTo(hh.endTime) > 0) {
        return false;
      }

      // Item/Category filter
      final bool itemMatched =
          hh.applicableItemIds.isEmpty ||
          hh.applicableItemIds.contains(item.id);
      final bool categoryMatched =
          hh.applicableCategoryIds.isEmpty ||
          hh.applicableCategoryIds.contains(item.category.name);

      return itemMatched && categoryMatched;
    }).toList();

    if (applicableHH.isEmpty) return null;

    // Resolve by priority
    applicableHH.sort((a, b) => b.priority.compareTo(a.priority));
    return applicableHH.first;
  }

  /// Apply happy hour discount to an OrderItem
  static OrderItem applyHappyHour(OrderItem item, HappyHour? hh) {
    if (hh == null) return item;

    double discountAmount = 0.0;
    if (hh.discountType == DiscountType.percent) {
      discountAmount = item.price * (hh.discountValue / 100);
    } else {
      discountAmount = hh.discountValue;
    }

    return item.copyWith(
      discountAmount: discountAmount,
      discountType: hh.discountType,
      notes:
          '${item.notes != null ? '${item.notes}; ' : ''}Happy Hour: ${hh.name}',
    );
  }
}
