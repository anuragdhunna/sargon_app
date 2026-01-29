import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hotel_manager/core/models/models.dart';
import 'package:hotel_manager/features/offers/logic/offer_cubit.dart';
import 'package:hotel_manager/features/offers/logic/offer_state.dart';
import 'package:hotel_manager/theme/app_design.dart';

class ApplyOfferDialog extends StatelessWidget {
  final String orderId;
  final Function(Offer) onApply;

  const ApplyOfferDialog({
    super.key,
    required this.orderId,
    required this.onApply,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Available Offers'),
      content: SizedBox(
        width: 400,
        child: BlocBuilder<OfferCubit, OfferState>(
          builder: (context, state) {
            if (state is OfferLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is OfferLoaded) {
              final activeOffers = state.offers
                  .where((o) => o.isActive)
                  .toList();
              if (activeOffers.isEmpty) {
                return const Center(child: Text('No active offers available.'));
              }
              return ListView.builder(
                shrinkWrap: true,
                itemCount: activeOffers.length,
                itemBuilder: (context, index) {
                  final offer = activeOffers[index];
                  return ListTile(
                    title: Text(offer.name),
                    subtitle: Text(offer.description ?? ''),
                    trailing: Text(
                      offer.discountType == DiscountType.percent
                          ? '${offer.discountValue}% OFF'
                          : '₹${offer.discountValue} OFF',
                      style: TextStyle(
                        color: AppDesign.primaryStart,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onTap: () {
                      onApply(offer);
                      Navigator.pop(context);
                    },
                  );
                },
              );
            }
            return const Center(child: Text('Failed to load offers.'));
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
