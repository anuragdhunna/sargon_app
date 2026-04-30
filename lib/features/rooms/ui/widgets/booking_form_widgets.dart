import 'package:flutter/material.dart';
import 'package:hotel_manager/component/inputs/app_text_field.dart';
import 'package:hotel_manager/theme/app_design.dart';

class AccompanyingGuestDialog extends StatelessWidget {
  final List<Map<String, String>> existingPersons;
  final Function(Map<String, String>) onAdd;

  const AccompanyingGuestDialog({
    super.key,
    required this.existingPersons,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    final nameController = TextEditingController();
    final relationController = TextEditingController();
    final idController = TextEditingController();

    return AlertDialog(
      title: const Text('Guest Details'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppTextField(
            controller: nameController,
            labelText: 'Full Name',
            hintText: 'John Doe',
          ),
          const SizedBox(height: 12),
          AppTextField(
            controller: relationController,
            labelText: 'Relation',
            hintText: 'Spouse, Friend, etc.',
          ),
          const SizedBox(height: 12),
          AppTextField(
            controller: idController,
            labelText: 'ID Proof Number',
            hintText: 'Aadhar/Passport Number',
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel', style: TextStyle(color: AppDesign.neutral500)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppDesign.primaryStart,
            foregroundColor: Colors.white,
          ),
          onPressed: () {
            if (nameController.text.isNotEmpty) {
              onAdd({
                'name': nameController.text,
                'relation': relationController.text,
                'id': idController.text,
              });
              Navigator.pop(context);
            }
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}
