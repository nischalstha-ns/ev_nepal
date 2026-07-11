import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/branded_app_bar.dart';
import '../../widgets/glass_card.dart';

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  final MobileScannerController _controller = MobileScannerController();
  bool _scanned = false;
  bool _loading = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_scanned) return;
    final barcode = capture.barcodes.firstOrNull;
    if (barcode?.rawValue == null) return;

    setState(() { _scanned = true; _loading = true; });
    await _controller.stop();

    final token = barcode!.rawValue!;
    try {
      final booking = await ApiService.getBookingByQrToken(token);
      if (!mounted) return;
      setState(() => _loading = false);

      if (booking == null) {
        _showResultDialog(
          icon: Icons.error_outline,
          color: AppColors.danger,
          title: 'QR Not Found',
          message: 'No booking found for this QR code.',
        );
        return;
      }

      final status = booking['status'] as String? ?? '';
      final userName = booking['users']?['full_name'] ?? 'Unknown';
      final stationName = booking['stations']?['name'] ?? '';
      final chargerName = booking['chargers']?['name'] ?? '';
      final powerKw = booking['chargers']?['power_kw'];

      if (status == 'confirmed') {
        _showBookingDialog(
          bookingId: booking['id'] as String,
          userName: userName,
          stationName: stationName,
          chargerName: chargerName,
          powerKw: powerKw?.toString() ?? '7.4',
          qrToken: token,
        );
      } else if (status == 'charging') {
        _showResultDialog(
          icon: Icons.bolt,
          color: AppColors.primary,
          title: 'Already Charging',
          message: '$userName is currently charging at $chargerName.',
        );
      } else if (status == 'completed') {
        _showResultDialog(
          icon: Icons.check_circle,
          color: AppColors.success,
          title: 'Session Completed',
          message: 'This booking has already been completed.',
        );
      } else {
        _showResultDialog(
          icon: Icons.info_outline,
          color: AppColors.warning,
          title: 'Invalid Booking',
          message: 'Booking status is "$status". Cannot start charging.',
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      _showResultDialog(
        icon: Icons.error_outline,
        color: AppColors.danger,
        title: 'Scan Error',
        message: e.toString(),
      );
    }
  }

  void _showBookingDialog({
    required String bookingId,
    required String userName,
    required String stationName,
    required String chargerName,
    required String powerKw,
    required String qrToken,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.qr_code_scanner,
                  color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 12),
            const Text('Booking Verified'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _InfoRow(label: 'Customer', value: userName),
            const SizedBox(height: 8),
            _InfoRow(label: 'Charger', value: chargerName),
            const SizedBox(height: 8),
            _InfoRow(label: 'Power', value: '$powerKw kW'),
            const SizedBox(height: 8),
            _InfoRow(label: 'Token', value: qrToken),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _resetScan();
            },
            child: const Text('Cancel'),
          ),
          FilledButton.icon(
            onPressed: () async {
              Navigator.pop(ctx);
              await ApiService.startCharging(bookingId);
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Charging started for $userName!'),
                  backgroundColor: AppColors.success,
                ),
              );
              Navigator.pop(context);
            },
            icon: const Icon(Icons.bolt, size: 18),
            label: const Text('Start Charging'),
          ),
        ],
      ),
    );
  }

  void _showResultDialog({
    required IconData icon,
    required Color color,
    required String title,
    required String message,
  }) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 10),
            Text(title),
          ],
        ),
        content: Text(message),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              _resetScan();
            },
            child: const Text('Scan Again'),
          ),
        ],
      ),
    );
  }

  void _resetScan() {
    setState(() => _scanned = false);
    _controller.start();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BrandedAppBar(
        title: 'Scan Booking QR',
        showBackButton: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on_outlined),
            onPressed: _controller.toggleTorch,
            tooltip: 'Toggle torch',
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
          ),
          // Scanning overlay
          Center(
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                border: Border.all(
                  color: _scanned
                      ? AppColors.success
                      : Colors.white.withValues(alpha: 0.8),
                  width: 3,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: SurfaceCard(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: _loading
                    ? const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2)),
                          SizedBox(width: 10),
                          Text('Looking up booking...'),
                        ],
                      )
                    : Text(
                        _scanned ? 'QR detected' : 'Point camera at QR code',
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 14),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 72,
          child: Text(label,
              style: const TextStyle(
                  color: AppColors.onSurfaceVariant, fontSize: 13)),
        ),
        Expanded(
          child: Text(value,
              style: const TextStyle(
                  fontWeight: FontWeight.w600, fontSize: 13)),
        ),
      ],
    );
  }
}
