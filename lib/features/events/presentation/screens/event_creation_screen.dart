import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hotel_manager/core/utils/build_context_ext.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../theme/app_design.dart';
import '../../../../component/buttons/premium_button.dart';
import '../../../../component/inputs/app_text_field.dart';
import '../../../../component/inputs/app_phone_field.dart';
import '../../../../core/models/models.dart';
import '../../../../component/cards/app_card.dart';
import '../../../../component/inputs/app_dropdown.dart';
import '../../logic/event_cubit.dart';
import '../widgets/event_form_widgets.dart';

part 'event_creation_screen_methods.dart';

class EventCreationScreen extends StatefulWidget {
  final PrivateEvent? event;
  const EventCreationScreen({super.key, this.event});

  @override
  State<EventCreationScreen> createState() => _EventCreationScreenState();
}

class _EventCreationScreenState extends State<EventCreationScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _nameController = TextEditingController();
  final _guestNameController = TextEditingController();
  final _guestPhoneController = TextEditingController();
  final _paxController = TextEditingController(text: '0');
  final _basePriceController = TextEditingController(text: '0');
  final _perPaxRateController = TextEditingController(text: '0');

  // State
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _startTime = const TimeOfDay(hour: 10, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 14, minute: 0);
  final List<String> _selectedHallIds = [];
  final List<String> _selectedMenuItemIds = [];
  PricingCategory _pricingCategory = PricingCategory.package;
  String? _selectedTaxRuleId;
  List<PrivateEvent> _conflicts = [];
  List<EventFeatureSelection> _featureSelections = [];

  @override
  void initState() {
    super.initState();
    final cubit = context.read<EventCubit>();
    cubit.fetchHalls();
    cubit
        .streamMenuItems(); // Still useful to have real-time for menu, but can be fetch if preferred.
    cubit.streamVendors();
    cubit.fetchEventTaxRules();

    if (widget.event != null) {
      _nameController.text = widget.event!.name;
      _guestNameController.text = widget.event!.guestName;
      _guestPhoneController.text = widget.event!.guestPhone;
      _paxController.text = widget.event!.expectedPax.toString();
      _basePriceController.text = widget.event!.pricing.basePrice.toString();
      _perPaxRateController.text = widget.event!.pricing.perPaxRate.toString();
      _selectedDate = widget.event!.date;
      _pricingCategory = widget.event!.pricing.category;
      _selectedTaxRuleId = widget.event!.pricing.taxRuleId;
      _selectedHallIds.addAll(widget.event!.hallIds);
      _selectedMenuItemIds.addAll(widget.event!.menuItemIds);

      final startTimeParts = widget.event!.startTime.split(':');
      _startTime = TimeOfDay(
        hour: int.parse(startTimeParts[0]),
        minute: int.parse(startTimeParts[1]),
      );
      final endTimeParts = widget.event!.endTime.split(':');
      _endTime = TimeOfDay(
        hour: int.parse(endTimeParts[0]),
        minute: int.parse(endTimeParts[1]),
      );
      _featureSelections = List.from(widget.event!.featureSelections);

      // Initial check for conflicts if editing
      WidgetsBinding.instance.addPostFrameCallback((_) => _checkAvailability());
    }
  }

  void _checkAvailability() {
    final cubit = context.read<EventCubit>();
    final conflicts = cubit.getConflictsForDate(
      date: _selectedDate,
      startTime: _formatTime(_startTime),
      endTime: _formatTime(_endTime),
      hallIds: _selectedHallIds,
      excludeEventId: widget.event?.id,
    );
    setState(() => _conflicts = conflicts);
  }

  String _formatTime(TimeOfDay time) {
    return '${time.hour}:${time.minute.toString().padLeft(2, "0")}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppDesign.neutral50,
      appBar: AppBar(title: const Text('Schedule New Event')),
      body: BlocConsumer<EventCubit, EventState>(
        listener: (context, state) {
          if (state.status == EventStatusType.error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message ?? 'Unknown error')),
            );
          }
        },
        builder: (context, state) {
          return Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_conflicts.isNotEmpty) _buildConflictWarning(),
                  _buildSectionTitle('Event Details'),
                  AppTextField(
                    controller: _nameController,
                    label: 'Event Name',
                    hint: 'e.g., Annual Gala',
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: AppTextField(
                          controller: _guestNameController,
                          label: 'Contact Person',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AppPhoneField(
                          controller: _guestPhoneController,
                          label: 'Phone',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildSectionTitle('Scheduling'),
                  _buildDatePicker(),
                  const SizedBox(height: 16),
                  _buildTimePickers(),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Hall Selection'),
                  HallSelector(
                    halls: state.halls,
                    selectedHallIds: _selectedHallIds,
                    onSelectionChanged: (id, selected) {
                      setState(() {
                        if (selected) {
                          _selectedHallIds.add(id);
                        } else {
                          _selectedHallIds.remove(id);
                        }
                      });
                      _checkAvailability();
                    },
                  ),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Menu Selection'),
                  MenuSelector(
                    items: state.menuItems,
                    selectedMenuItemIds: _selectedMenuItemIds,
                    onSelectionChanged: (id, selected) {
                      setState(() {
                        if (selected) {
                          _selectedMenuItemIds.add(id);
                        } else {
                          _selectedMenuItemIds.remove(id);
                        }
                      });
                    },
                  ),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Pricing & Guests'),
                  Row(
                    children: [
                      Expanded(
                        child: AppTextField(
                          controller: _paxController,
                          label: 'Expected Pax',
                          keyboardType: TextInputType.number,
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AppDropdown<PricingCategory>(
                          label: 'Pricing Model',
                          initialValue: _pricingCategory,
                          items: PricingCategory.values
                              .map(
                                (c) => DropdownMenuItem(
                                  value: c,
                                  child: Text(c.name),
                                ),
                              )
                              .toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() => _pricingCategory = val);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  BlocBuilder<EventCubit, EventState>(
                    builder: (context, state) {
                      final taxRules = state.eventTaxRules;

                      if (taxRules.isEmpty) {
                        return Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppDesign.neutral100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'No tax rules configured. Please add one in Settings > Taxes.',
                            style: AppDesign.bodySmall.copyWith(
                              color: AppDesign.neutral600,
                            ),
                          ),
                        );
                      }

                      return AppDropdown<String>(
                        label: 'Initial Tax Rule',
                        initialValue: _selectedTaxRuleId,
                        items: taxRules
                            .map(
                              (r) => DropdownMenuItem(
                                value: r.id,
                                child: Text(r.name),
                              ),
                            )
                            .toList(),
                        onChanged: (val) =>
                            setState(() => _selectedTaxRuleId = val),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  if (_pricingCategory == PricingCategory.package ||
                      _pricingCategory == PricingCategory.hybrid)
                    AppTextField(
                      controller: _basePriceController,
                      label: 'Base Package Price',
                      keyboardType: TextInputType.number,
                      onChanged: (_) => setState(() {}),
                    ),
                  if (_pricingCategory == PricingCategory.perPax ||
                      _pricingCategory == PricingCategory.hybrid) ...[
                    const SizedBox(height: 16),
                    AppTextField(
                      controller: _perPaxRateController,
                      label: 'Rate Per Pax',
                      keyboardType: TextInputType.number,
                      onChanged: (_) => setState(() {}),
                    ),
                  ],
                  const SizedBox(height: 24),
                  _buildSectionTitle('Additional Services'),
                  _buildDynamicFeaturesSection(state),
                  const SizedBox(height: 24),
                  QuoteEstimator(
                    pax: int.tryParse(_paxController.text) ?? 0,
                    basePrice:
                        double.tryParse(_basePriceController.text) ?? 0.0,
                    perPaxRate:
                        double.tryParse(_perPaxRateController.text) ?? 0.0,
                    category: _pricingCategory,
                  ),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      Expanded(
                        child: PremiumButton.secondary(
                          label: 'Save as Draft',
                          onPressed: () =>
                              _validateAndSubmit(state.halls, isDraft: true),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: PremiumButton.primary(
                          label: widget.event == null
                              ? 'Create Event'
                              : 'Update Event',
                          onPressed: () =>
                              _validateAndSubmit(state.halls, isDraft: false),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 48),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDynamicFeaturesSection(EventState state) {
    // 1. Get all features available in selected halls
    final availableFeatureIds = state.halls
        .where((h) => _selectedHallIds.contains(h.id))
        .expand((h) => h.featureIds)
        .toSet();

    if (availableFeatureIds.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Text('No additional features available for selected halls.'),
      );
    }

    final features = state.hallFeatures
        .where((f) => availableFeatureIds.contains(f.id))
        .toList();

    return AppCard(
      child: Column(
        children: features.map((feature) {
          final selectionIndex = _featureSelections.indexWhere(
            (s) => s.featureId == feature.id,
          );
          final isSelected =
              selectionIndex != -1 &&
              _featureSelections[selectionIndex].isSelected;
          final arrangement = selectionIndex != -1
              ? _featureSelections[selectionIndex].arrangement ?? 'customer'
              : 'customer';

          return Column(
            children: [
              if (features.indexOf(feature) != 0) const Divider(height: 32),
              SwitchListTile(
                value: isSelected,
                onChanged: (val) {
                  setState(() {
                    if (selectionIndex != -1) {
                      _featureSelections[selectionIndex] =
                          _featureSelections[selectionIndex].copyWith(
                            isSelected: val,
                          );
                    } else {
                      _featureSelections.add(
                        EventFeatureSelection(
                          featureId: feature.id,
                          isSelected: val,
                          arrangement: 'customer',
                        ),
                      );
                    }
                  });
                },
                title: Text(feature.name, style: AppDesign.bodyLarge),
                subtitle: Text(
                  feature.description ??
                      (isSelected ? 'Requested' : 'Not Required'),
                  style: AppDesign.bodySmall,
                ),
                activeThumbColor: AppDesign.primaryStart,
                contentPadding: EdgeInsets.zero,
              ),
              if (isSelected) ...[
                const SizedBox(height: 8),
                AppDropdown<String>(
                  label: 'Arranged By',
                  initialValue: arrangement,
                  items: const [
                    DropdownMenuItem(
                      value: 'customer',
                      child: Text('Customer'),
                    ),
                    DropdownMenuItem(
                      value: 'management',
                      child: Text('Management'),
                    ),
                  ],
                  onChanged: (val) {
                    setState(() {
                      if (selectionIndex != -1) {
                        _featureSelections[selectionIndex] =
                            _featureSelections[selectionIndex].copyWith(
                              arrangement: val,
                            );
                      }
                    });
                  },
                ),
              ],
            ],
          );
        }).toList(),
      ),
    );
  }

  void _validateAndSubmit(List<Hall> halls, {required bool isDraft}) async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedHallIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one hall.')),
      );
      return;
    }

    final pax = int.tryParse(_paxController.text) ?? 0;
    final totalCapacity = halls
        .where((h) => _selectedHallIds.contains(h.id))
        .fold(0, (sum, h) => sum + h.capacity);

    final event = PrivateEvent(
      hotelId: context.hotelId,
      id:
          widget.event?.id ??
          context.read<EventCubit>().repository.nextId(
            'events',
            hotelId: context.hotelId,
          ),
      name: _nameController.text,
      guestName: _guestNameController.text,
      guestPhone: _guestPhoneController.text,
      date: _selectedDate,
      startTime: _formatTime(_startTime),
      endTime: _formatTime(_endTime),
      hallIds: _selectedHallIds,
      menuItemIds: _selectedMenuItemIds,
      expectedPax: pax,
      status: isDraft ? EventStatus.draft : EventStatus.confirmed,
      pricing: EventPricing(
        category: _pricingCategory,
        taxRuleId: _selectedTaxRuleId,
        basePrice: double.tryParse(_basePriceController.text) ?? 0.0,
        perPaxRate: double.tryParse(_perPaxRateController.text) ?? 0.0,
        addOns: widget.event?.pricing.addOns ?? const [],
        manualPrice: widget.event?.pricing.manualPrice,
      ),
      createdOn: widget.event?.createdOn ?? DateTime.now(),
      createdBy: widget.event?.createdBy,
      advancePayment: widget.event?.advancePayment ?? 0.0,
      notes: widget.event?.notes,
      featureSelections: _featureSelections,
    );

    // Conflict Check (Only if not a draft)
    if (!isDraft && _conflicts.isNotEmpty) {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Scheduling Conflict'),
          content: Text(
            'The following halls are already booked: ${_conflicts.map((c) => c.name).join(", ")}. Do you still want to proceed?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Proceed'),
            ),
          ],
        ),
      );
      if (confirm != true) return;
    }

    // Capacity Check
    if (pax > totalCapacity) {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Capacity Warning'),
          content: Text(
            'The expected guest count ($pax) exceeds the total capacity of selected halls ($totalCapacity). Do you still want to proceed?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Proceed'),
            ),
          ],
        ),
      );
      if (confirm != true) return;
    }

    if (!context.mounted) return;
    context.read<EventCubit>().saveEvent(event);
    if (!context.mounted) return;
    context.pop();
  }
}
