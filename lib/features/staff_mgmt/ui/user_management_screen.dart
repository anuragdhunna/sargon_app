import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hotel_manager/component/buttons/icon_button_with_label.dart';
import 'package:hotel_manager/component/cards/app_card.dart';
import 'package:hotel_manager/component/states/empty_state.dart';
import 'package:hotel_manager/features/staff_mgmt/data/user_model.dart';
import 'package:hotel_manager/features/staff_mgmt/logic/user_cubit.dart';
import 'package:hotel_manager/features/staff_mgmt/ui/add_user_dialog.dart';
import 'package:hotel_manager/theme/app_design.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  static const String routeName = '/users';

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  UserRole? _selectedRole;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppDesign.neutral50,
      appBar: AppBar(
        title: const Text('Staff Directory'),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButtonWithLabel(
            icon: Icons.add,
            label: 'Add',
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => const AddUserDialog(),
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
                      return AppCard(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDesign.space3,
                          vertical: AppDesign.space3,
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: AppDesign.primaryStart
                                  .withOpacity(0.1),
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
                                      Icon(
                                        Icons.work,
                                        size: 14,
                                        color: AppDesign.neutral600,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        user.role.name.toUpperCase(),
                                        style: AppDesign.bodySmall.copyWith(
                                          color: AppDesign.neutral600,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Icon(
                                        Icons.phone,
                                        size: 14,
                                        color: AppDesign.neutral600,
                                      ),
                                      const SizedBox(width: 4),
                                      Flexible(
                                        child: Text(
                                          user.phoneNumber,
                                          style: AppDesign.bodySmall.copyWith(
                                            color: AppDesign.neutral600,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            PopupMenuButton(
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: 'edit',
                                  child: Text('Edit'),
                                ),
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
                                  context.read<UserCubit>().deleteUser(user.id);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('User Deleted'),
                                    ),
                                  );
                                } else if (val == 'edit') {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Edit Feature Coming Soon'),
                                    ),
                                  );
                                }
                              },
                            ),
                          ],
                        ),
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
