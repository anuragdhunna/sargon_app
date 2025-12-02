import '../../../inventory_index.dart';

/// Input model for receiving items against a PO
class ReceivingItemInput {
  final POLineItem lineItem;
  final double maxQuantity;
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController notesController = TextEditingController();
  bool qualityCheckPassed = true;

  ReceivingItemInput({required this.lineItem, required this.maxQuantity});

  void dispose() {
    quantityController.dispose();
    notesController.dispose();
  }
}

/// Input model for manually adding items without a PO
class ManualItemInput {
  InventoryItem? selectedItem;
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController notesController = TextEditingController();
  bool qualityCheckPassed = true;

  void dispose() {
    quantityController.dispose();
    priceController.dispose();
    notesController.dispose();
  }
}
