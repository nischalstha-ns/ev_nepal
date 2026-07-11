import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/branded_app_bar.dart';

class StationApprovalScreen extends StatefulWidget {
  const StationApprovalScreen({super.key});

  @override
  State<StationApprovalScreen> createState() => _StationApprovalScreenState();
}

class _StationApprovalScreenState extends State<StationApprovalScreen> {
  List<dynamic> _stations = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final data = await ApiService.getAllStationsAdmin();
      setState(() { _stations = data; _loading = false; });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  Future<void> _approve(String id) async {
    try {
      await ApiService.approveStation(id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Station approved'), backgroundColor: AppColors.success),
      );
      _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: AppColors.danger),
      );
    }
  }

  Future<void> _reject(String id) async {
    final reasonCtrl = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reject Station'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Please provide a reason for rejection:'),
            const SizedBox(height: 12),
            TextField(
              controller: reasonCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'e.g. Incomplete information, invalid coordinates...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await ApiService.rejectStationWithReason(id, reasonCtrl.text.trim());
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Station rejected')),
      );
      _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: AppColors.danger),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const BrandedAppBar(title: 'Station Approvals', showBackButton: true),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _stations.length,
                itemBuilder: (_, i) {
                  final s = _stations[i];
                  final approved = s['is_approved'] == true;
                  final rejected = s['rejection_reason'] != null &&
                      (s['rejection_reason'] as String).isNotEmpty;
                  final owner = s['users'] as Map<String, dynamic>?;
                  final chargerCount = (s['chargers'] as List?)?.length ?? 0;
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(s['name'] ?? '', style: Theme.of(context).textTheme.titleMedium),
                                    Text('${s['address']}, ${s['city']}', style: Theme.of(context).textTheme.bodyMedium),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: approved
                                      ? AppColors.success.withValues(alpha: 0.1)
                                      : rejected
                                          ? AppColors.danger.withValues(alpha: 0.1)
                                          : AppColors.warning.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  approved ? 'Approved' : rejected ? 'Rejected' : 'Pending',
                                  style: TextStyle(
                                    color: approved
                                        ? AppColors.success
                                        : rejected
                                            ? AppColors.danger
                                            : AppColors.warning,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          if (owner != null)
                            Text('Owner: ${owner['full_name'] ?? ''} · ${owner['email'] ?? ''}',
                                style: Theme.of(context).textTheme.bodySmall),
                          if (chargerCount > 0)
                            Text('Chargers: $chargerCount',
                                style: Theme.of(context).textTheme.bodySmall),
                          if (s['description'] != null &&
                              (s['description'] as String).isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(s['description'] as String,
                                  style: Theme.of(context).textTheme.bodySmall,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis),
                            ),
                          if (rejected) ...[
                            const SizedBox(height: 6),
                            Text('Reason: ${s['rejection_reason']}',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.danger)),
                          ],
                          if (!approved && !rejected) ...[
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () => _approve(s['id']),
                                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
                                    child: const Text('Approve'),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () => _reject(s['id']),
                                    style: OutlinedButton.styleFrom(foregroundColor: AppColors.danger),
                                    child: const Text('Reject'),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
