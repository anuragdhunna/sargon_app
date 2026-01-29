import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:hotel_manager/theme/app_design.dart';
import 'package:hotel_manager/core/models/models.dart';
import 'package:hotel_manager/features/offers/logic/offer_cubit.dart';
import 'package:hotel_manager/features/offers/logic/offer_state.dart';
import 'package:hotel_manager/component/cards/app_card.dart';
import 'package:hotel_manager/component/buttons/premium_button.dart';
import 'package:hotel_manager/component/inputs/app_text_field.dart';

class OfferManagementScreen extends StatelessWidget {
  const OfferManagementScreen({super.key});

  static const String routeName = '/offers';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppDesign.neutral50,
      appBar: AppBar(
        title: const Text('Offer Management'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: BlocBuilder<OfferCubit, OfferState>(
        builder: (context, state) {
          if (state is OfferLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is OfferError) {
            return Center(child: Text('Error: ${state.message}'));
          }

          if (state is OfferLoaded) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SectionHeader(
                    title: 'Active Offers',
                    buttonLabel: 'Create New Offer',
                    onPressed: () => _showOfferDialog(context),
                  ),
                  const SizedBox(height: 16),
                  if (state.offers.isEmpty)
                    const _EmptyState(message: 'No active offers.')
                  else
                    _OffersGrid(offers: state.offers),
                  const SizedBox(height: 48),
                  _SectionHeader(
                    title: 'Happy Hours',
                    buttonLabel: 'Set Happy Hour',
                    onPressed: () => _showHappyHourDialog(context),
                  ),
                  const SizedBox(height: 16),
                  if (state.happyHours.isEmpty)
                    const _EmptyState(message: 'No happy hours scheduled.')
                  else
                    _HappyHoursList(happyHours: state.happyHours),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  void _showOfferDialog(BuildContext context, [Offer? offer]) {
    showDialog(
      context: context,
      builder: (context) => _OfferFormDialog(offer: offer),
    );
  }

  void _showHappyHourDialog(BuildContext context, [HappyHour? happyHour]) {
    showDialog(
      context: context,
      builder: (context) => _HappyHourFormDialog(happyHour: happyHour),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String buttonLabel;
  final VoidCallback onPressed;

  const _SectionHeader({
    required this.title,
    required this.buttonLabel,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: AppDesign.titleLarge.copyWith(fontWeight: FontWeight.bold),
        ),
        PremiumButton.primary(label: buttonLabel, onPressed: onPressed),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String message;
  const _EmptyState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Text(
          message,
          style: AppDesign.bodyMedium.copyWith(color: AppDesign.neutral500),
        ),
      ),
    );
  }
}

class _OffersGrid extends StatelessWidget {
  final List<Offer> offers;
  const _OffersGrid({required this.offers});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.5,
      ),
      itemCount: offers.length,
      itemBuilder: (context, index) {
        return _OfferCard(offer: offers[index]);
      },
    );
  }
}

class _OfferCard extends StatelessWidget {
  final Offer offer;
  const _OfferCard({required this.offer});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _TypeBadge(type: offer.offerType.name),
              Switch(
                value: offer.isActive,
                onChanged: (val) {
                  final updated = Offer(
                    id: offer.id,
                    name: offer.name,
                    offerType: offer.offerType,
                    discountType: offer.discountType,
                    discountValue: offer.discountValue,
                    isActive: val,
                    description: offer.description,
                  );
                  context.read<OfferCubit>().saveOffer(updated);
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            offer.name,
            style: AppDesign.titleMedium.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            offer.discountType == DiscountType.percent
                ? '${offer.discountValue}% Off'
                : '₹${offer.discountValue} Off',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.green.shade700,
            ),
          ),
          const Spacer(),
          Text(
            offer.description ?? 'Generic discount for customers.',
            style: AppDesign.bodySmall.copyWith(color: AppDesign.neutral500),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _TypeBadge extends StatelessWidget {
  final String type;
  const _TypeBadge({required this.type});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppDesign.primaryStart.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        type.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: AppDesign.primaryStart,
        ),
      ),
    );
  }
}

class _HappyHoursList extends StatelessWidget {
  final List<HappyHour> happyHours;
  const _HappyHoursList({required this.happyHours});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: happyHours.map((hh) => _HappyHourCard(happyHour: hh)).toList(),
    );
  }
}

class _HappyHourCard extends StatelessWidget {
  final HappyHour happyHour;
  const _HappyHourCard({required this.happyHour});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: AppCard(
        child: ListTile(
          leading: const Icon(Icons.timer_outlined, color: Colors.orange),
          title: Text(
            happyHour.name,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            '${happyHour.startTime} - ${happyHour.endTime} • ${happyHour.applicableDays.join(", ")}',
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                happyHour.discountType == DiscountType.percent
                    ? '${happyHour.discountValue}% Off'
                    : '₹${happyHour.discountValue} Off',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 8),
              Switch(
                value: happyHour.isActive,
                onChanged: (val) {
                  final updated = HappyHour(
                    id: happyHour.id,
                    name: happyHour.name,
                    applicableDays: happyHour.applicableDays,
                    startTime: happyHour.startTime,
                    endTime: happyHour.endTime,
                    discountType: happyHour.discountType,
                    discountValue: happyHour.discountValue,
                    isActive: val,
                  );
                  context.read<OfferCubit>().saveHappyHour(updated);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OfferFormDialog extends StatefulWidget {
  final Offer? offer;
  const _OfferFormDialog({this.offer});

  @override
  State<_OfferFormDialog> createState() => _OfferFormDialogState();
}

class _OfferFormDialogState extends State<_OfferFormDialog> {
  final _formKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.offer == null ? 'Create Offer' : 'Edit Offer'),
      content: SizedBox(
        width: 500,
        child: SingleChildScrollView(
          child: FormBuilder(
            key: _formKey,
            initialValue: {
              'name': widget.offer?.name,
              'offerType': widget.offer?.offerType ?? OfferType.bill,
              'discountType':
                  widget.offer?.discountType ?? DiscountType.percent,
              'discountValue': widget.offer?.discountValue.toString(),
              'description': widget.offer?.description,
              'minBillAmount': widget.offer?.minBillAmount.toString() ?? '0',
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppTextField(
                  name: 'name',
                  label: 'Offer Name',
                  validator: FormBuilderValidators.required(),
                ),
                const SizedBox(height: 16),
                FormBuilderDropdown<OfferType>(
                  name: 'offerType',
                  decoration: const InputDecoration(labelText: 'Offer Type'),
                  items: OfferType.values
                      .map(
                        (t) => DropdownMenuItem(
                          value: t,
                          child: Text(t.name.toUpperCase()),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: FormBuilderDropdown<DiscountType>(
                        name: 'discountType',
                        decoration: const InputDecoration(
                          labelText: 'Discount Type',
                        ),
                        items: DiscountType.values
                            .map(
                              (t) => DropdownMenuItem(
                                value: t,
                                child: Text(t.name.toUpperCase()),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: AppTextField(
                        name: 'discountValue',
                        label: 'Value',
                        keyboardType: TextInputType.number,
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(),
                          FormBuilderValidators.numeric(),
                        ]),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                AppTextField(
                  name: 'minBillAmount',
                  label: 'Min Bill Amount',
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  name: 'description',
                  label: 'Description',
                  maxLines: 2,
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState?.saveAndValidate() ?? false) {
              final val = _formKey.currentState!.value;
              final newOffer = Offer(
                id:
                    widget.offer?.id ??
                    'off_${DateTime.now().millisecondsSinceEpoch}',
                name: val['name'],
                offerType: val['offerType'],
                discountType: val['discountType'],
                discountValue: double.parse(val['discountValue']),
                minBillAmount:
                    double.tryParse(val['minBillAmount'] ?? '0') ?? 0,
                description: val['description'],
                isActive: widget.offer?.isActive ?? true,
              );
              context.read<OfferCubit>().saveOffer(newOffer);
              Navigator.pop(context);
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}

class _HappyHourFormDialog extends StatefulWidget {
  final HappyHour? happyHour;
  const _HappyHourFormDialog({this.happyHour});

  @override
  State<_HappyHourFormDialog> createState() => _HappyHourFormDialogState();
}

class _HappyHourFormDialogState extends State<_HappyHourFormDialog> {
  final _formKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.happyHour == null ? 'Set Happy Hour' : 'Edit Happy Hour',
      ),
      content: SizedBox(
        width: 500,
        child: SingleChildScrollView(
          child: FormBuilder(
            key: _formKey,
            initialValue: {
              'name': widget.happyHour?.name,
              'startTime': widget.happyHour?.startTime ?? '18:00',
              'endTime': widget.happyHour?.endTime ?? '21:00',
              'discountType':
                  widget.happyHour?.discountType ?? DiscountType.percent,
              'discountValue': widget.happyHour?.discountValue.toString(),
              'applicableDays':
                  widget.happyHour?.applicableDays ??
                  [
                    'Monday',
                    'Tuesday',
                    'Wednesday',
                    'Thursday',
                    'Friday',
                    'Saturday',
                    'Sunday',
                  ],
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppTextField(
                  name: 'name',
                  label: 'Name (e.g. Evening Happy Hour)',
                  validator: FormBuilderValidators.required(),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: AppTextField(
                        name: 'startTime',
                        label: 'Start (HH:mm)',
                        validator: FormBuilderValidators.required(),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: AppTextField(
                        name: 'endTime',
                        label: 'End (HH:mm)',
                        validator: FormBuilderValidators.required(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                FormBuilderCheckboxGroup<String>(
                  name: 'applicableDays',
                  decoration: const InputDecoration(labelText: 'Active Days'),
                  options: const [
                    FormBuilderFieldOption(value: 'Monday'),
                    FormBuilderFieldOption(value: 'Tuesday'),
                    FormBuilderFieldOption(value: 'Wednesday'),
                    FormBuilderFieldOption(value: 'Thursday'),
                    FormBuilderFieldOption(value: 'Friday'),
                    FormBuilderFieldOption(value: 'Saturday'),
                    FormBuilderFieldOption(value: 'Sunday'),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: FormBuilderDropdown<DiscountType>(
                        name: 'discountType',
                        decoration: const InputDecoration(
                          labelText: 'Discount Type',
                        ),
                        items: DiscountType.values
                            .map(
                              (t) => DropdownMenuItem(
                                value: t,
                                child: Text(t.name.toUpperCase()),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: AppTextField(
                        name: 'discountValue',
                        label: 'Value',
                        keyboardType: TextInputType.number,
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(),
                          FormBuilderValidators.numeric(),
                        ]),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState?.saveAndValidate() ?? false) {
              final val = _formKey.currentState!.value;
              final newHH = HappyHour(
                id:
                    widget.happyHour?.id ??
                    'hh_${DateTime.now().millisecondsSinceEpoch}',
                name: val['name'],
                applicableDays: List<String>.from(val['applicableDays']),
                startTime: val['startTime'],
                endTime: val['endTime'],
                discountType: val['discountType'],
                discountValue: double.parse(val['discountValue']),
                isActive: widget.happyHour?.isActive ?? true,
              );
              context.read<OfferCubit>().saveHappyHour(newHH);
              Navigator.pop(context);
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
