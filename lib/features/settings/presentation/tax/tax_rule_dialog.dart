import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hotel_manager/core/models/billing_models.dart';
import 'package:hotel_manager/features/settings/data/repositories/settings_repository.dart';
import 'package:hotel_manager/features/auth/logic/auth_cubit.dart';
import 'package:hotel_manager/features/auth/logic/auth_state.dart';
import 'package:hotel_manager/component/inputs/app_text_field.dart';
import 'package:hotel_manager/component/buttons/premium_button.dart';
import 'package:uuid/uuid.dart';

class TaxRuleDialog extends StatefulWidget {
  final TaxRule? existingRule;

  const TaxRuleDialog({super.key, this.existingRule});

  @override
  State<TaxRuleDialog> createState() => _TaxRuleDialogState();
}

class _TaxRuleDialogState extends State<TaxRuleDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _cgstController = TextEditingController();
  final _sgstController = TextEditingController();
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    if (widget.existingRule != null) {
      _nameController.text = widget.existingRule!.name;
      _cgstController.text = widget.existingRule!.cgstPercent.toString();
      _sgstController.text = widget.existingRule!.sgstPercent.toString();
      _isActive = widget.existingRule!.isActive;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _cgstController.dispose();
    _sgstController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_formKey.currentState!.validate()) {
      final authState = context.read<AuthCubit>().state;
      String userId = 'unknown';
      String userName = 'Unknown User';

      if (authState is AuthVerified) {
        userId = authState.userId;
        userName = authState.userName;
      }

      final cgst = double.tryParse(_cgstController.text) ?? 0.0;
      final sgst = double.tryParse(_sgstController.text) ?? 0.0;

      final rule = TaxRule(
        id: widget.existingRule?.id ?? const Uuid().v4(),
        name: _nameController.text,
        cgstPercent: cgst,
        sgstPercent: sgst,
        isActive: _isActive,
      );

      try {
        await context.read<SettingsRepository>().saveTaxRule(
          rule,
          userId,
          userName,
        );
        if (mounted) Navigator.of(context).pop();
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error saving tax rule: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.existingRule != null ? 'Edit Tax Rule' : 'Add Tax Rule',
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppTextField(
                controller: _nameController,
                label: 'Rule Name (e.g., GST 5%)',
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      controller: _cgstController,
                      label: 'CGST %',
                      keyboardType: TextInputType.number,
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: AppTextField(
                      controller: _sgstController,
                      label: 'SGST %',
                      keyboardType: TextInputType.number,
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Required' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Active'),
                value: _isActive,
                onChanged: (v) => setState(() => _isActive = v),
              ),
              if (widget.existingRule != null) ...[
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Delete Rule?'),
                        content: const Text(
                          'Are you sure you want to delete this tax rule?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text(
                              'Delete',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    );

                    if (confirm == true && context.mounted) {
                      final authState = context.read<AuthCubit>().state;
                      String userId = 'unknown';
                      String userName = 'Unknown User';
                      if (authState is AuthVerified) {
                        userId = authState.userId;
                        userName = authState.userName;
                      }

                      await context.read<SettingsRepository>().deleteTaxRule(
                        widget.existingRule!.id,
                        userId,
                        userName,
                      );
                      if (context.mounted) Navigator.pop(context);
                    }
                  },
                  icon: const Icon(Icons.delete, color: Colors.red),
                  label: const Text(
                    'Delete Rule',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        PremiumButton.primary(label: 'Save', onPressed: _save),
      ],
    );
  }
}
