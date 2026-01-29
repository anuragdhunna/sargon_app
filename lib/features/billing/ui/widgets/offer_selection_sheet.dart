import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/models/models.dart';
import '../../../../theme/app_design.dart';
import '../../../offers/logic/offer_cubit.dart';
import '../../../offers/logic/offer_state.dart';

class OfferSelectionSheet extends StatefulWidget {
  final ValueChanged<Offer> onOfferSelected;

  const OfferSelectionSheet({super.key, required this.onOfferSelected});

  static void show(BuildContext context, ValueChanged<Offer> onOfferSelected) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          OfferSelectionSheet(onOfferSelected: onOfferSelected),
    );
  }

  @override
  State<OfferSelectionSheet> createState() => _OfferSelectionSheetState();
}

class _OfferSelectionSheetState extends State<OfferSelectionSheet> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            _buildHandle(),
            _buildHeader(),
            _buildSearchBar(),
            Expanded(child: _buildOfferList()),
          ],
        ),
      ),
    );
  }

  Widget _buildHandle() {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 12),
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
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Available Offers',
            style: AppDesign.headlineSmall.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search coupons or offers...',
          prefixIcon: const Icon(Icons.search),
          filled: true,
          fillColor: AppDesign.neutral100,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
        onChanged: (val) => setState(() => _searchQuery = val),
      ),
    );
  }

  Widget _buildOfferList() {
    return BlocBuilder<OfferCubit, OfferState>(
      builder: (context, state) {
        if (state is OfferLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is OfferError) {
          return Center(child: Text(state.message));
        }
        if (state is OfferLoaded) {
          final offers = state.offers.where((offer) {
            final matchesSearch =
                offer.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                (offer.description?.toLowerCase().contains(
                      _searchQuery.toLowerCase(),
                    ) ??
                    false);
            return matchesSearch && offer.isActive;
          }).toList();

          if (offers.isEmpty) {
            return _buildEmptyState();
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            itemCount: offers.length,
            itemBuilder: (context, index) {
              final offer = offers[index];
              return _OfferCard(
                offer: offer,
                onTap: () {
                  widget.onOfferSelected(offer);
                  Navigator.pop(context);
                },
              );
            },
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.local_offer_outlined,
            size: 64,
            color: AppDesign.neutral300,
          ),
          const SizedBox(height: 16),
          Text(
            'No offers found',
            style: AppDesign.titleMedium.copyWith(color: AppDesign.neutral500),
          ),
        ],
      ),
    );
  }
}

class _OfferCard extends StatelessWidget {
  final Offer offer;
  final VoidCallback onTap;

  const _OfferCard({required this.offer, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _buildOfferIcon(),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        offer.name,
                        style: AppDesign.titleMedium.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (offer.description != null)
                        Text(
                          offer.description!,
                          style: AppDesign.bodySmall.copyWith(
                            color: AppDesign.neutral500,
                          ),
                        ),
                      const SizedBox(height: 8),
                      _buildDiscountBadge(),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: AppDesign.neutral300),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOfferIcon() {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: AppDesign.primaryStart.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(
        offer.discountType == DiscountType.percent
            ? Icons.percent
            : Icons.currency_rupee,
        color: AppDesign.primaryStart,
      ),
    );
  }

  Widget _buildDiscountBadge() {
    final value = offer.discountType == DiscountType.percent
        ? '${offer.discountValue.toStringAsFixed(0)}%'
        : '₹${offer.discountValue.toStringAsFixed(0)}';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        'OFF $value',
        style: TextStyle(
          color: Colors.green.shade700,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}
