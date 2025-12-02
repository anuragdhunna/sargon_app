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

class EditChecklistScreen extends StatefulWidget {
  final Checklist checklist;

  const EditChecklistScreen({super.key, required this.checklist});

  @override
  State<EditChecklistScreen> createState() => _EditChecklistScreenState();
}

class _EditChecklistScreenState extends State<EditChecklistScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  late List<String> _tasks;
  final TextEditingController _taskController = TextEditingController();
  late bool _isTimeBound;

  @override
  void initState() {
    super.initState();
    _tasks = widget.checklist.items.map((item) => item.task).toList();
    _isTimeBound = widget.checklist.isTimeBound;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Checklist')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: FormBuilder(
          key: _formKey,
          initialValue: {
            'title': widget.checklist.title,
            'description': widget.checklist.description,
            'role': widget.checklist.assignedRole,
            'type': widget.checklist.type,
            'recurrence': widget.checklist.recurrence,
          },
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
                      decoration: const InputDecoration(labelText: 'Category', border: OutlineInputBorder()),
                      items: ChecklistType.values
                          .map((type) => DropdownMenuItem(value: type, child: Text(type.name.toUpperCase())))
                          .toList(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SwitchListTile(
                title: const Text('Time-Bound Task'),
                subtitle: const Text('Task has a deadline'),
                value: _isTimeBound,
                onChanged: (val) => setState(() => _isTimeBound = val),
              ),
              const SizedBox(height: 16),
              FormBuilderDropdown<RecurrencePattern>(
                name: 'recurrence',
                decoration: const InputDecoration(labelText: 'Recurrence', border: OutlineInputBorder()),
                items: RecurrencePattern.values
                    .map((pattern) => DropdownMenuItem(
                          value: pattern,
                          child: Text(pattern.name.toUpperCase()),
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
                label: 'Update Checklist',
                onPressed: () {
                  if (_formKey.currentState?.saveAndValidate() ?? false) {
                    if (_tasks.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please add at least one task.')),
                      );
                      return;
                    }

                    final data = _formKey.currentState!.value;
                    final updatedChecklist = widget.checklist.copyWith(
                      title: data['title'],
                      description: data['description'],
                      type: data['type'],
                      assignedRole: data['role'],
                      isTimeBound: _isTimeBound,
                      recurrence: data['recurrence'],
                    );

                    context.read<ChecklistCubit>().updateChecklist(updatedChecklist);
                    context.pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Checklist Updated!')),
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
}
