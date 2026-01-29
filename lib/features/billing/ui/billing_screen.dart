import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/models/models.dart';
import '../../../theme/app_design.dart';
import '../logic/billing_cubit.dart';
import '../logic/billing_state.dart';
import '../logic/discount_calculator.dart';
import '../../../component/buttons/premium_button.dart';
import 'widgets/bill_summary_card.dart';
import 'widgets/offer_selection_sheet.dart';
import 'widgets/loyalty_redemption_sheet.dart';
import '../../staff_mgmt/ui/widgets/customer_selection_sheet.dart';

class BillingScreen extends StatefulWidget {
  final String tableId;
  final String? tableNumber;
  final List<Order> orders;

  const BillingScreen({
    super.key,
    required this.tableId,
    this.tableNumber,
    required this.orders,
  });

  static const String routeName = '/billing';

  @override
  State<BillingScreen> createState() => _BillingScreenState();
}

class _BillingScreenState extends State<BillingScreen> {
  bool _includeServiceCharge = true;
  final List<Offer> _appliedOffers = [];
  int _redeemedPoints = 0;
  Customer? _selectedCustomer;
  PaymentMethod? _selectedPaymentMethod;

  @override
  void initState() {
    super.initState();
    // Default to guest name if linked to a room booking
    if (widget.orders.isNotEmpty && widget.orders.first.guestName != null) {
      _selectedCustomer = Customer(
        id: widget.orders.first.bookingId ?? 'guest',
        name: widget.orders.first.guestName!,
        phone: 'Contact Guest', // Placeholder
        loyaltyInfo: const LoyaltyInfo(
          tierId: 'bronze',
          totalPoints: 0,
          availablePoints: 0,
        ),
      );
    }
  }

  BillTaxSummary _calculateSummary(BillingLoaded state) {
    final taxRule = state.taxRules.isNotEmpty ? state.taxRules.first : null;
    final scRule = _includeServiceCharge && state.serviceChargeRules.isNotEmpty
        ? state.serviceChargeRules.first
        : null;

    return DiscountCalculator.calculateTaxSummary(
      orders: widget.orders,
      taxRule: taxRule,
      scRule: scRule,
      manualDiscounts: _appliedOffers,
      loyaltyPointsRedeemed: _redeemedPoints,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppDesign.neutral50,
      appBar: AppBar(
        title: Text('Bill: ${widget.tableNumber ?? widget.tableId}'),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      body: BlocBuilder<BillingCubit, BillingState>(
        builder: (context, state) {
          if (state is BillingLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is BillingError) {
            return Center(child: Text(state.message));
          }
          if (state is BillingLoaded) {
            final summary = _calculateSummary(state);

            return Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      _buildOrderSummaryCard(),
                      const SizedBox(height: 20),
                      _buildOffersSection(),
                      const SizedBox(height: 20),
                      _buildCustomerSection(),
                      const SizedBox(height: 20),
                      if (_selectedCustomer != null) ...[
                        _buildLoyaltySection(),
                        const SizedBox(height: 20),
                      ],
                      _buildPaymentSection(),
                      const SizedBox(height: 20),
                      BillSummaryCard(
                        summary: summary,
                        manualDiscounts: _appliedOffers.map((o) {
                          double amount = 0;
                          if (o.discountType == DiscountType.percent) {
                            amount =
                                (summary.subTotal -
                                    summary.totalDiscountAmount +
                                    o.discountValue) *
                                (o.discountValue / 100);
                          } else {
                            amount = o.discountValue;
                          }
                          return BillDiscount(
                            id: o.id,
                            offerId: o.id,
                            name: o.name,
                            discountType: o.discountType,
                            discountValue: o.discountValue,
                            discountAmount: amount,
                            appliedBy: 'staff',
                            reason: 'Applied during billing',
                            appliedAt: DateTime.now(),
                          );
                        }).toList(),
                        showServiceCharge: _includeServiceCharge,
                        onServiceChargeChanged: (val) {
                          setState(() => _includeServiceCharge = val);
                        },
                      ),
                    ],
                  ),
                ),
                _buildBottomAction(state, summary),
              ],
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildOrderSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Order Items',
                style: AppDesign.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${widget.orders.fold(0, (sum, o) => sum + o.items.length)} items',
                style: AppDesign.bodySmall.copyWith(
                  color: AppDesign.neutral500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...widget.orders.expand((order) {
            return order.items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${item.quantity}x ${item.name}',
                            style: AppDesign.bodyLarge,
                          ),
                          if (item.discountAmount > 0)
                            Text(
                              order.appliedOfferName ?? 'Offer Applied',
                              style: AppDesign.bodySmall.copyWith(
                                color: Colors.orange.shade700,
                              ),
                            ),
                        ],
                      ),
                    ),
                    Text(
                      '₹${item.totalPrice.toStringAsFixed(2)}',
                      style: AppDesign.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildOffersSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Offers & Discounts',
                style: AppDesign.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              PremiumButton.primary(
                label: 'Apply',
                onPressed: () => OfferSelectionSheet.show(context, (offer) {
                  setState(() {
                    if (!_appliedOffers.any((o) => o.id == offer.id)) {
                      _appliedOffers.add(offer);
                    }
                  });
                }),
              ),
            ],
          ),
          if (_appliedOffers.isNotEmpty) ...[
            const SizedBox(height: 16),
            ..._appliedOffers.map(
              (offer) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Chip(
                  label: Text(offer.name),
                  onDeleted: () => setState(() => _appliedOffers.remove(offer)),
                  backgroundColor: Colors.green.shade50,
                  labelStyle: TextStyle(color: Colors.green.shade700),
                  deleteIconColor: Colors.green.shade700,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCustomerSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Customer Details',
                style: AppDesign.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              PremiumButton.primary(
                label: _selectedCustomer == null ? 'Select Customer' : 'Change',
                onPressed: () => CustomerSelectionSheet.show(
                  context,
                  initialCustomer: _selectedCustomer,
                  onSelected: (customer) {
                    setState(() {
                      _selectedCustomer = customer;
                      _redeemedPoints = 0; // Reset points on customer change
                    });
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_selectedCustomer != null)
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppDesign.primaryStart.withOpacity(0.1),
                  child: Text(
                    _selectedCustomer!.name[0].toUpperCase(),
                    style: const TextStyle(
                      color: AppDesign.primaryStart,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _selectedCustomer!.name,
                      style: AppDesign.bodyLarge.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _selectedCustomer!.phone,
                      style: AppDesign.bodySmall.copyWith(
                        color: AppDesign.neutral500,
                      ),
                    ),
                  ],
                ),
              ],
            )
          else
            Text(
              'No customer linked. Required for loyalty points.',
              style: AppDesign.bodySmall.copyWith(color: AppDesign.neutral400),
            ),
        ],
      ),
    );
  }

  Widget _buildLoyaltySection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppDesign.primaryStart.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppDesign.primaryStart.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.star, color: AppDesign.primaryStart),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Loyalty Points',
                  style: AppDesign.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _redeemedPoints > 0
                      ? 'Redeemed $_redeemedPoints points'
                      : '${_selectedCustomer!.loyaltyInfo?.availablePoints ?? 0} points available',
                  style: AppDesign.bodySmall,
                ),
              ],
            ),
          ),
          PremiumButton.primary(
            label: _redeemedPoints > 0 ? 'Change' : 'Redeem',
            onPressed: () {
              final summary = _calculateSummary(
                context.read<BillingCubit>().state as BillingLoaded,
              );
              LoyaltyRedemptionSheet.show(
                context,
                _selectedCustomer!,
                summary.subTotal,
                (points) => setState(() => _redeemedPoints = points),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Payment Method',
            style: AppDesign.titleMedium.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children:
                [
                  PaymentMethod.cash,
                  PaymentMethod.upi,
                  PaymentMethod.card,
                  if (widget.orders.any((o) => o.roomId != null))
                    PaymentMethod.bill_to_room,
                ].map((method) {
                  final isSelected = _selectedPaymentMethod == method;
                  return InkWell(
                    onTap: () =>
                        setState(() => _selectedPaymentMethod = method),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppDesign.primaryStart.withValues(alpha: 0.1)
                            : AppDesign.neutral50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? AppDesign.primaryStart
                              : Colors.transparent,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _getMethodIcon(method),
                            size: 20,
                            color: isSelected
                                ? AppDesign.primaryStart
                                : AppDesign.neutral600,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            method.displayName,
                            style: AppDesign.bodyMedium.copyWith(
                              color: isSelected
                                  ? AppDesign.primaryStart
                                  : AppDesign.neutral700,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
          ),
        ],
      ),
    );
  }

  IconData _getMethodIcon(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.cash:
        return Icons.money;
      case PaymentMethod.upi:
        return Icons.qr_code_scanner;
      case PaymentMethod.card:
        return Icons.credit_card;
      case PaymentMethod.bill_to_room:
        return Icons.room_service;
      default:
        return Icons.payment;
    }
  }

  Widget _buildBottomAction(BillingLoaded state, BillTaxSummary summary) {
    final label = _selectedPaymentMethod != null
        ? 'Generate & Settle • ₹${summary.grandTotal.toStringAsFixed(2)}'
        : 'Generate Bill • ₹${summary.grandTotal.toStringAsFixed(2)}';

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: PremiumButton.primary(
          label: label,
          isFullWidth: true,
          onPressed: () => _handleGenerateBill(state, summary),
        ),
      ),
    );
  }

  void _handleGenerateBill(BillingLoaded state, BillTaxSummary summary) async {
    final taxRule = state.taxRules.isNotEmpty ? state.taxRules.first : null;
    final scRule = _includeServiceCharge && state.serviceChargeRules.isNotEmpty
        ? state.serviceChargeRules.first
        : null;

    try {
      final billId = await context.read<BillingCubit>().createBill(
        tableId: widget.tableId,
        orders: widget.orders,
        taxRuleId: taxRule?.id ?? 'gst_5',
        serviceChargeRuleId: scRule?.id,
        manualDiscounts: _appliedOffers,
        customerId: _selectedCustomer?.id,
        redeemedPoints: _redeemedPoints,
      );

      // If payment method selected, settle it
      if (_selectedPaymentMethod != null) {
        await context.read<BillingCubit>().addPayment(
          billId: billId,
          amount: summary.grandTotal,
          method: _selectedPaymentMethod!,
          roomId: widget.orders
              .firstWhere(
                (o) => o.roomId != null,
                orElse: () => widget.orders.first,
              )
              .roomId,
          bookingId: widget.orders
              .firstWhere(
                (o) => o.bookingId != null,
                orElse: () => widget.orders.first,
              )
              .bookingId,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _selectedPaymentMethod != null
                  ? 'Bill generated and settled via ${_selectedPaymentMethod!.displayName}'
                  : 'Bill generated successfully!',
            ),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error generating bill: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
