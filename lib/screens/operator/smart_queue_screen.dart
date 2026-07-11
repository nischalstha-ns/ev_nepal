import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class SmartQueueScreen extends StatefulWidget {
  const SmartQueueScreen({super.key});

  @override
  State<SmartQueueScreen> createState() => _SmartQueueScreenState();
}

class _SmartQueueScreenState extends State<SmartQueueScreen> {
  final List<QueueItem> _queueItems = [
    QueueItem(
      position: 1,
      plateNumber: 'BA 1 JA 2345',
      priority: QueuePriority.vip,
      arrivalTime: '11:30 AM',
      estimatedWait: '5 min',
      assignedCharger: 'Port 10',
      progress: 0.85,
    ),
    QueueItem(
      position: 2,
      plateNumber: 'BA 2 KHA 7891',
      priority: QueuePriority.reserved,
      arrivalTime: '11:35 AM',
      estimatedWait: '8 min',
      assignedCharger: 'Port 02',
      progress: 0.0,
    ),
    QueueItem(
      position: 3,
      plateNumber: 'GA 1 KA 5566',
      priority: QueuePriority.regular,
      arrivalTime: '11:38 AM',
      estimatedWait: '15 min',
      assignedCharger: null,
      progress: null,
    ),
    QueueItem(
      position: 4,
      plateNumber: 'BA 5 PA 9988',
      priority: QueuePriority.regular,
      arrivalTime: '11:40 AM',
      estimatedWait: '22 min',
      assignedCharger: null,
      progress: null,
    ),
    QueueItem(
      position: 5,
      plateNumber: 'BA 3 GA 1122',
      priority: QueuePriority.regular,
      arrivalTime: '11:42 AM',
      estimatedWait: '28 min',
      assignedCharger: null,
      progress: null,
    ),
    QueueItem(
      position: 6,
      plateNumber: 'KO 1 JA 7788',
      priority: QueuePriority.regular,
      arrivalTime: '11:45 AM',
      estimatedWait: '35 min',
      assignedCharger: null,
      progress: null,
    ),
  ];

  void _callNext() {
    if (_queueItems.isNotEmpty) {
      final nextVehicle = _queueItems.first;
      final charger = nextVehicle.assignedCharger ?? 'next available port';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Calling vehicle ${nextVehicle.plateNumber} to $charger'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),
      body: SafeArea(
        child: Column(
          children: [
            // Custom Header
            _buildHeader(),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Queue Stats Grid
                    _buildQueueStats(),

                    const SizedBox(height: 24),

                    // Priority Legend
                    _buildPriorityLegend(),

                    const SizedBox(height: 24),

                    // Live Queue List
                    Text(
                      'Live Queue',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 12),

                    ..._queueItems.map((item) => _buildQueueCard(item)),

                    const SizedBox(height: 16),

                    // AI Prediction Card
                    _buildAIPredictionCard(),

                    const SizedBox(height: 100), // Space for bottom actions
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildQuickActions(),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Text(
            'Smart Queue',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(width: 12),
          // Live Indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.success.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: AppColors.success,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  'LIVE',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.success,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQueueStats() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard(
          icon: Icons.people_outline,
          value: '6',
          label: 'Waiting',
          color: AppColors.warning,
        ),
        _buildStatCard(
          icon: Icons.schedule,
          value: '18 min',
          label: 'Avg Wait',
          color: AppColors.primary,
        ),
        _buildStatCard(
          icon: Icons.timer_outlined,
          value: '5 min',
          label: 'Next Available',
          color: AppColors.inversePrimary,
        ),
        _buildStatCard(
          icon: Icons.check_circle_outline,
          value: '42',
          label: 'Served Today',
          color: AppColors.success,
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(
            icon,
            color: color,
            size: 28,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPriorityLegend() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Priority Levels',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildPriorityChip('🚨 Emergency', AppColors.danger),
              const SizedBox(width: 8),
              _buildPriorityChip('⭐ VIP/Premium', const Color(0xFFF59E0B)),
              const SizedBox(width: 8),
              _buildPriorityChip('📋 Reserved', const Color(0xFF3B82F6)),
              const SizedBox(width: 8),
              _buildPriorityChip('👤 Regular', AppColors.outline),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPriorityChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
        ),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildQueueCard(QueueItem item) {
    final priorityColor = _getPriorityColor(item.priority);
    final isBeingServed = item.progress != null;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border(
          left: BorderSide(
            color: priorityColor,
            width: 4,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                // Position Number
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: priorityColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${item.position}',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: priorityColor,
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                // Vehicle Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            item.plateNumber,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontFamily: 'monospace',
                              color: AppColors.onSurface,
                            ),
                          ),
                          const SizedBox(width: 8),
                          _buildPriorityBadge(item.priority),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 14,
                            color: AppColors.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Arrived ${item.arrivalTime}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Wait Time
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      item.estimatedWait,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.onSurface,
                      ),
                    ),
                    Text(
                      'wait',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            // Assigned Charger or Status
            if (item.assignedCharger != null) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.electric_bolt,
                    size: 16,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Assigned to ${item.assignedCharger}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                  if (isBeingServed) ...[
                    const SizedBox(width: 8),
                    Expanded(
                      child: LinearProgressIndicator(
                        value: item.progress,
                        backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${(item.progress! * 100).toInt()}%',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ],
              ),
            ] else ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.pending_outlined,
                    size: 16,
                    color: AppColors.outline,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Waiting for charger assignment',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.onSurfaceVariant,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPriorityBadge(QueuePriority priority) {
    final config = _getPriorityConfig(priority);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: config.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: config.color.withValues(alpha: 0.3),
        ),
      ),
      child: Text(
        config.label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.bold,
          color: config.color,
          fontSize: 10,
        ),
      ),
    );
  }

  Widget _buildAIPredictionCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withValues(alpha: 0.05),
            AppColors.inversePrimary.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.2),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Queue Prediction',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          _buildPredictionRow(
            icon: Icons.schedule,
            label: 'Queue will clear by',
            value: '12:45 PM',
          ),
          const SizedBox(height: 12),

          _buildPredictionRow(
            icon: Icons.lightbulb_outline,
            label: 'Recommended action',
            value: 'Open Port 07 from maintenance',
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Icon(
                Icons.analytics_outlined,
                size: 18,
                color: AppColors.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              Text(
                'Confidence: ',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              Text(
                '88%',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.success,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: LinearProgressIndicator(
                  value: 0.88,
                  backgroundColor: AppColors.success.withValues(alpha: 0.1),
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.success),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPredictionRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 18,
          color: AppColors.onSurfaceVariant,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.onSurface,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: _callNext,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.arrow_forward, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Call Next',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: BorderSide(color: AppColors.primary),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Icon(Icons.add, size: 20),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFF59E0B),
                  side: const BorderSide(color: Color(0xFFF59E0B)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Icon(Icons.priority_high, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getPriorityColor(QueuePriority priority) {
    return _getPriorityConfig(priority).color;
  }

  PriorityConfig _getPriorityConfig(QueuePriority priority) {
    switch (priority) {
      case QueuePriority.emergency:
        return PriorityConfig(
          label: 'EMERGENCY',
          color: AppColors.danger,
        );
      case QueuePriority.vip:
        return PriorityConfig(
          label: 'VIP',
          color: const Color(0xFFF59E0B),
        );
      case QueuePriority.reserved:
        return PriorityConfig(
          label: 'RESERVED',
          color: const Color(0xFF3B82F6),
        );
      case QueuePriority.regular:
        return PriorityConfig(
          label: 'REGULAR',
          color: AppColors.outline,
        );
    }
  }
}

// Models
class QueueItem {
  final int position;
  final String plateNumber;
  final QueuePriority priority;
  final String arrivalTime;
  final String estimatedWait;
  final String? assignedCharger;
  final double? progress;

  QueueItem({
    required this.position,
    required this.plateNumber,
    required this.priority,
    required this.arrivalTime,
    required this.estimatedWait,
    this.assignedCharger,
    this.progress,
  });
}

enum QueuePriority {
  emergency,
  vip,
  reserved,
  regular,
}

class PriorityConfig {
  final String label;
  final Color color;

  PriorityConfig({
    required this.label,
    required this.color,
  });
}
