import 'package:flutter/material.dart';
import '../../models/station_model.dart';
import '../../models/charger_model.dart';
import '../../models/booking_model.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/branded_app_bar.dart';

class BookingScreen extends StatefulWidget {
  final Station station;
  final Charger charger;

  const BookingScreen({super.key, required this.station, required this.charger});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  int _targetPercent = 80;
  bool _loading = false;

  double get _estimatedCost {
    const batteryKwh = 30.0;
    final kwNeeded = batteryKwh * _targetPercent / 100;
    return kwNeeded * widget.charger.pricePerKwh;
  }

  Future<void> _confirmBooking() async {
    setState(() => _loading = true);
    try {
      final uid = AuthService.currentUserId ?? '';
      final data = await ApiService.createBooking(
        stationId: widget.station.id,
        chargerId: widget.charger.id,
        targetPercent: _targetPercent,
        chargingOption: '$_targetPercent%',
        estimatedCost: _estimatedCost,
        userId: uid,
      );
      if (!mounted) return;
      Navigator.pushReplacementNamed(
        context,
        '/user/qr',
        arguments: {'booking': Booking.fromJson(data)},
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: AppColors.danger),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const BrandedAppBar(title: 'Book Charger', showBackButton: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Station', style: Theme.of(context).textTheme.bodyMedium),
                    Text(widget.station.name, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Text('Charger', style: Theme.of(context).textTheme.bodyMedium),
                    Text(
                      '${widget.charger.name} • ${widget.charger.chargerType} ${widget.charger.powerKw.toInt()} kW',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text('Target Charge Level', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            Row(
              children: [50, 80, 100].map((p) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: _PercentButton(
                    percent: p,
                    selected: _targetPercent == p,
                    onTap: () => setState(() => _targetPercent = p),
                  ),
                ),
              )).toList(),
            ),
            const SizedBox(height: 8),
            Slider(
              value: _targetPercent.toDouble(),
              min: 10,
              max: 100,
              divisions: 9,
              label: '$_targetPercent%',
              activeColor: AppColors.primaryGreen,
              onChanged: (v) => setState(() => _targetPercent = v.round()),
            ),
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _CostRow(label: 'Charging to', value: '$_targetPercent%'),
                    _CostRow(label: 'Price per kWh', value: 'Rs. ${widget.charger.pricePerKwh.toInt()}'),
                    const Divider(),
                    _CostRow(
                      label: 'Estimated Cost',
                      value: 'Rs. ${_estimatedCost.toStringAsFixed(0)}',
                      bold: true,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.account_balance_wallet, size: 16, color: AppColors.success),
                          SizedBox(width: 6),
                          Text('Payment: EV Wallet Demo', style: TextStyle(color: AppColors.success, fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            PrimaryButton(
              label: 'Confirm Booking & Pay',
              icon: Icons.electric_bolt,
              isLoading: _loading,
              onPressed: _confirmBooking,
            ),
          ],
        ),
      ),
    );
  }
}

class _PercentButton extends StatelessWidget {
  final int percent;
  final bool selected;
  final VoidCallback onTap;

  const _PercentButton({required this.percent, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryGreen : AppColors.cardWhite,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppColors.primaryGreen : Colors.grey.shade300,
          ),
        ),
        child: Center(
          child: Text(
            '$percent%',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: selected ? Colors.white : AppColors.darkText,
            ),
          ),
        ),
      ),
    );
  }
}

class _CostRow extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;

  const _CostRow({required this.label, required this.value, this.bold = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          Text(
            value,
            style: TextStyle(
              fontWeight: bold ? FontWeight.bold : FontWeight.w500,
              fontSize: bold ? 16 : 14,
              color: bold ? AppColors.primaryGreen : AppColors.darkText,
            ),
          ),
        ],
      ),
    );
  }
}
