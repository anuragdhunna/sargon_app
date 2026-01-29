import 'package:flutter/material.dart';

class KdsLegend extends StatelessWidget {
  const KdsLegend({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: const [
          _LegendItem(color: Colors.red, label: 'VIP/Rush'),
          _LegendItem(color: Colors.orange, label: 'Delayed'),
          _LegendItem(color: Colors.blue, label: 'Preparing'),
          _LegendItem(color: Colors.green, label: 'Ready'),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 12),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
