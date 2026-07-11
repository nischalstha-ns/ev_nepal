import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../services/realtime_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/branded_app_bar.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/shimmer_card.dart';

class QueueManagementScreen extends StatefulWidget {
  final String stationId;
  const QueueManagementScreen({super.key, required this.stationId});

  @override
  State<QueueManagementScreen> createState() => _QueueManagementScreenState();
}

class _QueueManagementScreenState extends State<QueueManagementScreen> {
  String get _stationId => widget.stationId;

  List<dynamic> _chargers = [];
  String? _selectedChargerId;
  bool _loadingChargers = true;

  @override
  void initState() {
    super.initState();
    _loadChargers();
  }

  Future<void> _loadChargers() async {
    try {
      final result = await ApiService.getChargers(_stationId);
      if (mounted) {
        setState(() {
          _chargers = result;
          _loadingChargers = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loadingChargers = false);
    }
  }

  Future<void> _callNext(String entryId) async {
    try {
      await ApiService.callNextInQueue(entryId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Next user called'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const BrandedAppBar(title: 'Queue Management', showBackButton: true),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Charger selector
            if (_loadingChargers)
              const LinearProgressIndicator()
            else
              DropdownButtonFormField<String>(
                initialValue: _selectedChargerId,
                decoration: InputDecoration(
                  labelText: 'Select Charger',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: AppColors.surfaceContainer,
                ),
                hint: const Text('Choose a charger to view its queue'),
                items: _chargers.map((c) {
                  final id = c['id'] as String;
                  final name = c['name'] as String? ?? id;
                  final status = c['status'] as String? ?? 'unknown';
                  return DropdownMenuItem<String>(
                    value: id,
                    child: Text('$name — $status'),
                  );
                }).toList(),
                onChanged: (val) => setState(() => _selectedChargerId = val),
              ),

            const SizedBox(height: 16),

            // Queue list
            Expanded(
              child: _selectedChargerId == null
                  ? _EmptyPlaceholder(
                      icon: Icons.queue,
                      message: 'Select a charger above\nto view its queue',
                    )
                  : StreamBuilder<List<Map<String, dynamic>>>(
                      stream: RealtimeService.watchQueues(_selectedChargerId!),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const ShimmerList(count: 3);
                        }
                        final entries = snapshot.data ?? [];
                        if (entries.isEmpty) {
                          return _EmptyPlaceholder(
                            icon: Icons.queue,
                            message: 'No one in queue',
                          );
                        }

                        // Find first waiting entry for "Call Next" button
                        final firstWaiting = entries
                            .where((e) => e['status'] == 'waiting')
                            .toList();
                        final firstWaitingId = firstWaiting.isNotEmpty
                            ? firstWaiting.first['id'] as String
                            : null;

                        return RefreshIndicator(
                          onRefresh: () async {
                            // StreamBuilder auto-refreshes; manual trigger is a no-op
                          },
                          child: ListView.builder(
                            itemCount: entries.length,
                            itemBuilder: (_, i) {
                              final entry = entries[i];
                              final entryId = entry['id'] as String;
                              final position = entry['position'] as int? ?? i + 1;
                              final status = entry['status'] as String? ?? 'waiting';
                              final userId = entry['user_id'] as String? ?? '---';
                              final shortUser = userId.length >= 8
                                  ? userId.substring(0, 8)
                                  : userId;
                              final estWait = position * 30;
                              final isFirstWaiting = entryId == firstWaitingId;

                              StatusBadge badge;
                              if (status == 'called') {
                                badge = StatusBadge.online('Called');
                              } else if (status == 'waiting') {
                                badge = StatusBadge.warning('Waiting');
                              } else {
                                badge = StatusBadge.info(status);
                              }

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: SurfaceCard(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 18,
                                        backgroundColor: AppColors.primaryContainer,
                                        child: Text(
                                          '$position',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.primary,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'User #$shortUser',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 14,
                                                color: AppColors.onSurface,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              'Est. wait: $estWait min',
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: AppColors.onSurfaceVariant,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      badge,
                                      if (isFirstWaiting) ...[
                                        const SizedBox(width: 8),
                                        ElevatedButton(
                                          onPressed: () => _callNext(entryId),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: AppColors.primary,
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 8,
                                            ),
                                            textStyle: const TextStyle(fontSize: 12),
                                          ),
                                          child: const Text('Call Next'),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyPlaceholder extends StatelessWidget {
  final IconData icon;
  final String message;
  const _EmptyPlaceholder({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 56, color: AppColors.outlineVariant),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15,
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
