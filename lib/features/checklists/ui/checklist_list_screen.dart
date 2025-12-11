import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hotel_manager/component/buttons/premium_button.dart';
import 'package:hotel_manager/component/cards/app_card.dart';
import 'package:hotel_manager/component/states/empty_state.dart';
import 'package:hotel_manager/features/auth/logic/auth_cubit.dart';
import 'package:hotel_manager/features/auth/logic/auth_state.dart';
import 'package:hotel_manager/features/checklists/data/checklist_model.dart';
import 'package:hotel_manager/features/checklists/logic/checklist_cubit.dart';
import 'package:hotel_manager/features/staff_mgmt/data/user_model.dart';
import 'package:hotel_manager/theme/app_design.dart';
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
              return const EmptyState(
                icon: Icons.task_alt,
                title: 'No Tasks Assigned',
                message: 'You have no pending tasks. Great job! 🎉',
              );
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

    return AppCard(
      padding: EdgeInsets.zero,
      child: ExpansionTile(
        title: Text(
          checklist.title,
          style: AppDesign.titleMedium.copyWith(
            fontWeight: FontWeight.bold,
            decoration: isCompleted ? TextDecoration.lineThrough : null,
            color: isCompleted ? AppDesign.neutral500 : AppDesign.neutral900,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              checklist.description,
              style: AppDesign.bodySmall.copyWith(color: AppDesign.neutral600),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Chip(
                  label: Text(
                    checklist.assignedRole.name.toUpperCase(),
                    style: AppDesign.labelSmall,
                  ),
                  padding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                  backgroundColor: AppDesign.primaryStart.withOpacity(0.1),
                ),
                const SizedBox(width: 8),
                Text(
                  'Due: ${DateFormat('MMM d, h:mm a').format(checklist.dueDate)}',
                  style: AppDesign.bodySmall.copyWith(
                    color: AppDesign.error,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: AppDesign.neutral200,
              color: isCompleted ? AppDesign.success : AppDesign.info,
            ),
          ],
        ),
        children: checklist.items.map((item) {
          return CheckboxListTile(
            title: Text(
              item.task,
              style: AppDesign.bodyMedium.copyWith(
                decoration: item.isCompleted
                    ? TextDecoration.lineThrough
                    : null,
                color: item.isCompleted
                    ? AppDesign.neutral500
                    : AppDesign.neutral900,
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
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppDesign.radiusLg),
                      ),
                      title: Text(
                        'Cross-Role Completion',
                        style: AppDesign.titleLarge,
                      ),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'You are completing a task assigned to ${checklist.assignedRole.name}. Please provide a reason.',
                            style: AppDesign.bodyMedium,
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            decoration: InputDecoration(
                              labelText: 'Reason',
                              hintText:
                                  'Enter reason for cross-role completion',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                  AppDesign.radiusMd,
                                ),
                              ),
                              filled: true,
                              fillColor: AppDesign.neutral50,
                            ),
                            onChanged: (value) => reason = value,
                            maxLines: 2,
                          ),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                        PremiumButton.primary(
                          label: 'Complete',
                          onPressed: () {
                            if (reason.trim().isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Reason is required'),
                                  backgroundColor: Colors.red,
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
