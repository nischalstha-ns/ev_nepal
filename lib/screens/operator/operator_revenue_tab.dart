import 'package:flutter/material.dart';
import 'operator_revenue_analytics.dart';

class OperatorRevenueTab extends StatelessWidget {
  final String stationId;
  const OperatorRevenueTab({super.key, required this.stationId});

  @override
  Widget build(BuildContext context) {
    return const OperatorRevenueAnalytics();
  }
}
