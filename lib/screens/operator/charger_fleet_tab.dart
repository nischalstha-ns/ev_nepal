import 'package:flutter/material.dart';
import 'manage_chargers_screen.dart';

class ChargerFleetTab extends StatelessWidget {
  final String stationId;
  const ChargerFleetTab({super.key, required this.stationId});

  @override
  Widget build(BuildContext context) {
    return const ManageChargersScreen();
  }
}
