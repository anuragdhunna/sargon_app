import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hotel_manager/component/cards/app_card.dart';
import 'package:hotel_manager/component/states/empty_state.dart';
import 'package:hotel_manager/features/staff_mgmt/logic/owner_cubit.dart';
import 'package:hotel_manager/features/staff_mgmt/ui/create_owner_screen.dart';
import 'package:hotel_manager/features/staff_mgmt/ui/edit_owner_screen.dart';
import 'package:hotel_manager/core/models/models.dart';
import 'package:hotel_manager/theme/app_design.dart';

/// Owner Management Screen (Super Admin only)
///
/// Lists all hotel owners across the platform.
class OwnerManagementScreen extends StatefulWidget {
  const OwnerManagementScreen({super.key});

  static const String routeName = '/owners';

  @override
  State<OwnerManagementScreen> createState() => _OwnerManagementScreenState();
}

class _OwnerManagementScreenState extends State<OwnerManagementScreen> {
  @override
  void initState() {
    super.initState();
    context.read<OwnerCubit>().loadAllOwners();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppDesign.neutral50,
      appBar: AppBar(
        title: const Text('Hotel Owners'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: BlocBuilder<OwnerCubit, OwnerState>(
        builder: (context, state) {
          if (state is OwnerLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is OwnerLoaded) {
            if (state.owners.isEmpty) {
              return const EmptyState(
                icon: Icons.business_outlined,
                title: 'No Hotel Owners',
                message: 'No owners have registered on the platform yet.',
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: state.owners.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final owner = state.owners[index];
                return _OwnerCard(owner: owner);
              },
            );
          } else if (state is OwnerError) {
            return Center(child: Text('Error: ${state.message}'));
          }
          return const Center(child: Text('Initializing...'));
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.push(CreateOwnerScreen.routeName).then((_) {
            // Reload owners when returning
            if (context.mounted) {
              context.read<OwnerCubit>().loadAllOwners();
            }
          });
        },
        backgroundColor: AppDesign.primaryStart,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Owner', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}

class _OwnerCard extends StatelessWidget {
  final User owner;

  const _OwnerCard({required this.owner});

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
              owner.name.isNotEmpty ? owner.name[0].toUpperCase() : '?',
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
                  owner.name,
                  style: AppDesign.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.email, size: 14, color: AppDesign.neutral600),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        owner.email ?? 'No email',
                        style: AppDesign.bodySmall.copyWith(
                          color: AppDesign.neutral600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                Text(
                  'Hotels: ${owner.hotelIds.length}',
                  style: AppDesign.bodySmall.copyWith(
                    color: AppDesign.neutral600,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.edit, color: AppDesign.primaryStart),
            onPressed: () {
              context.push(EditOwnerScreen.routeName, extra: owner).then((_) {
                if (context.mounted) {
                  context.read<OwnerCubit>().loadAllOwners();
                }
              });
            },
          ),
          Switch(
            value: owner.status == UserStatus.active,
            activeThumbColor: AppDesign.success,
            onChanged: (val) {
              context.read<OwnerCubit>().updateOwnerStatus(owner.id, val);
            },
          ),
        ],
      ),
    );
  }
}
