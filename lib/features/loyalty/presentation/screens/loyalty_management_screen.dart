import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:hotel_manager/theme/app_design.dart';
import 'package:hotel_manager/core/models/models.dart';
import 'package:hotel_manager/features/loyalty/logic/loyalty_cubit.dart';
import 'package:hotel_manager/features/loyalty/logic/loyalty_state.dart';
import 'package:hotel_manager/component/cards/app_card.dart';
import 'package:hotel_manager/component/buttons/premium_button.dart';
import 'package:hotel_manager/component/inputs/app_text_field.dart';

class LoyaltyManagementScreen extends StatelessWidget {
  const LoyaltyManagementScreen({super.key});

  static const String routeName = '/loyalty';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppDesign.neutral50,
      appBar: AppBar(
        title: const Text('Loyalty Program'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: BlocBuilder<LoyaltyCubit, LoyaltyState>(
        builder: (context, state) {
          if (state is LoyaltyLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is LoyaltyError) {
            return Center(child: Text('Error: ${state.message}'));
          }

          if (state is LoyaltyLoaded) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _TiersSection(tiers: state.tiers),
                  const SizedBox(height: 48),
                  _RulesSection(rules: state.rules),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _TiersSection extends StatelessWidget {
  final List<LoyaltyTier> tiers;
  const _TiersSection({required this.tiers});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Loyalty Tiers',
              style: AppDesign.titleLarge.copyWith(fontWeight: FontWeight.bold),
            ),
            PremiumButton.primary(
              label: 'Add New Tier',
              onPressed: () => _showTierDialog(context),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (tiers.isEmpty)
          const _EmptyState(message: 'No loyalty tiers defined.')
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.2,
            ),
            itemCount: tiers.length,
            itemBuilder: (context, index) {
              return _TierCard(tier: tiers[index]);
            },
          ),
      ],
    );
  }

  void _showTierDialog(BuildContext context, [LoyaltyTier? tier]) {
    showDialog(
      context: context,
      builder: (context) => _TierFormDialog(tier: tier),
    );
  }
}

class _TierCard extends StatelessWidget {
  final LoyaltyTier tier;
  const _TierCard({required this.tier});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                tier.name,
                style: AppDesign.titleLarge.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppDesign.primaryStart,
                ),
              ),
              Switch(
                value: tier.isActive,
                onChanged: (val) {
                  final updated = LoyaltyTier(
                    id: tier.id,
                    name: tier.name,
                    minSpend: tier.minSpend,
                    earnMultiplier: tier.earnMultiplier,
                    redeemMultiplier: tier.redeemMultiplier,
                    benefits: tier.benefits,
                    isActive: val,
                  );
                  context.read<LoyaltyCubit>().saveTier(updated);
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Min Spend: ₹${tier.minSpend}',
            style: AppDesign.bodyMedium.copyWith(color: AppDesign.neutral600),
          ),
          Text(
            'Earn Multiplier: ${tier.earnMultiplier}x',
            style: AppDesign.bodyMedium.copyWith(color: AppDesign.neutral600),
          ),
          const Spacer(),
          Text(
            '${tier.benefits.length} Benefits',
            style: AppDesign.bodySmall.copyWith(
              color: AppDesign.primaryStart,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _RulesSection extends StatelessWidget {
  final List<PointRule> rules;
  const _RulesSection({required this.rules});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Point Earning Rules',
              style: AppDesign.titleLarge.copyWith(fontWeight: FontWeight.bold),
            ),
            PremiumButton.primary(
              label: 'Add Point Rule',
              onPressed: () => _showRuleDialog(context),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (rules.isEmpty)
          const _EmptyState(message: 'No earning rules set.')
        else
          ...rules.map(
            (rule) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: AppCard(
                child: ListTile(
                  leading: const Icon(Icons.stars, color: Colors.amber),
                  title: Text(
                    'Earn ${rule.earnValue} points per ₹100',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    'Type: ${rule.earnType.name.replaceAll('_', ' ')} • Min Bill: ₹${rule.minBillAmount}',
                  ),
                  trailing: Switch(
                    value: rule.isActive,
                    onChanged: (val) {
                      final updated = PointRule(
                        id: rule.id,
                        earnType: rule.earnType,
                        earnValue: rule.earnValue,
                        minBillAmount: rule.minBillAmount,
                        isActive: val,
                      );
                      context.read<LoyaltyCubit>().saveRule(updated);
                    },
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  void _showRuleDialog(BuildContext context, [PointRule? rule]) {
    showDialog(
      context: context,
      builder: (context) => _RuleFormDialog(rule: rule),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String message;
  const _EmptyState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Text(
          message,
          style: AppDesign.bodyMedium.copyWith(color: AppDesign.neutral500),
        ),
      ),
    );
  }
}

class _TierFormDialog extends StatefulWidget {
  final LoyaltyTier? tier;
  const _TierFormDialog({this.tier});

  @override
  State<_TierFormDialog> createState() => _TierFormDialogState();
}

class _TierFormDialogState extends State<_TierFormDialog> {
  final _formKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.tier == null ? 'Create Tier' : 'Edit Tier'),
      content: SizedBox(
        width: 400,
        child: FormBuilder(
          key: _formKey,
          initialValue: {
            'name': widget.tier?.name,
            'minSpend': widget.tier?.minSpend.toString(),
            'earnMultiplier': widget.tier?.earnMultiplier.toString() ?? '1.0',
            'redeemMultiplier':
                widget.tier?.redeemMultiplier.toString() ?? '1.0',
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppTextField(
                name: 'name',
                label: 'Tier Name (e.g. Gold)',
                validator: FormBuilderValidators.required(),
              ),
              const SizedBox(height: 16),
              AppTextField(
                name: 'minSpend',
                label: 'Min Spend to Unlock',
                keyboardType: TextInputType.number,
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(),
                  FormBuilderValidators.numeric(),
                ]),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      name: 'earnMultiplier',
                      label: 'Earn Multiplier',
                      keyboardType: TextInputType.number,
                      validator: FormBuilderValidators.required(),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: AppTextField(
                      name: 'redeemMultiplier',
                      label: 'Redeem Multiplier',
                      keyboardType: TextInputType.number,
                      validator: FormBuilderValidators.required(),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState?.saveAndValidate() ?? false) {
              final val = _formKey.currentState!.value;
              final newTier = LoyaltyTier(
                id:
                    widget.tier?.id ??
                    'tier_${DateTime.now().millisecondsSinceEpoch}',
                name: val['name'],
                minSpend: double.parse(val['minSpend']),
                earnMultiplier: double.parse(val['earnMultiplier']),
                redeemMultiplier: double.parse(val['redeemMultiplier']),
                isActive: widget.tier?.isActive ?? true,
              );
              context.read<LoyaltyCubit>().saveTier(newTier);
              Navigator.pop(context);
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}

class _RuleFormDialog extends StatefulWidget {
  final PointRule? rule;
  const _RuleFormDialog({this.rule});

  @override
  State<_RuleFormDialog> createState() => _RuleFormDialogState();
}

class _RuleFormDialogState extends State<_RuleFormDialog> {
  final _formKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.rule == null ? 'Add Point Rule' : 'Edit Point Rule'),
      content: SizedBox(
        width: 400,
        child: FormBuilder(
          key: _formKey,
          initialValue: {
            'earnType': widget.rule?.earnType ?? PointEarnType.bill_amount,
            'earnValue': widget.rule?.earnValue.toString() ?? '1',
            'minBillAmount': widget.rule?.minBillAmount.toString() ?? '0',
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FormBuilderDropdown<PointEarnType>(
                name: 'earnType',
                decoration: const InputDecoration(labelText: 'Earning Type'),
                items: PointEarnType.values
                    .map(
                      (t) => DropdownMenuItem(
                        value: t,
                        child: Text(t.name.toUpperCase()),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 16),
              AppTextField(
                name: 'earnValue',
                label: 'Points awarded',
                keyboardType: TextInputType.number,
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(),
                  FormBuilderValidators.numeric(),
                ]),
              ),
              const SizedBox(height: 16),
              AppTextField(
                name: 'minBillAmount',
                label: 'Min Bill Amount',
                keyboardType: TextInputType.number,
                validator: FormBuilderValidators.required(),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState?.saveAndValidate() ?? false) {
              final val = _formKey.currentState!.value;
              final newRule = PointRule(
                id:
                    widget.rule?.id ??
                    'rule_${DateTime.now().millisecondsSinceEpoch}',
                earnType: val['earnType'],
                earnValue: double.parse(val['earnValue']),
                minBillAmount: double.parse(val['minBillAmount']),
                isActive: widget.rule?.isActive ?? true,
              );
              context.read<LoyaltyCubit>().saveRule(newRule);
              Navigator.pop(context);
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
