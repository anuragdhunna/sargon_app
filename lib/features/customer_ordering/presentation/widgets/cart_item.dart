import 'package:flutter/material.dart';
import 'package:hotel_manager/core/models/models.dart';

class CartItem extends StatelessWidget {
  final OrderItem item;
  final VoidCallback onRemove;
  final ValueChanged<int> onQuantityChanged;

  const CartItem({
    super.key,
    required this.item,
    required this.onRemove,
    required this.onQuantityChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Remove item'),
            content: Text('Remove "${item.name}" from cart?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Remove'),
              ),
            ],
          ),
        );
      },
      onDismissed: (direction) {
        onRemove();
      },
      child: ListTile(
        leading: const Icon(Icons.fastfood),
        title: Text(item.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (item.notes != null && item.notes!.isNotEmpty)
              Text(
                'Notes: ${item.notes}',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            Text(
              'Qty: ${item.quantity} × ₹${item.price.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.remove),
              onPressed: item.quantity > 1
                  ? () => onQuantityChanged(item.quantity - 1)
                  : null,
            ),
            Text('${item.quantity}'),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => onQuantityChanged(item.quantity + 1),
            ),
          ],
        ),
      ),
    );
  }
}
