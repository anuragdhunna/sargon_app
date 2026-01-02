import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hotel_manager/theme/app_design.dart';
import 'package:hotel_manager/core/models/models.dart';
import 'package:hotel_manager/features/billing/logic/billing_cubit.dart';
import 'package:hotel_manager/features/billing/logic/billing_state.dart';
import 'package:hotel_manager/core/services/database_service.dart';
import 'package:hotel_manager/component/cards/app_card.dart';
import 'package:intl/intl.dart';

class RoomFolioScreen extends StatelessWidget {
  final String bookingId;

  const RoomFolioScreen({super.key, required this.bookingId});

  static const String routeName = '/folio/:bookingId';

  @override
  Widget build(BuildContext context) {
    final databaseService = context.read<DatabaseService>();

    return Scaffold(
      backgroundColor: AppDesign.neutral50,
      appBar: AppBar(
        title: const Text('Room Folio & Charges'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: StreamBuilder<RoomFolio?>(
        stream: databaseService.streamFolio(bookingId),
        builder: (context, folioSnapshot) {
          return BlocBuilder<BillingCubit, BillingState>(
            builder: (context, billingState) {
              if (billingState is BillingLoading ||
                  folioSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final folio = folioSnapshot.data;
              final bills = billingState is BillingLoaded
                  ? billingState.bills
                        .where((b) => b.bookingId == bookingId)
                        .toList()
                  : <Bill>[];

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _FolioHeader(bookingId: bookingId),
                    const SizedBox(height: 24),
                    _ChargesSummary(bills: bills, folio: folio),
                    const SizedBox(height: 24),
                    const Text(
                      'Details of Charges',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...bills.map((bill) => _BillItemCard(bill: bill)),
                    if (bills.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 40),
                          child: Text(
                            'No restaurant bills linked to this room yet.',
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _FolioHeader extends StatelessWidget {
  final String bookingId;
  const _FolioHeader({required this.bookingId});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: AppDesign.primaryStart.withOpacity(0.1),
            child: Icon(Icons.person, color: AppDesign.primaryStart, size: 30),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Consolidated Folio',
                  style: AppDesign.bodySmall.copyWith(
                    color: AppDesign.neutral500,
                  ),
                ),
                Text(
                  'Booking ID: ${bookingId.split('_').last}',
                  style: AppDesign.titleLarge.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          _StatusBadge(status: 'Active'),
        ],
      ),
    );
  }
}

class _ChargesSummary extends StatelessWidget {
  final List<Bill> bills;
  final RoomFolio? folio;

  const _ChargesSummary({required this.bills, this.folio});

  @override
  Widget build(BuildContext context) {
    final double posTotal = bills.fold(0, (sum, b) => sum + b.grandTotal);
    final double totalPaid = bills.fold(0, (sum, b) => sum + b.paidAmount);
    final double balance = posTotal - totalPaid;

    return AppCard(
      color: AppDesign.primaryStart,
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _SummaryItem(
                label: 'POS Charges',
                value: '₹$posTotal',
                light: true,
              ),
              _SummaryItem(label: 'Misc Charges', value: '₹0', light: true),
              _SummaryItem(label: 'Other', value: '₹0', light: true),
            ],
          ),
          const Divider(height: 32, color: Colors.white24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Net Outstanding',
                    style: AppDesign.bodySmall.copyWith(color: Colors.white70),
                  ),
                  Text(
                    '₹$balance',
                    style: AppDesign.headlineMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppDesign.primaryStart,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
                child: const Text('Settle Folio'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final String value;
  final bool light;

  const _SummaryItem({
    required this.label,
    required this.value,
    this.light = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppDesign.bodySmall.copyWith(
            color: light ? Colors.white70 : AppDesign.neutral500,
          ),
        ),
        Text(
          value,
          style: AppDesign.titleMedium.copyWith(
            color: light ? Colors.white : AppDesign.neutral900,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _BillItemCard extends StatelessWidget {
  final Bill bill;
  const _BillItemCard({required this.bill});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        title: Text('Bill #${bill.id.split('_').last}'),
        subtitle: Text(
          'Date: ${DateFormat('dd MMM, hh:mm a').format(bill.openedAt)}',
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '₹${bill.grandTotal}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            Text(
              bill.paymentStatus.name.toUpperCase(),
              style: TextStyle(
                fontSize: 10,
                color: bill.paymentStatus == PaymentStatus.paid
                    ? Colors.green
                    : Colors.orange,
              ),
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _DetailRow(label: 'Subtotal', value: '₹${bill.subTotal}'),
                _DetailRow(
                  label: 'Service Charge',
                  value: '₹${bill.taxSummary.serviceChargeAmount}',
                ),
                _DetailRow(
                  label: 'Tax (GST)',
                  value: '₹${bill.taxSummary.totalTax}',
                ),
                const Divider(),
                _DetailRow(
                  label: 'Total Amount',
                  value: '₹${bill.grandTotal}',
                  bold: true,
                ),
                _DetailRow(
                  label: 'Amount Paid',
                  value: '₹${bill.paidAmount}',
                  color: Colors.green,
                ),
                _DetailRow(
                  label: 'Balance',
                  value: '₹${bill.remainingBalance}',
                  color: Colors.red,
                  bold: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;
  final Color? color;

  const _DetailRow({
    required this.label,
    required this.value,
    this.bold = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: AppDesign.neutral600)),
          Text(
            value,
            style: TextStyle(
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
              color: color ?? AppDesign.neutral900,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.green.withOpacity(0.5)),
      ),
      child: Text(
        status,
        style: const TextStyle(
          color: Colors.green,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
