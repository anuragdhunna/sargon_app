import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hotel_manager/component/buttons/icon_button_with_label.dart';
import 'package:hotel_manager/component/cards/app_card.dart';
import 'package:hotel_manager/component/states/empty_state.dart';
import 'package:hotel_manager/features/auth/logic/auth_cubit.dart';
import 'package:hotel_manager/features/auth/logic/auth_state.dart';
import 'package:hotel_manager/features/staff_mgmt/data/user_model.dart';
import 'package:hotel_manager/features/staff_mgmt/logic/user_cubit.dart';
import 'package:hotel_manager/features/staff_mgmt/ui/add_user_dialog.dart';
import 'package:hotel_manager/theme/app_design.dart';

/// Staff/User Management Screen
///
/// Only admin (owner) and manager can add new staff members.
/// All authenticated users can view the staff directory.
class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  static const String routeName = '/users';

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  UserRole? _selectedRole;

  /// Check if current user can manage staff (add/delete)
  bool _canManageStaff(AuthState authState) {
    if (authState is AuthVerified) {
      return authState.role == UserRole.owner ||
          authState.role == UserRole.manager;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthCubit>().state;
    final canManage = _canManageStaff(authState);

    return Scaffold(
      backgroundColor: AppDesign.neutral50,
      appBar: AppBar(
        title: const Text('Staff Directory'),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          // Only show Add button for admin/manager
          if (canManage)
            IconButtonWithLabel(
              icon: Icons.add,
              label: 'Add',
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => BlocProvider.value(
                    value: context.read<UserCubit>(),
                    child: const AddUserDialog(),
                  ),
                );
              },
              isVertical: true,
              iconSize: 20,
              fontSize: 10,
            ),
          const SizedBox(width: AppDesign.space2),
        ],
      ),
      body: Column(
        children: [
          // Filters
          SizedBox(
            height: 60,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: const Text('All'),
                    selected: _selectedRole == null,
                    onSelected: (val) {
                      setState(() => _selectedRole = null);
                      context.read<UserCubit>().filterUsers(null);
                    },
                  ),
                ),
                ...UserRole.values.map((role) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(role.name.toUpperCase()),
                      selected: _selectedRole == role,
                      onSelected: (val) {
                        setState(() => _selectedRole = role);
                        context.read<UserCubit>().filterUsers(role);
                      },
                    ),
                  );
                }),
              ],
            ),
          ),

          // User List
          Expanded(
            child: BlocBuilder<UserCubit, UserState>(
              builder: (context, state) {
                if (state is UserLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is UserLoaded) {
                  if (state.users.isEmpty) {
                    return const EmptyState(
                      icon: Icons.people_outline,
                      title: 'No Staff Members',
                      message: 'Add your first staff member to get started',
                    );
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: state.users.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final user = state.users[index];
                      return _UserCard(
                        user: user,
                        canManage: canManage,
                        onDelete: () {
                          context.read<UserCubit>().deleteUser(user.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('User Deleted')),
                          );
                        },
                      );
                    },
                  );
                }
                return const Center(child: Text('Something went wrong'));
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// User card widget displaying staff member information
class _UserCard extends StatelessWidget {
  final User user;
  final bool canManage;
  final VoidCallback onDelete;

  const _UserCard({
    required this.user,
    required this.canManage,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDesign.space3,
        vertical: AppDesign.space3,
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppDesign.primaryStart.withAlpha(25),
            radius: 24,
            child: Text(
              user.name[0].toUpperCase(),
              style: AppDesign.titleMedium.copyWith(
                color: AppDesign.primaryStart,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: AppDesign.space3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  style: AppDesign.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.work, size: 14, color: AppDesign.neutral600),
                    const SizedBox(width: 4),
                    Text(
                      user.role.name.toUpperCase(),
                      style: AppDesign.bodySmall.copyWith(
                        color: AppDesign.neutral600,
                      ),
                    ),
                    if (user.email != null && user.email!.isNotEmpty) ...[
                      const SizedBox(width: 12),
                      Icon(Icons.email, size: 14, color: AppDesign.neutral600),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          user.email!,
                          style: AppDesign.bodySmall.copyWith(
                            color: AppDesign.neutral600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          // Toggle Status
          if (canManage)
            Switch(
              value: user.status == UserStatus.active,
              activeThumbColor: AppDesign.success,
              onChanged: (val) {
                context.read<UserCubit>().toggleUserStatus(user.id);
              },
            ),

          // Only show menu for admin/manager
          if (canManage)
            PopupMenuButton(
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'edit', child: Text('Edit')),
                PopupMenuItem(
                  value: 'delete',
                  child: Text(
                    'Delete',
                    style: TextStyle(color: AppDesign.error),
                  ),
                ),
              ],
              onSelected: (val) {
                if (val == 'delete') {
                  _showDeleteConfirmation(context);
                } else if (val == 'edit') {
                  showDialog(
                    context: context,
                    builder: (_) => BlocProvider.value(
                      value: context.read<UserCubit>(),
                      child: AddUserDialog(user: user),
                    ),
                  );
                }
              },
            ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Staff Member'),
        content: Text('Are you sure you want to delete ${user.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              onDelete();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppDesign.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
