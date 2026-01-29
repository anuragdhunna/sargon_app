import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hotel_manager/core/models/models.dart';
import 'package:hotel_manager/features/orders/logic/order_cubit.dart';
import 'package:hotel_manager/theme/app_design.dart';

class KdsItemRow extends StatelessWidget {
  final String orderId;
  final OrderItem item;

  const KdsItemRow({super.key, required this.orderId, required this.item});

  @override
  Widget build(BuildContext context) {
    final bool isDelayed = item.isDelayed;
    final bool isCancelled = item.kdsStatus == KdsStatus.cancelled;

    return Opacity(
      opacity: isCancelled ? 0.5 : 1.0,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  '${item.quantity}x',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    item.name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      decoration: isCancelled
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                ),
                if (isDelayed)
                  const Icon(
                    Icons.timer_outlined,
                    color: Colors.orange,
                    size: 18,
                  ),
                const SizedBox(width: 8),
                _buildStatusAction(context),
              ],
            ),
            if (item.notes != null)
              Padding(
                padding: const EdgeInsets.only(left: 32, top: 2),
                child: Text(
                  item.notes!,
                  style: TextStyle(
                    color: Colors.red.shade700,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            if (item.kdsStatus == KdsStatus.fired ||
                item.kdsStatus == KdsStatus.preparing)
              Padding(
                padding: const EdgeInsets.only(left: 32, top: 8),
                child: LinearProgressIndicator(
                  value: _calculateProgress(),
                  backgroundColor: AppDesign.neutral100,
                  color: isDelayed ? Colors.orange : Colors.blue,
                ),
              ),
          ],
        ),
      ),
    );
  }

  double _calculateProgress() {
    if (item.firedAt == null) return 0;
    final elapsed = DateTime.now().difference(item.firedAt!).inMinutes;
    final progress = elapsed / item.expectedPrepTimeMinutes;
    return progress.clamp(0.0, 1.0);
  }

  Widget _buildStatusAction(BuildContext context) {
    if (item.kdsStatus == KdsStatus.cancelled) {
      return const Text(
        'VOID',
        style: TextStyle(
          color: Colors.red,
          fontWeight: FontWeight.bold,
          fontSize: 10,
        ),
      );
    }
    if (item.kdsStatus == KdsStatus.served) {
      return const Icon(Icons.check_circle, color: Colors.green, size: 20);
    }
    if (item.kdsStatus == KdsStatus.pending) {
      return TextButton(
        style: TextButton.styleFrom(
          backgroundColor: AppDesign.neutral200,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          minimumSize: const Size(60, 30),
        ),
        onPressed: () {
          context.read<OrderCubit>().fireCourse(orderId, item.course);
        },
        child: const Text(
          'FIRE',
          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
        ),
      );
    }

    String label;
    Color color;
    KdsStatus nextStatus;

    switch (item.kdsStatus) {
      case KdsStatus.fired:
        label = 'PREP';
        color = Colors.blue;
        nextStatus = KdsStatus.preparing;
        break;
      case KdsStatus.preparing:
        label = 'READY';
        color = Colors.orange;
        nextStatus = KdsStatus.ready;
        break;
      case KdsStatus.ready:
        label = 'SERVE';
        color = Colors.green;
        nextStatus = KdsStatus.served;
        break;
      default:
        return const SizedBox.shrink();
    }

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        minimumSize: const Size(60, 30),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
      onPressed: () {
        context.read<OrderCubit>().updateItemKdsStatus(
          orderId,
          item.id,
          nextStatus,
        );
      },
      child: Text(
        label,
        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}
