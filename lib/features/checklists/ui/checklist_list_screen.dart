import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hotel_manager/features/auth/logic/auth_cubit.dart';
import 'package:hotel_manager/features/auth/logic/auth_state.dart';
import 'package:hotel_manager/features/checklists/data/checklist_model.dart';
import 'package:hotel_manager/features/checklists/logic/checklist_cubit.dart';
import 'package:hotel_manager/features/staff_mgmt/data/user_model.dart';
import 'package:intl/intl.dart';

class ChecklistListScreen extends StatelessWidget {
  const ChecklistListScreen({super.key});

  static const String routeName = '/checklists';

  @override
  Widget build(BuildContext context) {
    // Check if user can create checklists
    final authState = context.read<AuthCubit>().state;
    final canCreate =
        authState is AuthVerified &&
        [UserRole.owner, UserRole.manager].contains(authState.role);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Tasks'),
        actions: [
          if (canCreate)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => context.push('/checklists/create'),
            ),
        ],
      ),
      body: BlocBuilder<ChecklistCubit, ChecklistState>(
        builder: (context, state) {
          if (state is ChecklistLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ChecklistLoaded) {
            if (state.checklists.isEmpty) {
              return const Center(child: Text('No tasks assigned! 🎉'));
            }
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: state.checklists.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final checklist = state.checklists[index];
                return _ChecklistCard(checklist: checklist);
              },
            );
          }
          return const Center(child: Text('Something went wrong'));
        },
      ),
    );
  }
}

class _ChecklistCard extends StatelessWidget {
  final Checklist checklist;

  const _ChecklistCard({required this.checklist});

  @override
  Widget build(BuildContext context) {
    final progress =
        checklist.items.where((i) => i.isCompleted).length /
        checklist.items.length;
    final isCompleted = progress == 1.0;

    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: ExpansionTile(
        title: Text(
          checklist.title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            decoration: isCompleted ? TextDecoration.lineThrough : null,
            color: isCompleted ? Colors.grey : Colors.black,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              checklist.description,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Chip(
                  label: Text(
                    checklist.assignedRole.name.toUpperCase(),
                    style: const TextStyle(fontSize: 10),
                  ),
                  padding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                ),
                const SizedBox(width: 8),
                Text(
                  'Due: ${DateFormat('MMM d, h:mm a').format(checklist.dueDate)}',
                  style: TextStyle(
                    color: Colors.red.shade700,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey.shade200,
              color: isCompleted ? Colors.green : Colors.blue,
            ),
          ],
        ),
        children: checklist.items.map((item) {
          return CheckboxListTile(
            title: Text(
              item.task,
              style: TextStyle(
                decoration: item.isCompleted
                    ? TextDecoration.lineThrough
                    : null,
                color: item.isCompleted ? Colors.grey : Colors.black,
              ),
            ),
            value: item.isCompleted,
            onChanged: (val) {
              if (val == null) return;

              final authState = context.read<AuthCubit>().state;
              if (authState is! AuthVerified) return;

              final currentUserRole = authState.role;
              final isCrossRole =
                  currentUserRole != checklist.assignedRole &&
                  currentUserRole !=
                      UserRole
                          .owner; // Owner can do anything without reason? Maybe not.
              // Let's say Owner also needs to give reason if doing Housekeeping task, for audit.
              // Or maybe Owner is exempt. The prompt says "Cross-role completion reason".
              // Let's enforce it for everyone if roles don't match.

              if (val == true && currentUserRole != checklist.assignedRole) {
                // Cross-role completion: Ask for reason
                showDialog(
                  context: context,
                  builder: (context) {
                    String reason = '';
                    return AlertDialog(
                      title: const Text('Cross-Role Completion'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'You are completing a task assigned to ${checklist.assignedRole.name}. Please provide a reason.',
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            decoration: const InputDecoration(
                              labelText: 'Reason',
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (value) => reason = value,
                          ),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                        FilledButton(
                          onPressed: () {
                            if (reason.trim().isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Reason is required'),
                                ),
                              );
                              return;
                            }
                            context.read<ChecklistCubit>().toggleItem(
                              checklist.id,
                              item.id,
                              reason: reason,
                              userId: authState.userId,
                              userName: authState.userName,
                              userRole: authState.role.name,
                            );
                            Navigator.pop(context);
                          },
                          child: const Text('Complete'),
                        ),
                      ],
                    );
                  },
                );
              } else {
                // Normal completion or unchecking
                context.read<ChecklistCubit>().toggleItem(
                  checklist.id,
                  item.id,
                  userId: authState.userId,
                  userName: authState.userName,
                  userRole: authState.role.name,
                );
              }
            },
            controlAffinity: ListTileControlAffinity.leading,
          );
        }).toList(),
      ),
    );
  }
}
