import 'package:flutter/material.dart';
import '../../models/station_model.dart';
import '../../models/charger_model.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/branded_app_bar.dart';

class QueueScreen extends StatefulWidget {
  final Station station;
  final Charger charger;

  const QueueScreen({super.key, required this.station, required this.charger});

  @override
  State<QueueScreen> createState() => _QueueScreenState();
}

class _QueueScreenState extends State<QueueScreen> {
  Map<String, dynamic>? _queueEntry;
  bool _loading = false;
  bool _joined = false;

  Future<void> _joinQueue() async {
    setState(() => _loading = true);
    try {
      final data = await ApiService.joinQueue(
        stationId: widget.station.id,
        chargerId: widget.charger.id,
        userId: AuthService.currentUserId ?? '',
      );
      setState(() { _queueEntry = data; _joined = true; });
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
      appBar: const BrandedAppBar(title: 'Join Queue', showBackButton: true),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: _joined && _queueEntry != null
            ? _QueueConfirmation(entry: _queueEntry!, onHome: () => Navigator.pushNamedAndRemoveUntil(context, '/user', (_) => false))
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.station.name, style: Theme.of(context).textTheme.titleLarge),
                          const SizedBox(height: 4),
                          Text(widget.charger.name, style: Theme.of(context).textTheme.bodyMedium),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.danger.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text('Charger Occupied', style: TextStyle(color: AppColors.danger, fontSize: 12, fontWeight: FontWeight.w500)),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Center(
                    child: Column(
                      children: [
                        const Icon(Icons.queue, size: 64, color: AppColors.primaryGreen),
                        const SizedBox(height: 16),
                        Text('Join the Waitlist', style: Theme.of(context).textTheme.headlineMedium),
                        const SizedBox(height: 8),
                        Text(
                          'You\'ll be notified when the charger is available',
                          style: Theme.of(context).textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  PrimaryButton(
                    label: 'Join Queue',
                    icon: Icons.add_circle_outline,
                    isLoading: _loading,
                    onPressed: _joinQueue,
                  ),
                ],
              ),
      ),
    );
  }
}

class _QueueConfirmation extends StatelessWidget {
  final Map<String, dynamic> entry;
  final VoidCallback onHome;

  const _QueueConfirmation({required this.entry, required this.onHome});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.primaryGreen.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check_circle, color: AppColors.primaryGreen, size: 64),
        ),
        const SizedBox(height: 24),
        Text('You\'re in the Queue!', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 32),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Text('Queue Position', style: Theme.of(context).textTheme.bodyMedium),
                Text(
                  '#${entry['position']}',
                  style: const TextStyle(fontSize: 56, fontWeight: FontWeight.bold, color: AppColors.primaryGreen),
                ),
                const Divider(),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.timer, color: AppColors.warning, size: 18),
                    const SizedBox(width: 6),
                    Text(
                      'Est. wait: ${entry['estimated_wait_minutes']} minutes',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(onPressed: onHome, child: const Text('Back to Home')),
        ),
      ],
    );
  }
}
