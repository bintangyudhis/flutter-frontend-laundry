import 'package:flutter/material.dart';

class StatusChip extends StatelessWidget {
  final String status;
  const StatusChip({super.key, required this.status});

  Color get _color {
    switch (status) {
      case 'Pickup':
        return Colors.orange;
      case 'Queue':
        return Colors.blueGrey;
      case 'Process':
        return Colors.blue;
      case 'Washing':
        return Colors.cyan;
      case 'Dried':
        return Colors.teal;
      case 'Ironed':
        return Colors.purple;
      case 'Done':
        return Colors.green;
      case 'Delivery':
        return Colors.indigo;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _color.withValues(alpha: 0.4)),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: _color,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
