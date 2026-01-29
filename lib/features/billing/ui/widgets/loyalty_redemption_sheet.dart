import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../core/models/models.dart';
import '../../../../theme/app_design.dart';
import '../../../../component/buttons/premium_button.dart';

class LoyaltyRedemptionSheet extends StatefulWidget {
  final Customer customer;
  final double billAmount;
  final ValueChanged<int> onRedeem;

  const LoyaltyRedemptionSheet({
    super.key,
    required this.customer,
    required this.billAmount,
    required this.onRedeem,
  });

  static void show(
    BuildContext context,
    Customer customer,
    double billAmount,
    ValueChanged<int> onRedeem,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => LoyaltyRedemptionSheet(
        customer: customer,
        billAmount: billAmount,
        onRedeem: onRedeem,
      ),
    );
  }

  @override
  State<LoyaltyRedemptionSheet> createState() => _LoyaltyRedemptionSheetState();
}

class _LoyaltyRedemptionSheetState extends State<LoyaltyRedemptionSheet> {
  late double _redeemAmount;
  late int _pointsToRedeem;
  final double _pointValue = 0.1; // ₹0.1 per point (Example: 10 points = ₹1)

  @override
  void initState() {
    super.initState();
    _pointsToRedeem = 0;
    _redeemAmount = 0;
  }

  void _updateRedemption(double value) {
    setState(() {
      _pointsToRedeem = value.round();
      _redeemAmount = _pointsToRedeem * _pointValue;

      // Cap redemption at bill amount
      if (_redeemAmount > widget.billAmount) {
        _redeemAmount = widget.billAmount;
        _pointsToRedeem = (_redeemAmount / _pointValue).floor();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final availablePoints = widget.customer.loyaltyInfo?.availablePoints ?? 0;

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.9),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHandle(),
            const SizedBox(height: 16),
            Text(
              'Redeem Points',
              style: AppDesign.headlineSmall.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Available: $availablePoints pts (₹${(availablePoints * _pointValue).toStringAsFixed(2)})',
              style: AppDesign.bodyLarge.copyWith(color: AppDesign.neutral600),
            ),
            const SizedBox(height: 40),
            _buildSlider(availablePoints),
            const SizedBox(height: 40),
            _buildSummaryBox(),
            const SizedBox(height: 32),
            PremiumButton.primary(
              label: 'Redeem ₹${_redeemAmount.toStringAsFixed(2)}',
              isFullWidth: true,
              onPressed: _pointsToRedeem > 0
                  ? () {
                      widget.onRedeem(_pointsToRedeem);
                      Navigator.pop(context);
                    }
                  : null,
            ),
            const SizedBox(height: 40),
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

  Widget _buildSlider(int maxPoints) {
    return Column(
      children: [
        Text(
          '$_pointsToRedeem Points',
          style: AppDesign.headlineMedium.copyWith(
            fontWeight: FontWeight.bold,
            color: AppDesign.primaryStart,
          ),
        ),
        const SizedBox(height: 16),
        Slider.adaptive(
          value: _pointsToRedeem.toDouble(),
          min: 0,
          max: maxPoints.toDouble(),
          divisions: maxPoints > 0 ? maxPoints : 1,
          activeColor: AppDesign.primaryStart,
          onChanged: maxPoints > 0 ? _updateRedemption : null,
        ),
      ],
    );
  }

  Widget _buildSummaryBox() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppDesign.neutral100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'New Point Balance',
                style: AppDesign.bodySmall.copyWith(
                  color: AppDesign.neutral500,
                ),
              ),
              Text(
                '${(widget.customer.loyaltyInfo?.availablePoints ?? 0) - _pointsToRedeem} pts',
                style: AppDesign.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const Icon(Icons.arrow_forward, color: AppDesign.neutral300),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Cash Value',
                style: AppDesign.bodySmall.copyWith(
                  color: AppDesign.neutral500,
                ),
              ),
              Text(
                '₹${_redeemAmount.toStringAsFixed(2)}',
                style: AppDesign.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
