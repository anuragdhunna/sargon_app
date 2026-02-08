import 'package:hotel_manager/core/models/models.dart';
import 'package:hotel_manager/core/models/billing_models.dart';
import 'package:hotel_manager/core/services/database_service.dart';
import 'package:hotel_manager/core/services/audit_service.dart';

class SettingsRepository {
  final DatabaseService _databaseService;
  final AuditService _auditService;

  SettingsRepository({
    required DatabaseService databaseService,
    required AuditService auditService,
  }) : _databaseService = databaseService,
       _auditService = auditService;

  // --- Tax Rules ---

  Stream<List<TaxRule>> streamTaxRules() {
    return _databaseService.streamTaxRules();
  }

  Future<void> saveTaxRule(TaxRule rule, String userId, String userName) async {
    await _databaseService.saveTaxRule(rule);

    await _auditService.log(
      userId: userId,
      userName: userName,
      userRole: 'admin',
      action: AuditAction.update,
      entity: 'tax_rule',
      entityId: rule.id,
      description:
          'Updated tax rule: ${rule.name} (${rule.getEffectiveTax()}%)',
      metadata: {
        'cgst': rule.cgstPercent,
        'sgst': rule.sgstPercent,
        'igst': rule.igstPercent,
      },
    );
  }

  Future<void> deleteTaxRule(
    String taxRuleId,
    String userId,
    String userName,
  ) async {
    await _databaseService.deleteTaxRule(taxRuleId);

    await _auditService.log(
      userId: userId,
      userName: userName,
      userRole: 'admin',
      action: AuditAction.delete,
      entity: 'tax_rule',
      entityId: taxRuleId,
      description: 'Deleted tax rule: $taxRuleId',
    );
  }

  // --- Service Charge Rules ---

  Stream<List<ServiceChargeRule>> streamServiceChargeRules() {
    return _databaseService.streamServiceChargeRules();
  }

  Future<void> saveServiceChargeRule(
    ServiceChargeRule rule,
    String userId,
    String userName,
  ) async {
    await _databaseService.saveServiceChargeRule(rule);

    await _auditService.log(
      userId: userId,
      userName: userName,
      userRole: 'admin',
      action: AuditAction.update,
      entity: 'service_charge_rule',
      entityId: rule.id,
      description: 'Updated service charge: ${rule.name} (${rule.percent}%)',
      metadata: {'percent': rule.percent},
    );
  }

  // --- Tables ---

  Stream<List<TableEntity>> streamTables() {
    return _databaseService.streamTables();
  }

  Future<void> saveTable(
    TableEntity table,
    String userId,
    String userName,
  ) async {
    await _databaseService.saveTable(table);

    await _auditService.log(
      userId: userId,
      userName: userName,
      userRole: 'admin',
      action: AuditAction.update,
      entity: 'table',
      entityId: table.id,
      description: 'Updated table: ${table.name} (${table.tableCode})',
      metadata: {'capacity': table.maxCapacity},
    );
  }

  Future<void> deleteTable(
    String tableId,
    String userId,
    String userName,
  ) async {
    await _databaseService.deleteTable(tableId);

    await _auditService.log(
      userId: userId,
      userName: userName,
      userRole: 'admin',
      action: AuditAction.delete,
      entity: 'table',
      entityId: tableId,
      description: 'Deleted table: $tableId',
    );
  }

  // --- Menu Management ---

  Stream<List<MenuItem>> streamMenuItems() =>
      _databaseService.streamMenuItems();

  Future<void> saveMenuItem(
    MenuItem item,
    String userId,
    String userName,
  ) async {
    await _databaseService.saveMenuItem(item);
    await _auditService.log(
      userId: userId,
      userName: userName,
      userRole: 'admin',
      action: AuditAction.update,
      entity: 'menu_item',
      entityId: item.id,
      description: 'Updated menu item: ${item.name}',
      metadata: {'price': item.price, 'category': item.category.name},
    );
  }

  Future<void> deleteMenuItem(
    String itemId,
    String userId,
    String userName,
  ) async {
    await _databaseService.deleteMenuItem(itemId);
    await _auditService.log(
      userId: userId,
      userName: userName,
      userRole: 'admin',
      action: AuditAction.delete,
      entity: 'menu_item',
      entityId: itemId,
      description: 'Deleted menu item $itemId',
    );
  }
}
