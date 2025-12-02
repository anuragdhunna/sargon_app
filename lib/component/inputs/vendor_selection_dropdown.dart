import '../../features/inventory/inventory_index.dart';

/// Premium vendor selection dropdown
///
/// Features:
/// - Search vendors
/// - Show vendor details
/// - Preferred vendor indicator
/// - Category badges
class VendorSelectionDropdown extends StatefulWidget {
  final String? selectedVendorId;
  final ValueChanged<Vendor?> onVendorSelected;
  final VendorCategory? filterCategory;
  final bool showPreferredOnly;
  final String? label;

  const VendorSelectionDropdown({
    super.key,
    this.selectedVendorId,
    required this.onVendorSelected,
    this.filterCategory,
    this.showPreferredOnly = false,
    this.label,
  });

  @override
  State<VendorSelectionDropdown> createState() =>
      _VendorSelectionDropdownState();
}

class _VendorSelectionDropdownState extends State<VendorSelectionDropdown> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VendorCubit, VendorState>(
      builder: (context, state) {
        if (state is! VendorLoaded) {
          return const CircularProgressIndicator();
        }

        var vendors = state.vendors;

        // Apply filters
        if (widget.filterCategory != null) {
          vendors = vendors
              .where((v) => v.category == widget.filterCategory)
              .toList();
        }

        if (widget.showPreferredOnly) {
          vendors = vendors.where((v) => v.isPreferred).toList();
        }

        // Apply search
        if (_searchQuery.isNotEmpty) {
          final lowerQuery = _searchQuery.toLowerCase();
          vendors = vendors.where((v) {
            return v.name.toLowerCase().contains(lowerQuery) ||
                v.contactPerson.toLowerCase().contains(lowerQuery);
          }).toList();
        }

        final selectedVendor = widget.selectedVendorId != null
            ? context.read<VendorCubit>().getVendorById(
                widget.selectedVendorId!,
              )
            : null;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.label != null) ...[
              Text(
                widget.label!,
                style: AppDesign.labelMedium.copyWith(
                  color: AppDesign.neutral700,
                ),
              ),
              const SizedBox(height: AppDesign.space2),
            ],
            InkWell(
              onTap: () => _showVendorPicker(context, vendors),
              borderRadius: BorderRadius.circular(AppDesign.radiusMd),
              child: Container(
                padding: const EdgeInsets.all(AppDesign.space4),
                decoration: BoxDecoration(
                  border: Border.all(color: AppDesign.neutral300),
                  borderRadius: BorderRadius.circular(AppDesign.radiusMd),
                ),
                child: Row(
                  children: [
                    Icon(Icons.business, color: AppDesign.neutral500, size: 20),
                    const SizedBox(width: AppDesign.space3),
                    Expanded(
                      child: selectedVendor != null
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      selectedVendor.name,
                                      style: AppDesign.bodyMedium.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    if (selectedVendor.isPreferred) ...[
                                      const SizedBox(width: AppDesign.space2),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: AppDesign.space2,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppDesign.success.withOpacity(
                                            0.1,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            AppDesign.radiusSm,
                                          ),
                                        ),
                                        child: Text(
                                          'Preferred',
                                          style: AppDesign.labelSmall.copyWith(
                                            color: AppDesign.success,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${selectedVendor.contactPerson} • ${selectedVendor.phoneNumber}',
                                  style: AppDesign.bodySmall.copyWith(
                                    color: AppDesign.neutral500,
                                  ),
                                ),
                              ],
                            )
                          : Text(
                              'Select Vendor',
                              style: AppDesign.bodyMedium.copyWith(
                                color: AppDesign.neutral400,
                              ),
                            ),
                    ),
                    Icon(Icons.arrow_drop_down, color: AppDesign.neutral500),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showVendorPicker(BuildContext context, List<Vendor> vendors) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return StatefulBuilder(
            builder: (context, setState) {
              var filteredVendors = vendors;
              if (_searchQuery.isNotEmpty) {
                final lowerQuery = _searchQuery.toLowerCase();
                filteredVendors = vendors.where((v) {
                  return v.name.toLowerCase().contains(lowerQuery) ||
                      v.contactPerson.toLowerCase().contains(lowerQuery);
                }).toList();
              }

              return Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppDesign.space4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(AppDesign.radiusLg),
                        topRight: Radius.circular(AppDesign.radiusLg),
                      ),
                      boxShadow: AppDesign.shadowSm,
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: AppDesign.neutral300,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(height: AppDesign.space4),
                        Text('Select Vendor', style: AppDesign.titleLarge),
                        const SizedBox(height: AppDesign.space4),
                        TextField(
                          onChanged: (value) {
                            setState(() {
                              _searchQuery = value;
                            });
                          },
                          decoration: InputDecoration(
                            hintText: 'Search vendors...',
                            prefixIcon: const Icon(Icons.search),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                AppDesign.radiusFull,
                              ),
                            ),
                            isDense: true,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.separated(
                      controller: scrollController,
                      padding: const EdgeInsets.all(AppDesign.space4),
                      itemCount: filteredVendors.length,
                      separatorBuilder: (context, index) => const Divider(),
                      itemBuilder: (context, index) {
                        final vendor = filteredVendors[index];
                        final isSelected = vendor.id == widget.selectedVendorId;

                        return ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(AppDesign.space2),
                            decoration: BoxDecoration(
                              color: AppDesign.primaryStart.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(
                                AppDesign.radiusMd,
                              ),
                            ),
                            child: Icon(
                              Icons.business,
                              color: AppDesign.primaryStart,
                              size: 24,
                            ),
                          ),
                          title: Row(
                            children: [
                              Text(
                                vendor.name,
                                style: AppDesign.bodyMedium.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              if (vendor.isPreferred) ...[
                                const SizedBox(width: AppDesign.space2),
                                Icon(
                                  Icons.star,
                                  size: 16,
                                  color: AppDesign.warning,
                                ),
                              ],
                            ],
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${vendor.contactPerson} • ${vendor.phoneNumber}',
                                style: AppDesign.bodySmall,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                vendor.category.displayName,
                                style: AppDesign.labelSmall.copyWith(
                                  color: AppDesign.neutral500,
                                ),
                              ),
                            ],
                          ),
                          trailing: isSelected
                              ? Icon(
                                  Icons.check_circle,
                                  color: AppDesign.success,
                                )
                              : null,
                          selected: isSelected,
                          onTap: () {
                            widget.onVendorSelected(vendor);
                            Navigator.pop(context);
                          },
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
