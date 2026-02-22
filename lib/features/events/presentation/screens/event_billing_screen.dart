import 'package:flutter/material.dart';
import 'package:hotel_manager/core/utils/build_context_ext.dart';
import '../../../../theme/app_design.dart';
import '../../../../component/buttons/premium_button.dart';
import '../../../../component/cards/app_card.dart';
import '../../../../core/models/event_models.dart';
import '../../../../core/models/billing_models.dart';
import '../../logic/event_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EventBillingScreen extends StatefulWidget {
  final PrivateEvent event;

  const EventBillingScreen({super.key, required this.event});

  @override
  State<EventBillingScreen> createState() => _EventBillingScreenState();
}

class _EventBillingScreenState extends State<EventBillingScreen> {
  TaxRule? _selectedTaxRule;
  double _serviceChargePercent = 0.0;
  double _advancePaid = 0.0;

  @override
  void initState() {
    super.initState();
    _advancePaid = widget.event.advancePayment;
    final cubit = context.read<EventCubit>();
    cubit.streamEventTaxRules();
    cubit.streamEventPOs(widget.event.id);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EventCubit, EventState>(
      builder: (context, state) {
        final subtotal = _calculateSubtotal(widget.event, state.eventPOs);

        final taxRules = state.eventTaxRules.isNotEmpty
            ? state.eventTaxRules
            : _defaultTaxRules;

        if (_selectedTaxRule == null && taxRules.isNotEmpty) {
          _selectedTaxRule = taxRules.first;
        }

        final serviceCharge = subtotal * (_serviceChargePercent / 100);
        final taxableAmount = subtotal + serviceCharge;
        final taxAmount =
            taxableAmount * ((_selectedTaxRule?.getEffectiveTax() ?? 0) / 100);
        final grandTotal = taxableAmount + taxAmount;
        final balanceDue = grandTotal - _advancePaid;

        return Scaffold(
          backgroundColor: AppDesign.neutral50,
          appBar: AppBar(title: const Text('Event Billing')),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildBillSummaryCard(
                  subtotal,
                  serviceCharge,
                  taxAmount,
                  grandTotal,
                ),
                const SizedBox(height: 24),
                _buildBillingSettingsCard(taxRules),
                const SizedBox(height: 24),
                _buildPaymentCard(balanceDue),
                const SizedBox(height: 32),
                PremiumButton.primary(
                  label: 'Finalize & Generate Receipt',
                  isFullWidth: true,
                  onPressed: () => _finalizeBilling(context, grandTotal),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  List<TaxRule> get _defaultTaxRules => [
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

  Widget _buildBillSummaryCard(
    double subtotal,
    double serviceCharge,
    double taxAmount,
    double grandTotal,
  ) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bill Summary',
            style: AppDesign.titleMedium.copyWith(fontWeight: FontWeight.bold),
          ),
          const Divider(height: 24),
          _buildBillRow('Subtotal', subtotal),
          _buildBillRow(
            'Service Charge ($_serviceChargePercent%)',
            serviceCharge,
          ),
          _buildBillRow(
            'Taxes (${_selectedTaxRule?.name ?? "None"})',
            taxAmount,
          ),
          const Divider(height: 24, thickness: 2),
          _buildBillRow(
            'Grand Total',
            grandTotal,
            isBold: true,
            color: AppDesign.primaryStart,
          ),
        ],
      ),
    );
  }

  Widget _buildBillRow(
    String label,
    double amount, {
    bool isBold = false,
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppDesign.bodyMedium.copyWith(
              fontWeight: isBold ? FontWeight.bold : null,
            ),
          ),
          Text(
            '₹ ${amount.toStringAsFixed(2)}',
            style: AppDesign.bodyLarge.copyWith(
              fontWeight: isBold ? FontWeight.bold : null,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBillingSettingsCard(List<TaxRule> taxRules) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Billing Options',
            style: AppDesign.titleMedium.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<TaxRule>(
            initialValue: _selectedTaxRule,
            decoration: const InputDecoration(labelText: 'Tax Rule'),
            items: taxRules
                .map((r) => DropdownMenuItem(value: r, child: Text(r.name)))
                .toList(),
            onChanged: (val) => setState(() => _selectedTaxRule = val),
          ),
          const SizedBox(height: 16),
          TextField(
            decoration: const InputDecoration(
              labelText: 'Service Charge (%)',
              hintText: '0.0',
            ),
            keyboardType: TextInputType.number,
            onChanged: (val) => setState(
              () => _serviceChargePercent = double.tryParse(val) ?? 0.0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentCard(double balanceDue) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Payments & Settlement',
            style: AppDesign.titleMedium.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          TextField(
            decoration: const InputDecoration(
              labelText: 'Advance/Paid Amount',
              prefixText: '₹ ',
            ),
            keyboardType: TextInputType.number,
            onChanged: (val) =>
                setState(() => _advancePaid = double.tryParse(val) ?? 0.0),
          ),
          const Divider(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Balance Due',
                style: AppDesign.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '₹ ${balanceDue.toStringAsFixed(2)}',
                style: AppDesign.titleLarge.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  double _calculateSubtotal(PrivateEvent event, List<EventPO> pos) {
    double total = event.pricing.basePrice;
    for (var addon in event.pricing.addOns) {
      total += addon.price;
    }

    // Include PO costs passed to customer
    for (var po in pos) {
      if (po.isPassedToCustomer) {
        total += po.cost;
      }
    }

    return total;
  }

  void _finalizeBilling(BuildContext context, double totalAmount) async {
    // 1. Update advance payment if changed
    if (_advancePaid != widget.event.advancePayment) {
      await context.read<EventCubit>().saveEventAdvancePayment(
        widget.event.id,
        _advancePaid,
      );
    }

    // 2. Update status to billed
    if (!context.mounted) return;
    await context.read<EventCubit>().updateStatus(
      widget.event.id,
      EventStatus.billed,
    );

    // 3. Navigate back
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bill generated and event finalized.')),
      );
      Navigator.pop(context);
    }
  }
}
