import 'package:hotel_manager/core/models/models.dart';
import 'package:hotel_manager/core/services/database_service.dart';
import 'package:hotel_manager/core/repositories/base_firestore_repository.dart';

class SettingsRepository extends BaseFirestoreRepository<TaxRule> {
  final DatabaseService _databaseService;

  SettingsRepository({
    required DatabaseService databaseService,
    super.auditService,
  }) : _databaseService = databaseService,
       super(collectionPath: 'settings/tax_rules');

  @override
  TaxRule fromJson(Map<String, dynamic> json) => TaxRule.fromJson(json);

  // --- Tax Rules ---

  Stream<List<TaxRule>> streamTaxRules(String hotelId) {
    return _databaseService.streamTaxRules(hotelId);
  }

  Future<void> saveTaxRule(TaxRule rule, {User? performer}) async {
    await _databaseService.saveTaxRule(rule);

    await logAction(
      performer: performer,
      action: AuditAction.update,
      targetUserId: rule.id,
      description:
          'Updated tax rule: ${rule.name} (${rule.getEffectiveTax()}%)',
      newData: {
        'cgst': rule.cgstPercent,
        'sgst': rule.sgstPercent,
        'igst': rule.igstPercent,
      },
    );
  }

  Future<void> deleteTaxRule(
    String hotelId,
    String taxRuleId, {
    User? performer,
  }) async {
    await _databaseService.deleteTaxRule(hotelId, taxRuleId);

    await logAction(
      performer: performer,
      action: AuditAction.delete,
      targetUserId: taxRuleId,
      description: 'Deleted tax rule: $taxRuleId',
    );
  }

  // --- Service Charge Rules ---

  Stream<List<ServiceChargeRule>> streamServiceChargeRules(String hotelId) {
    return _databaseService.streamServiceChargeRules(hotelId);
  }

  Future<void> saveServiceChargeRule(
    ServiceChargeRule rule, {
    User? performer,
  }) async {
    await _databaseService.saveServiceChargeRule(rule);

    await logAction(
      performer: performer,
      action: AuditAction.update,
      targetUserId: rule.id,
      description: 'Updated service charge: ${rule.name} (${rule.percent}%)',
      newData: {'percent': rule.percent},
    );
  }

  Future<void> deleteServiceChargeRule(
    String hotelId,
    String id, {
    User? performer,
  }) async {
    await _databaseService.deleteServiceChargeRule(hotelId, id);

    await logAction(
      performer: performer,
      action: AuditAction.delete,
      targetUserId: id,
      description: 'Deleted service charge: $id',
    );
  }

  // --- Tables ---

  Stream<List<TableEntity>> streamTables(String hotelId) {
    return _databaseService.streamTables(hotelId);
  }

  Future<void> saveTable(TableEntity table, {User? performer}) async {
    await _databaseService.saveTable(table);

    await logAction(
      performer: performer,
      action: AuditAction.update,
      targetUserId: table.id,
      description: 'Updated table: ${table.name} (${table.tableCode})',
      newData: {'capacity': table.maxCapacity},
    );
  }

  Future<void> deleteTable(
    String hotelId,
    String tableId, {
    User? performer,
  }) async {
    await _databaseService.deleteTable(hotelId, tableId);

    await logAction(
      performer: performer,
      action: AuditAction.delete,
      targetUserId: tableId,
      description: 'Deleted table: $tableId',
    );
  }

  // --- Menu Management ---

  Stream<List<MenuItem>> streamMenuItems(String hotelId) =>
      _databaseService.streamMenuItems(hotelId);

  Future<void> saveMenuItem(MenuItem item, {User? performer}) async {
    await _databaseService.saveMenuItem(item);
    await logAction(
      performer: performer,
      action: AuditAction.update,
      targetUserId: item.id,
      description: 'Updated menu item: ${item.name}',
      newData: {'price': item.price, 'category': item.category.name},
    );
  }

  Future<void> deleteMenuItem(
    String hotelId,
    String itemId, {
    User? performer,
  }) async {
    await _databaseService.deleteMenuItem(hotelId, itemId);
    await logAction(
      performer: performer,
      action: AuditAction.delete,
      targetUserId: itemId,
      description: 'Deleted menu item $itemId',
    );
  }
}
