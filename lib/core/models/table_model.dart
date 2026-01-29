import 'package:equatable/equatable.dart';

/// Table status enum matching the lifecycle machine
enum TableStatus { available, occupied, billed, cleaning, reserved }

/// Extension for display names and colors
extension TableStatusExtension on TableStatus {
  String get displayName {
    switch (this) {
      case TableStatus.available:
        return 'Available';
      case TableStatus.occupied:
        return 'Occupied';
      case TableStatus.billed:
        return 'Billed';
      case TableStatus.cleaning:
        return 'Cleaning';
      case TableStatus.reserved:
        return 'Reserved';
    }
  }
}

/// Table model representing a physical table in the restaurant/bar
class TableEntity extends Equatable {
  final String id;
  final String tableCode; // T1, T2, B1 (Bar)
  final int minCapacity;
  final int maxCapacity;
  final List<String> joinableTableIds;
  final TableStatus status;
  final bool isBarTable;
  final bool isActive;
  final String? currentGroupId; // If part of a joined group

  const TableEntity({
    required this.id,
    required this.tableCode,
    required this.minCapacity,
    required this.maxCapacity,
    this.joinableTableIds = const [],
    this.status = TableStatus.available,
    this.isBarTable = false,
    this.isActive = true,
    this.currentGroupId,
  });

  TableEntity copyWith({
    String? id,
    String? tableCode,
    int? minCapacity,
    int? maxCapacity,
    List<String>? joinableTableIds,
    TableStatus? status,
    bool? isBarTable,
    bool? isActive,
    String? currentGroupId,
  }) {
    return TableEntity(
      id: id ?? this.id,
      tableCode: tableCode ?? this.tableCode,
      minCapacity: minCapacity ?? this.minCapacity,
      maxCapacity: maxCapacity ?? this.maxCapacity,
      joinableTableIds: joinableTableIds ?? this.joinableTableIds,
      status: status ?? this.status,
      isBarTable: isBarTable ?? this.isBarTable,
      isActive: isActive ?? this.isActive,
      currentGroupId: currentGroupId ?? this.currentGroupId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tableCode': tableCode,
      'minCapacity': minCapacity,
      'maxCapacity': maxCapacity,
      'joinableTableIds': joinableTableIds,
      'status': status.name,
      'isBarTable': isBarTable,
      'isActive': isActive,
      'currentGroupId': currentGroupId,
    };
  }

  factory TableEntity.fromJson(Map<String, dynamic> json) {
    return TableEntity(
      id: json['id']?.toString() ?? '',
      tableCode: json['tableCode']?.toString() ?? 'T-?',
      minCapacity: (json['minCapacity'] as num?)?.toInt() ?? 1,
      maxCapacity: (json['maxCapacity'] as num?)?.toInt() ?? 4,
      joinableTableIds: List<String>.from(json['joinableTableIds'] ?? []),
      status: TableStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => TableStatus.available,
      ),
      isBarTable: json['isBarTable'] as bool? ?? false,
      isActive: json['isActive'] as bool? ?? true,
      currentGroupId: json['currentGroupId']?.toString(),
    );
  }

  @override
  List<Object?> get props => [
    id,
    tableCode,
    minCapacity,
    maxCapacity,
    joinableTableIds,
    status,
    isBarTable,
    isActive,
    currentGroupId,
  ];
}

/// Represents a group of joined tables
class TableGroup extends Equatable {
  final String id;
  final List<String> tableIds;
  final int totalCapacity;

  const TableGroup({
    required this.id,
    required this.tableIds,
    required this.totalCapacity,
  });

  Map<String, dynamic> toJson() {
    return {'id': id, 'tableIds': tableIds, 'totalCapacity': totalCapacity};
  }

  factory TableGroup.fromJson(Map<String, dynamic> json) {
    return TableGroup(
      id: json['id'] as String,
      tableIds: List<String>.from(json['tableIds']),
      totalCapacity: json['totalCapacity'] as int,
    );
  }

  @override
  List<Object?> get props => [id, tableIds, totalCapacity];
}
