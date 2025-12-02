import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';
import 'package:hotel_manager/component/buttons/primary_button.dart';
import 'package:hotel_manager/component/inputs/custom_text_field.dart';
import 'package:hotel_manager/features/checklists/data/checklist_model.dart';
import 'package:hotel_manager/features/checklists/logic/checklist_cubit.dart';
import 'package:hotel_manager/features/staff_mgmt/data/user_model.dart';
import 'package:uuid/uuid.dart';

class CreateChecklistScreen extends StatefulWidget {
  const CreateChecklistScreen({super.key});

  @override
  State<CreateChecklistScreen> createState() => _CreateChecklistScreenState();
}

class _CreateChecklistScreenState extends State<CreateChecklistScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  final List<String> _tasks = [];
  final TextEditingController _taskController = TextEditingController();
  bool _isTimeBound = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create New Checklist')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: FormBuilder(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTextField(
                name: 'title',
                label: 'Checklist Title',
                hint: 'e.g., Kitchen Closing Protocol',
                validator: FormBuilderValidators.required(),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                name: 'description',
                label: 'Description',
                hint: 'Brief instructions...',
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: FormBuilderDropdown<UserRole>(
                      name: 'role',
                      initialValue: UserRole.housekeeping,
                      decoration: const InputDecoration(labelText: 'Assign To Role', border: OutlineInputBorder()),
                      items: UserRole.values
                          .map((role) => DropdownMenuItem(value: role, child: Text(role.name.toUpperCase())))
                          .toList(),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: FormBuilderDropdown<ChecklistType>(
                      name: 'type',
                      initialValue: ChecklistType.general,
                      decoration: const InputDecoration(labelText: 'Category', border: OutlineInputBorder()),
                      items: ChecklistType.values
                          .map((type) => DropdownMenuItem(value: type, child: Text(type.name.toUpperCase())))
                          .toList(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // Time-bound toggle
              SwitchListTile(
                title: const Text('Time-Bound Task'),
                subtitle: const Text('Task has a deadline'),
                value: _isTimeBound,
                onChanged: (val) => setState(() => _isTimeBound = val),
              ),
              
              const SizedBox(height: 16),
              
              // Recurrence pattern
              FormBuilderDropdown<RecurrencePattern>(
                name: 'recurrence',
                initialValue: RecurrencePattern.none,
                decoration: const InputDecoration(
                  labelText: 'Recurrence',
                  border: OutlineInputBorder(),
                  helperText: 'How often should this checklist repeat?',
                ),
                items: RecurrencePattern.values
                    .map((pattern) => DropdownMenuItem(
                          value: pattern,
                          child: Text(_getRecurrenceLabel(pattern)),
                        ))
                    .toList(),
              ),
              
              const SizedBox(height: 24),
              const Text('Tasks', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _taskController,
                      decoration: const InputDecoration(hintText: 'Enter task item', border: OutlineInputBorder()),
                      onSubmitted: (_) => _addTask(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: _addTask,
                    icon: const Icon(Icons.add),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (_tasks.isEmpty)
                const Text('No tasks added yet.', style: TextStyle(color: Colors.grey))
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _tasks.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: CircleAvatar(child: Text('${index + 1}')),
                      title: Text(_tasks[index]),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          setState(() {
                            _tasks.removeAt(index);
                          });
                        },
                      ),
                    );
                  },
                ),
              const SizedBox(height: 32),
              PrimaryButton(
                label: 'Publish Checklist',
                onPressed: () {
                  if (_formKey.currentState?.saveAndValidate() ?? false) {
                    if (_tasks.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please add at least one task.')),
                      );
                      return;
                    }

                    final data = _formKey.currentState!.value;
                    final checklist = Checklist(
                      id: const Uuid().v4(),
                      title: data['title'],
                      description: data['description'] ?? '',
                      type: data['type'],
                      status: ChecklistStatus.pending,
                      assignedRole: data['role'],
                      dueDate: DateTime.now().add(const Duration(hours: 24)),
                      items: _tasks.map((t) => ChecklistItem(id: const Uuid().v4(), task: t)).toList(),
                      isTimeBound: _isTimeBound,
                      recurrence: data['recurrence'] ?? RecurrencePattern.none,
                    );

                    context.read<ChecklistCubit>().addChecklist(checklist);
                    context.pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Checklist Published!')),
                    );
                  }
                },
              ),
            ],

          ),
        ),
      ),
    );
  }

  void _addTask() {
    if (_taskController.text.isNotEmpty) {
      setState(() {
        _tasks.add(_taskController.text);
        _taskController.clear();
      });
    }
  }

  String _getRecurrenceLabel(RecurrencePattern pattern) {
    switch (pattern) {
      case RecurrencePattern.none:
        return 'One-time';
      case RecurrencePattern.daily:
        return 'Daily';
      case RecurrencePattern.weekly:
        return 'Weekly';
      case RecurrencePattern.monthly:
        return 'Monthly';
      case RecurrencePattern.quarterly:
        return 'Quarterly';
    }
  }
}
