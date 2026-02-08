import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hotel_manager/core/models/models.dart';
import 'package:hotel_manager/features/settings/data/repositories/settings_repository.dart';
import 'package:hotel_manager/features/auth/logic/auth_cubit.dart';
import 'package:hotel_manager/features/auth/logic/auth_state.dart';
import 'package:hotel_manager/component/inputs/app_text_field.dart';
import 'package:hotel_manager/component/buttons/premium_button.dart';
import 'package:uuid/uuid.dart';

class TableDialog extends StatefulWidget {
  final TableEntity? existingTable;

  const TableDialog({super.key, this.existingTable});

  @override
  State<TableDialog> createState() => _TableDialogState();
}

class _TableDialogState extends State<TableDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _codeController = TextEditingController();
  final _capacityController = TextEditingController();

  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    if (widget.existingTable != null) {
      _codeController.text = widget.existingTable!.tableCode;
      _capacityController.text = widget.existingTable!.maxCapacity.toString();
      _isActive = widget.existingTable!.isActive;
      _nameController.text = widget.existingTable!.name;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _capacityController.dispose();
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

      final table = TableEntity(
        id: widget.existingTable?.id ?? const Uuid().v4(),
        name: _nameController.text,
        tableCode: _codeController.text,
        maxCapacity: int.tryParse(_capacityController.text) ?? 2,
        status: widget.existingTable?.status ?? TableStatus.available,
        isActive: _isActive,
      );

      try {
        await context.read<SettingsRepository>().saveTable(
          table,
          userId,
          userName,
        );
        if (mounted) Navigator.of(context).pop();
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error saving table: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.existingTable != null ? 'Edit Table' : 'Add Table'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppTextField(
                controller: _nameController,
                label: 'Table Name (e.g. Front Lawn 1)',
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      controller: _codeController,
                      label: 'Short Code (T1)',
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: AppTextField(
                      controller: _capacityController,
                      label: 'Capacity',
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
