import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:hotel_manager/core/models/menu_item_model.dart';
import 'dart:io';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:image_picker/image_picker.dart';
import 'package:hotel_manager/component/buttons/premium_button.dart';
import 'package:hotel_manager/component/inputs/app_text_field.dart';
import 'package:hotel_manager/core/models/recipe_model.dart';
import 'package:hotel_manager/features/settings/presentation/menu/recipe_builder_widget.dart';
import 'package:uuid/uuid.dart';
import 'package:hotel_manager/core/services/storage/image_storage_service.dart';

class MenuFormScreen extends StatefulWidget {
  final MenuItem? existingItem; // null = create mode
  final Future<void> Function(MenuItem) onSave;

  const MenuFormScreen({super.key, this.existingItem, required this.onSave});

  @override
  State<MenuFormScreen> createState() => _MenuFormScreenState();
}

class _MenuFormScreenState extends State<MenuFormScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _priceController = TextEditingController();
  final _prepTimeController = TextEditingController();

  MenuCategory _category = MenuCategory.mainCourse;
  DietaryType _dietaryType = DietaryType.veg;
  bool _isAvailable = true;
  List<RecipeIngredient> _recipe = [];

  // Image Upload
  XFile? _selectedImage;
  String? _currentImageUrl;
  bool _isUploading = false;
  final ImageStorageService _imageService = ImageStorageService();

  @override
  void initState() {
    super.initState();
    if (widget.existingItem != null) {
      final item = widget.existingItem!;
      _nameController.text = item.name;
      _descController.text = item.description;
      _priceController.text = item.price.toString();
      _prepTimeController.text = item.preparationTimeMinutes.toString();
      _category = item.category;
      _dietaryType = item.dietaryType;
      _isAvailable = item.isAvailable;
      _currentImageUrl = item.imageUrl;
      _recipe = item.recipe ?? [];
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _priceController.dispose();
    _prepTimeController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = pickedFile;
      });
    }
  }

  void _save() async {
    print('DEBUG: _save() called');
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      // 1. Validate Recipe
      if (_recipe.isEmpty) {
        print('DEBUG: Recipe is empty, blocking save');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please add at least one ingredient to the recipe.'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      if (_isUploading) {
        print('DEBUG: Already uploading, ignoring click');
        return;
      }
      setState(() => _isUploading = true);
      print('DEBUG: Setting _isUploading = true');

      try {
        String? imageUrl = _currentImageUrl;

        if (_selectedImage != null) {
          print('DEBUG: Uploading new image: ${_selectedImage!.name}');
          imageUrl = await _imageService.uploadImage(
            _selectedImage!,
            'menu_items',
          );
          print('DEBUG: Image upload successful: $imageUrl');
        }

        final item = MenuItem(
          id: widget.existingItem?.id ?? const Uuid().v4(),
          name: _nameController.text,
          description: _descController.text,
          price: double.tryParse(_priceController.text) ?? 0.0,
          category: _category,
          imageUrl: imageUrl ?? '',
          isAvailable: _isAvailable,
          dietaryType: _dietaryType,
          preparationTimeMinutes: int.tryParse(_prepTimeController.text) ?? 15,
          recipe: _recipe,
        );

        print('DEBUG: Calling onSave callback for item: ${item.name}');
        await widget.onSave(item);
        print('DEBUG: onSave callback completed');

        if (mounted) {
          Navigator.pop(context);
        }
      } catch (e) {
        print('DEBUG: Error in _save(): $e');
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error saving item: $e')));
        }
      } finally {
        if (mounted) {
          print('DEBUG: Finalizing _save(), setting _isUploading = false');
          setState(() => _isUploading = false);
        }
      }
    } else {
      print('DEBUG: Form validation failed');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.existingItem == null ? 'New Menu Item' : 'Edit Menu Item',
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: FormBuilder(
          key: _formKey,
          child: Column(
            children: [
              // Image Picker UI
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                    image: _selectedImage != null
                        ? DecorationImage(
                            image: kIsWeb
                                ? NetworkImage(_selectedImage!.path)
                                : FileImage(File(_selectedImage!.path))
                                      as ImageProvider,
                            fit: BoxFit.cover,
                          )
                        : (_currentImageUrl != null &&
                              _currentImageUrl!.isNotEmpty)
                        ? DecorationImage(
                            image: NetworkImage(_currentImageUrl!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child:
                      (_selectedImage == null &&
                          (_currentImageUrl == null ||
                              _currentImageUrl!.isEmpty))
                      ? const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_a_photo,
                              size: 40,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Tap to add image',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        )
                      : null,
                ),
              ),
              const SizedBox(height: 16),

              AppTextField(
                controller: _nameController,
                label: 'Item Name',
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(),
                ]),
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _descController,
                label: 'Description',
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      controller: _priceController,
                      label: 'Price',
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^\d*\.?\d*'),
                        ),
                      ],
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(),
                        FormBuilderValidators.numeric(),
                        FormBuilderValidators.min(0),
                      ]),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: AppTextField(
                      controller: _prepTimeController,
                      label: 'Prep Time (min)',
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.numeric(),
                        FormBuilderValidators.min(0),
                      ]),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<MenuCategory>(
                value: _category,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
                items: MenuCategory.values.map((c) {
                  return DropdownMenuItem(
                    value: c,
                    child: Text(c.name.toUpperCase()),
                  );
                }).toList(),
                onChanged: (v) => setState(() => _category = v!),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<DietaryType>(
                value: _dietaryType,
                decoration: const InputDecoration(
                  labelText: 'Dietary Type',
                  border: OutlineInputBorder(),
                ),
                items: DietaryType.values.map((c) {
                  return DropdownMenuItem(value: c, child: Text(c.displayName));
                }).toList(),
                onChanged: (v) => setState(() => _dietaryType = v!),
              ),
              SwitchListTile(
                title: const Text('Available'),
                value: _isAvailable,
                onChanged: (v) => setState(() => _isAvailable = v),
              ),
              const SizedBox(height: 24),

              // Recipe Builder
              RecipeBuilderWidget(
                initialRecipe: _recipe,
                onChanged: (newRecipe) {
                  _recipe = newRecipe;
                },
              ),

              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: _isUploading
                    ? const Center(child: CircularProgressIndicator())
                    : PremiumButton.primary(
                        label: 'Save Item',
                        onPressed: _save,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
