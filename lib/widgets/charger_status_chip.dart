import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ChargerStatusChip extends StatelessWidget {
  final String status;

  const ChargerStatusChip({super.key, required this.status});

  Color get _color {
    switch (status) {
      case 'available':
        return AppColors.success;
      case 'occupied':
        return AppColors.danger;
      case 'reserved':
        return AppColors.secondaryBlue;
      case 'maintenance':
        return AppColors.warning;
      case 'offline':
        return AppColors.lightText;
      default:
        return AppColors.lightText;
    }
  }

  IconData get _icon {
    switch (status) {
      case 'available':
        return Icons.check_circle;
      case 'occupied':
        return Icons.electric_bolt;
      case 'reserved':
        return Icons.lock_clock;
      case 'maintenance':
        return Icons.build;
      case 'offline':
        return Icons.power_off;
      default:
        return Icons.help;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_icon, size: 13, color: _color),
          const SizedBox(width: 4),
          Text(
            status[0].toUpperCase() + status.substring(1),
            style: TextStyle(fontSize: 12, color: _color, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
