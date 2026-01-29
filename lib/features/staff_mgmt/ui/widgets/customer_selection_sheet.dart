import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hotel_manager/core/models/models.dart';
import 'package:hotel_manager/features/staff_mgmt/logic/customer_cubit.dart';
import 'package:hotel_manager/features/staff_mgmt/ui/widgets/add_customer_dialog.dart';
import 'package:hotel_manager/theme/app_design.dart';
import 'package:hotel_manager/component/inputs/app_text_field.dart';
import 'package:hotel_manager/component/buttons/premium_button.dart';

class CustomerSelectionSheet extends StatefulWidget {
  final Function(Customer?) onSelected;
  final Customer? initialCustomer;

  const CustomerSelectionSheet({
    super.key,
    required this.onSelected,
    this.initialCustomer,
  });

  static Future<void> show(
    BuildContext context, {
    required Function(Customer?) onSelected,
    Customer? initialCustomer,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CustomerSelectionSheet(
        onSelected: onSelected,
        initialCustomer: initialCustomer,
      ),
    );
  }

  @override
  State<CustomerSelectionSheet> createState() => _CustomerSelectionSheetState();
}

class _CustomerSelectionSheetState extends State<CustomerSelectionSheet> {
  String _searchQuery = '';

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            _buildHandle(),
            _buildHeader(),
            const Divider(height: 1),
            Expanded(child: _buildCustomerList(scrollController)),
          ],
        ),
      ),
    );
  }

  Widget _buildHandle() {
    return Center(
      child: Container(
        margin: const EdgeInsets.only(top: 12),
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: AppDesign.neutral300,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Select Customer',
            style: AppDesign.headlineSmall.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          PremiumButton.primary(
            label: 'Add New',
            onPressed: () => _showAddCustomerDialog(context),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerList(ScrollController scrollController) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: AppTextField(
            hintText: 'Search by name or phone...',
            prefixIcon: Icons.search,
            onChanged: (val) => setState(() => _searchQuery = val ?? ''),
          ),
        ),
        Expanded(
          child: BlocBuilder<CustomerCubit, CustomerState>(
            builder: (context, state) {
              if (state is CustomerLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state is CustomerError) {
                return Center(child: Text(state.message));
              }
              if (state is CustomerLoaded) {
                final filtered = state.customers.where((c) {
                  return c.name.toLowerCase().contains(
                        _searchQuery.toLowerCase(),
                      ) ||
                      c.phone.contains(_searchQuery);
                }).toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('No customers found', style: AppDesign.bodyLarge),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () => _showAddCustomerDialog(context),
                          child: const Text('Add new customer?'),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 8,
                  ),
                  itemCount: filtered.length + 1, // +1 for "No customer" option
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return _buildNoCustomerOption();
                    }
                    final customer = filtered[index - 1];
                    final isSelected =
                        widget.initialCustomer?.id == customer.id;

                    return InkWell(
                      onTap: () {
                        widget.onSelected(customer);
                        Navigator.pop(context);
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppDesign.primaryStart.withOpacity(0.05)
                              : AppDesign.neutral50,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected
                                ? AppDesign.primaryStart
                                : Colors.transparent,
                          ),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: AppDesign.primaryStart
                                  .withOpacity(0.1),
                              child: Text(
                                customer.name[0].toUpperCase(),
                                style: const TextStyle(
                                  color: AppDesign.primaryStart,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    customer.name,
                                    style: AppDesign.titleSmall.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    customer.phone,
                                    style: AppDesign.bodySmall.copyWith(
                                      color: AppDesign.neutral500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (customer.loyaltyInfo != null)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.amber.shade100,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '${customer.loyaltyInfo?.availablePoints} pts',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.amber.shade800,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildNoCustomerOption() {
    return InkWell(
      onTap: () {
        widget.onSelected(null);
        Navigator.pop(context);
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: widget.initialCustomer == null
              ? AppDesign.primaryStart.withOpacity(0.05)
              : AppDesign.neutral50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: widget.initialCustomer == null
                ? AppDesign.primaryStart
                : Colors.transparent,
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: AppDesign.neutral200,
              child: Icon(
                Icons.person_off,
                size: 20,
                color: AppDesign.neutral600,
              ),
            ),
            const SizedBox(width: 16),
            Text(
              'Walk-in (No customer)',
              style: AppDesign.titleSmall.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddCustomerDialog(BuildContext context) async {
    final newCustomer = await showDialog<Customer>(
      context: context,
      builder: (_) => BlocProvider.value(
        value: context.read<CustomerCubit>(),
        child: const AddCustomerDialog(),
      ),
    );

    if (newCustomer != null && mounted) {
      widget.onSelected(newCustomer);
      Navigator.pop(context);
    }
  }
}
