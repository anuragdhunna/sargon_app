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
import '../../logic/event_cubit.dart';

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
                  _buildHallSelector(state.halls),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Menu Selection'),
                  _buildMenuSelector(state.menuItems),
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
                        child: DropdownButtonFormField<PricingCategory>(
                          initialValue: _pricingCategory,
                          decoration: const InputDecoration(
                            labelText: 'Pricing Model',
                          ),
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
                      final taxRules = state.eventTaxRules.isNotEmpty
                          ? state.eventTaxRules
                          : [
                              TaxRule(
                                id: 'gst5',
                                hotelId: context.hotelId,
                                name: 'GST 5%',
                                cgstPercent: 2.5,
                                sgstPercent: 2.5,
                              ),
                              TaxRule(
                                id: 'gst18',
                                hotelId: context.hotelId,
                                name: 'GST 18%',
                                cgstPercent: 9,
                                sgstPercent: 9,
                              ),
                            ];

                      return DropdownButtonFormField<String>(
                        initialValue: _selectedTaxRuleId,
                        decoration: const InputDecoration(
                          labelText: 'Initial Tax Rule',
                        ),
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
                  _buildQuoteEstimator(),
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

  Widget _buildMenuSelector(List<MenuItem> items) {
    if (items.isEmpty) return const Text('No menu items available.');
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: items.map((item) {
        final isSelected = _selectedMenuItemIds.contains(item.id);
        return FilterChip(
          label: Text(item.name),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              if (selected) {
                _selectedMenuItemIds.add(item.id);
              } else {
                _selectedMenuItemIds.remove(item.id);
              }
            });
          },
          selectedColor: Colors.orange.withValues(alpha: 0.2),
          checkmarkColor: Colors.orange,
        );
      }).toList(),
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

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: AppDesign.titleMedium.copyWith(
          fontWeight: FontWeight.bold,
          color: AppDesign.primaryStart,
        ),
      ),
    );
  }

  Widget _buildDatePicker() {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: _selectedDate,
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        if (picked != null && mounted) {
          setState(() => _selectedDate = picked);
          _checkAvailability();
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppDesign.neutral200),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, color: AppDesign.primaryStart),
            const SizedBox(width: 12),
            Text(
              DateFormat('EEEE, MMM dd, yyyy').format(_selectedDate),
              style: AppDesign.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimePickers() {
    return Row(
      children: [
        Expanded(
          child: _buildTimeTile(
            'Start',
            _startTime,
            (t) => setState(() => _startTime = t),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildTimeTile(
            'End',
            _endTime,
            (t) => setState(() => _endTime = t),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeTile(
    String label,
    TimeOfDay time,
    Function(TimeOfDay) onSelect,
  ) {
    return InkWell(
      onTap: () async {
        final picked = await showTimePicker(
          context: context,
          initialTime: time,
        );
        if (picked != null) {
          onSelect(picked);
          _checkAvailability();
        }
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppDesign.neutral200),
        ),
        child: Column(
          children: [
            Text(label, style: AppDesign.bodySmall),
            const SizedBox(height: 4),
            Text(
              time.format(context),
              style: AppDesign.titleMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHallSelector(List<Hall> halls) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: halls.map((hall) {
        final isSelected = _selectedHallIds.contains(hall.id);
        return FilterChip(
          label: Text('${hall.name} (${hall.capacity} pax)'),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              if (selected) {
                _selectedHallIds.add(hall.id);
              } else {
                _selectedHallIds.remove(hall.id);
              }
            });
            _checkAvailability();
          },
          selectedColor: AppDesign.primaryStart.withValues(alpha: 0.2),
          checkmarkColor: AppDesign.primaryStart,
        );
      }).toList(),
    );
  }

  Widget _buildConflictWarning() {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: Colors.red),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Conflict Detected: Selected halls already booked for this time.',
              style: AppDesign.bodyMedium.copyWith(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuoteEstimator() {
    final pax = int.tryParse(_paxController.text) ?? 0;
    final basePrice = double.tryParse(_basePriceController.text) ?? 0.0;
    final perPaxRate = double.tryParse(_perPaxRateController.text) ?? 0.0;

    double subtotal = 0;
    if (_pricingCategory == PricingCategory.package) {
      subtotal = basePrice;
    } else if (_pricingCategory == PricingCategory.perPax) {
      subtotal = pax * perPaxRate;
    } else if (_pricingCategory == PricingCategory.hybrid) {
      subtotal = basePrice + (pax * perPaxRate);
    }

    return AppCard(
      color: Colors.blue.withValues(alpha: 0.05),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.calculate_outlined, color: Colors.blue),
              const SizedBox(width: 8),
              Text(
                'Live Quote Estimator',
                style: AppDesign.bodyLarge.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade900,
                ),
              ),
            ],
          ),
          const Divider(),
          if (_pricingCategory == PricingCategory.package ||
              _pricingCategory == PricingCategory.hybrid)
            _buildEstimatorRow('Base Package', basePrice),
          if (_pricingCategory == PricingCategory.perPax ||
              _pricingCategory == PricingCategory.hybrid)
            _buildEstimatorRow(
              'Guest Charge ($pax x ₹$perPaxRate)',
              pax * perPaxRate,
            ),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Estimated Subtotal',
                style: AppDesign.bodyLarge.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '₹${subtotal.toStringAsFixed(2)}',
                style: AppDesign.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '* Taxes and add-ons will be calculated during billing.',
            style: AppDesign.bodySmall.copyWith(fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }

  Widget _buildEstimatorRow(String label, double amount) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppDesign.bodyMedium),
          Text('₹${amount.toStringAsFixed(2)}', style: AppDesign.bodyMedium),
        ],
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
                DropdownButtonFormField<String>(
                  initialValue: arrangement,
                  decoration: const InputDecoration(
                    labelText: 'Arranged By',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
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
}
