import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../theme/app_design.dart';
import '../../../../component/buttons/premium_button.dart';
import '../../../../component/cards/app_card.dart';
import '../../../../component/inputs/app_text_field.dart';
import '../../../../core/models/event_models.dart';
import '../../logic/event_cubit.dart';

class HallManagementScreen extends StatefulWidget {
  const HallManagementScreen({super.key});

  static const String routeName = '/settings/halls';

  @override
  State<HallManagementScreen> createState() => _HallManagementScreenState();
}

class _HallManagementScreenState extends State<HallManagementScreen> {
  @override
  void initState() {
    super.initState();
    // context.read<EventCubit>().streamHalls(); // Keep streams for real-time if needed, but user asked for fetch
    // context.read<EventCubit>().streamHallFeatures();
    context.read<EventCubit>().fetchHalls();
    context.read<EventCubit>().fetchHallFeatures();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppDesign.neutral50,
        appBar: AppBar(
          title: const Text('Hall Management'),
          backgroundColor: Colors.white,
          elevation: 0,
          titleTextStyle: AppDesign.headlineSmall.copyWith(
            color: AppDesign.neutral900,
            fontWeight: FontWeight.bold,
          ),
          iconTheme: const IconThemeData(color: AppDesign.neutral900),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Halls'),
              Tab(text: 'Features'),
            ],
            labelColor: AppDesign.primaryStart,
            unselectedLabelColor: AppDesign.neutral600,
            indicatorColor: AppDesign.primaryStart,
          ),
        ),
        body: TabBarView(children: [_buildHallsTab(), _buildFeaturesTab()]),
      ),
    );
  }

  Widget _buildHallsTab() {
    return BlocBuilder<EventCubit, EventState>(
      buildWhen: (previous, current) =>
          previous.halls != current.halls || previous.status != current.status,
      builder: (context, state) {
        if (state.status == EventStatusType.loading && state.halls.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        return Scaffold(
          backgroundColor: Colors.transparent,
          body: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: state.halls.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final hall = state.halls[index];
              return _HallCard(hall: hall);
            },
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _showHallDialog(context),
            backgroundColor: AppDesign.primaryStart,
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text(
              'Add Hall',
              style: TextStyle(color: Colors.white),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFeaturesTab() {
    return BlocBuilder<EventCubit, EventState>(
      buildWhen: (previous, current) =>
          previous.hallFeatures != current.hallFeatures,
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: state.hallFeatures.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final feature = state.hallFeatures[index];
              return _FeatureCard(feature: feature);
            },
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _showFeatureDialog(context),
            backgroundColor: AppDesign.primaryStart,
            icon: const Icon(Icons.star, color: Colors.white),
            label: const Text(
              'Add Feature',
              style: TextStyle(color: Colors.white),
            ),
          ),
        );
      },
    );
  }

  void _showFeatureDialog(BuildContext context, [HallFeature? feature]) {
    showDialog(
      context: context,
      builder: (_) => BlocProvider.value(
        value: context.read<EventCubit>(),
        child: _FeatureDialog(feature: feature),
      ),
    );
  }

  void _showHallDialog(BuildContext context, [Hall? hall]) {
    showDialog(
      context: context,
      builder: (_) => BlocProvider.value(
        value: context.read<EventCubit>(),
        child: _HallDialog(hall: hall),
      ),
    );
  }
}

class _HallCard extends StatelessWidget {
  final Hall hall;

  const _HallCard({required this.hall});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(
          hall.name,
          style: AppDesign.titleMedium.copyWith(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          'Capacity: ${hall.capacity} pax\n${hall.description ?? "No description"}',
          style: AppDesign.bodyMedium.copyWith(color: AppDesign.neutral600),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Switch(
              value: hall.isActive,
              onChanged: (value) {
                context.read<EventCubit>().saveHall(
                  hall.copyWith(isActive: value),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.edit, color: AppDesign.neutral600),
              onPressed: () => _showHallDialog(context, hall),
            ),
          ],
        ),
      ),
    );
  }

  void _showHallDialog(BuildContext context, Hall hall) {
    showDialog(
      context: context,
      builder: (_) => BlocProvider.value(
        value: context.read<EventCubit>(),
        child: _HallDialog(hall: hall),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final HallFeature feature;

  const _FeatureCard({required this.feature});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: CircleAvatar(
          backgroundColor: AppDesign.neutral50,
          child: Icon(
            IconData(
              feature.iconCode ?? Icons.star.codePoint,
              fontFamily: 'MaterialIcons',
            ),
            color: AppDesign.primaryStart,
          ),
        ),
        title: Text(
          feature.name,
          style: AppDesign.titleMedium.copyWith(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          feature.description ?? 'No description',
          style: AppDesign.bodyMedium.copyWith(color: AppDesign.neutral600),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: AppDesign.error),
          onPressed: () {
            context.read<EventCubit>().deleteHallFeature(feature.id);
          },
        ),
        onTap: () => _showFeatureDialog(context, feature),
      ),
    );
  }

  void _showFeatureDialog(BuildContext context, HallFeature feature) {
    showDialog(
      context: context,
      builder: (_) => BlocProvider.value(
        value: context.read<EventCubit>(),
        child: _FeatureDialog(feature: feature),
      ),
    );
  }
}

class _HallDialog extends StatefulWidget {
  final Hall? hall;

  const _HallDialog({this.hall});

  @override
  State<_HallDialog> createState() => _HallDialogState();
}

class _HallDialogState extends State<_HallDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _capacityController;
  late final TextEditingController _descController;
  late List<String> _selectedFeatureIds;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.hall?.name);
    _capacityController = TextEditingController(
      text: widget.hall?.capacity.toString(),
    );
    _descController = TextEditingController(text: widget.hall?.description);
    _selectedFeatureIds = List.from(widget.hall?.featureIds ?? []);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.hall != null;

    return AlertDialog(
      title: Text(isEdit ? 'Edit Hall' : 'Add Hall'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppTextField(
              controller: _nameController,
              label: 'Hall Name',
              hint: 'e.g., Grand Ballroom',
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: _capacityController,
              label: 'Capacity (pax)',
              hint: 'e.g., 500',
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: _descController,
              label: 'Description',
              hint: 'Optional details',
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Hall Features',
                style: AppDesign.titleSmall.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),
            BlocBuilder<EventCubit, EventState>(
              builder: (context, state) {
                if (state.hallFeatures.isEmpty) {
                  return const Text(
                    'No features defined. Add some in the Features tab.',
                  );
                }
                return Column(
                  children: state.hallFeatures.map((feature) {
                    return CheckboxListTile(
                      title: Text(feature.name),
                      value: _selectedFeatureIds.contains(feature.id),
                      onChanged: (value) {
                        setState(() {
                          if (value == true) {
                            _selectedFeatureIds.add(feature.id);
                          } else {
                            _selectedFeatureIds.remove(feature.id);
                          }
                        });
                      },
                      contentPadding: EdgeInsets.zero,
                      controlAffinity: ListTileControlAffinity.leading,
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        PremiumButton.primary(
          label: isEdit ? 'Update' : 'Create',
          onPressed: () {
            final hall = Hall(
              id:
                  widget.hall?.id ??
                  context.read<EventCubit>().repository.nextId('halls'),
              name: _nameController.text,
              capacity: int.tryParse(_capacityController.text) ?? 0,
              description: _descController.text,
              featureIds: _selectedFeatureIds,
              isActive: widget.hall?.isActive ?? true,
            );
            context.read<EventCubit>().saveHall(hall);
            Navigator.pop(context);
          },
        ),
      ],
    );
  }
}

class _FeatureDialog extends StatefulWidget {
  final HallFeature? feature;

  const _FeatureDialog({this.feature});

  @override
  State<_FeatureDialog> createState() => _FeatureDialogState();
}

class _FeatureDialogState extends State<_FeatureDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _descController;
  int? _selectedIconCode;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.feature?.name);
    _descController = TextEditingController(text: widget.feature?.description);
    _selectedIconCode = widget.feature?.iconCode;
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.feature != null;

    return AlertDialog(
      title: Text(isEdit ? 'Edit Feature' : 'Add Feature'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppTextField(
              controller: _nameController,
              label: 'Feature Name',
              hint: 'e.g., DJ System, Stage Decoration',
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: _descController,
              label: 'Description',
              hint: 'Optional details',
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerLeft,
              child: Text('Icon', style: AppDesign.labelMedium),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                _buildIconOption(Icons.music_note),
                _buildIconOption(Icons.celebration),
                _buildIconOption(Icons.event_seat),
                _buildIconOption(Icons.lightbulb),
                _buildIconOption(Icons.camera_alt),
                _buildIconOption(Icons.restaurant),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        PremiumButton.primary(
          label: isEdit ? 'Update' : 'Create',
          onPressed: () {
            if (_nameController.text.isEmpty) return;
            final feature = HallFeature(
              id:
                  widget.feature?.id ??
                  context.read<EventCubit>().repository.nextId('hall_features'),
              name: _nameController.text,
              description: _descController.text,
              iconCode: _selectedIconCode,
            );
            context.read<EventCubit>().saveHallFeature(feature);
            Navigator.pop(context);
          },
        ),
      ],
    );
  }

  Widget _buildIconOption(IconData icon) {
    final isSelected = _selectedIconCode == icon.codePoint;
    return GestureDetector(
      onTap: () => setState(() => _selectedIconCode = icon.codePoint),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected ? AppDesign.neutral50 : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppDesign.primaryStart : AppDesign.neutral300,
          ),
        ),
        child: Icon(
          icon,
          color: isSelected ? AppDesign.primaryStart : AppDesign.neutral600,
        ),
      ),
    );
  }
}
