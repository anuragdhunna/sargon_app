import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hotel_manager/features/staff_mgmt/data/user_model.dart';
import 'package:hotel_manager/features/staff_mgmt/logic/user_cubit.dart';
import 'package:hotel_manager/features/staff_mgmt/ui/add_user_dialog.dart';

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
      appBar: AppBar(
        title: const Text('Staff Directory'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => const AddUserDialog(),
              );
            },
          ),
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
                    return const Center(child: Text('No staff found.'));
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: state.users.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final user = state.users[index];
                      return Card(
                        elevation: 0,
                        color: Colors.grey.shade50,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: Colors.grey.shade200),
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.blue.shade100,
                            child: Text(
                              user.name[0],
                              style: TextStyle(color: Colors.blue.shade800),
                            ),
                          ),
                          title: Text(
                            user.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    Icons.work,
                                    size: 14,
                                    color: Colors.grey.shade600,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    user.role.name.toUpperCase(),
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  const SizedBox(width: 12),
                                  Icon(
                                    Icons.phone,
                                    size: 14,
                                    color: Colors.grey.shade600,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    user.phoneNumber,
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          trailing: PopupMenuButton(
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'edit',
                                child: Text('Edit'),
                              ),
                              const PopupMenuItem(
                                value: 'delete',
                                child: Text(
                                  'Delete',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                            onSelected: (val) {
                              if (val == 'delete') {
                                context.read<UserCubit>().deleteUser(user.id);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('User Deleted')),
                                );
                              } else if (val == 'edit') {
                                // TODO: Show Edit Dialog
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Edit Feature Coming Soon'),
                                  ),
                                );
                              }
                            },
                          ),
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
