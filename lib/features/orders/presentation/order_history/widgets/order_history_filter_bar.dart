import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:hotel_manager/theme/app_design.dart';
import 'package:hotel_manager/core/models/models.dart';
import 'package:hotel_manager/component/inputs/app_dropdown.dart';

class OrderHistoryFilterBar extends StatelessWidget {
  final String customerQuery;
  final String? selectedStatus;
  final bool showOnlyUnpaid;
  final DateTime? startDate;
  final DateTime? endDate;
  final Function(String) onSearchChanged;
  final Function(String?) onStatusChanged;
  final Function(bool) onUnpaidToggle;
  final VoidCallback onSelectDateRange;
  final VoidCallback onClearDateRange;

  const OrderHistoryFilterBar({
    super.key,
    required this.customerQuery,
    this.selectedStatus,
    required this.showOnlyUnpaid,
    this.startDate,
    this.endDate,
    required this.onSearchChanged,
    required this.onStatusChanged,
    required this.onUnpaidToggle,
    required this.onSelectDateRange,
    required this.onClearDateRange,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search Customer/Phone...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  onChanged: onSearchChanged,
                ),
              ),
              const SizedBox(width: 12),
              IconButton(
                icon: const Icon(
                  Icons.calendar_today,
                  color: AppDesign.primaryStart,
                ),
                onPressed: onSelectDateRange,
              ),
              if (startDate != null)
                IconButton(
                  icon: const Icon(Icons.clear, color: Colors.red),
                  onPressed: onClearDateRange,
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: AppDropdown<String?>(
                  name: 'status',
                  label: 'Status',
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text('All Status'),
                    ),
                    ...OrderStatus.values.map(
                      (s) => DropdownMenuItem(
                        value: s.name,
                        child: Text(s.displayName),
                      ),
                    ),
                  ],
                  onChanged: onStatusChanged,
                  initialValue: selectedStatus,
                ),
              ),
              const SizedBox(width: 12),
              FilterChip(
                label: const Text('Unpaid'),
                selected: showOnlyUnpaid,
                onSelected: onUnpaidToggle,
                selectedColor: AppDesign.primaryStart.withOpacity(0.1),
                checkmarkColor: AppDesign.primaryStart,
              ),
            ],
          ),
          if (startDate != null && endDate != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Date: ${DateFormat('dd MMM').format(startDate!)} - ${DateFormat('dd MMM').format(endDate!)}',
                style: AppDesign.bodySmall.copyWith(
                  color: AppDesign.primaryStart,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
