import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hotel_manager/core/models/models.dart';
import 'package:hotel_manager/features/settings/data/repositories/settings_repository.dart';
import 'package:hotel_manager/core/services/database_service.dart';
import 'package:hotel_manager/core/services/audit_service.dart';
import 'package:hotel_manager/theme/app_design.dart';
import 'package:hotel_manager/component/cards/app_card.dart';
import 'package:hotel_manager/component/buttons/premium_button.dart';
import 'tax_rule_dialog.dart';

class TaxSettingsScreen extends StatelessWidget {
  const TaxSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Inject repository strictly for this screen if not provided globally
    return RepositoryProvider(
      create: (context) => SettingsRepository(
        databaseService: context.read<DatabaseService>(),
        auditService: AuditService(),
      ),
      child: const _TaxSettingsContent(),
    );
  }
}

class _TaxSettingsContent extends StatelessWidget {
  const _TaxSettingsContent();

  @override
  Widget build(BuildContext context) {
    final repo = context.read<SettingsRepository>();

    return Scaffold(
      backgroundColor: AppDesign.neutral50,
      appBar: AppBar(title: const Text('Tax & Service Charges')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(
              context,
              'Tax Rules (GST)',
              () => _showAddTaxDialog(context),
            ),
            const SizedBox(height: 16),
            StreamBuilder<List<TaxRule>>(
              stream: repo.streamTaxRules(),
              builder: (context, snapshot) {
                if (snapshot.hasError) return Text('Error: ${snapshot.error}');
                if (!snapshot.hasData)
                  return const Center(child: CircularProgressIndicator());

                final rules = snapshot.data!;
                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: rules.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) =>
                      _TaxRuleCard(rule: rules[index]),
                );
              },
            ),
            const SizedBox(height: 32),
            _buildHeader(context, 'Service Charges', () {
              // Future: Add Service Charge Dialog
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Manage Service Charges coming soon'),
                ),
              );
            }),
            const SizedBox(height: 16),
            StreamBuilder<List<ServiceChargeRule>>(
              stream: repo.streamServiceChargeRules(),
              builder: (context, snapshot) {
                if (snapshot.hasError) return Text('Error: ${snapshot.error}');
                if (!snapshot.hasData)
                  return const Center(child: CircularProgressIndicator());

                final rules = snapshot.data!;
                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: rules.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) =>
                      _ServiceChargeCard(rule: rules[index]),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String title, VoidCallback onAdd) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: AppDesign.titleLarge),
        PremiumButton.primary(
          label: 'Add New',
          icon: Icons.add,
          onPressed: onAdd,
        ),
      ],
    );
  }

  void _showAddTaxDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => RepositoryProvider.value(
        value: context.read<SettingsRepository>(), // Pass repo to dialog
        child: const TaxRuleDialog(), // New Rule (null)
      ),
    );
  }
}

class _TaxRuleCard extends StatelessWidget {
  final TaxRule rule;

  const _TaxRuleCard({required this.rule});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(
          rule.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          'CGST: ${rule.cgstPercent}%  SGST: ${rule.sgstPercent}%  Total: ${rule.getEffectiveTax()}%',
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Chip(
              label: Text(rule.isActive ? 'Active' : 'Inactive'),
              backgroundColor: rule.isActive
                  ? Colors.green.withOpacity(0.1)
                  : Colors.grey.withOpacity(0.1),
              labelStyle: TextStyle(
                color: rule.isActive ? Colors.green : Colors.grey,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => RepositoryProvider.value(
                    value: context.read<SettingsRepository>(),
                    child: TaxRuleDialog(existingRule: rule),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ServiceChargeCard extends StatelessWidget {
  final ServiceChargeRule rule;
  const _ServiceChargeCard({required this.rule});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(
          rule.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('Rate: ${rule.percent}%'),
        trailing: Chip(
          label: Text(rule.isActive ? 'Active' : 'Inactive'),
          backgroundColor: rule.isActive
              ? Colors.green.withOpacity(0.1)
              : Colors.grey.withOpacity(0.1),
          labelStyle: TextStyle(
            color: rule.isActive ? Colors.green : Colors.grey,
          ),
        ),
      ),
    );
  }
}
