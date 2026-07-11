import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class CctvSurveillanceScreen extends StatefulWidget {
  const CctvSurveillanceScreen({super.key});

  @override
  State<CctvSurveillanceScreen> createState() => _CctvSurveillanceScreenState();
}

class _CctvSurveillanceScreenState extends State<CctvSurveillanceScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCameraGrid(),
                    const SizedBox(height: 20),
                    _buildVehicleDetections(),
                    const SizedBox(height: 20),
                    _buildAiAlerts(),
                    const SizedBox(height: 20),
                    _buildStationZones(),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        border: Border(
          bottom: BorderSide(
            color: AppColors.outlineVariant.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.security,
            color: AppColors.primary,
            size: 28,
          ),
          const SizedBox(width: 12),
          const Text(
            'AI Surveillance',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.success.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.success,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                const Text(
                  '4 Cameras Online',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.success,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCameraGrid() {
    final cameras = [
      {'id': '01', 'name': 'Entry Gate'},
      {'id': '02', 'name': 'Charging Bay A'},
      {'id': '03', 'name': 'Charging Bay B'},
      {'id': '04', 'name': 'Exit Gate'},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.1,
      ),
      itemCount: cameras.length,
      itemBuilder: (context, index) {
        return _buildCameraCard(
          cameras[index]['id']!,
          cameras[index]['name']!,
        );
      },
    );
  }

  Widget _buildCameraCard(String id, String name) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    const Icon(
                      Icons.fiber_manual_record,
                      size: 8,
                      color: AppColors.danger,
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      'LIVE',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppColors.danger,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.fiber_manual_record,
                      size: 16,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Center(
                  child: Icon(
                    Icons.videocam,
                    size: 48,
                    color: Colors.white.withValues(alpha: 0.3),
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.3),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'CAM $id - $name',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _getCurrentTime(),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w400,
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleDetections() {
    final detections = [
      {
        'time': '11:42 AM',
        'plate': 'BA 1 JA 2345',
        'status': 'Verified',
        'statusColor': AppColors.success,
        'camera': 'CAM 01',
      },
      {
        'time': '11:38 AM',
        'plate': 'BA 2 KHA 7891',
        'status': 'Reserved',
        'statusColor': const Color(0xFF3B82F6),
        'camera': 'CAM 01',
      },
      {
        'time': '11:25 AM',
        'plate': 'BA 5 PA 9988',
        'status': 'Verified',
        'statusColor': AppColors.success,
        'camera': 'CAM 01',
      },
      {
        'time': '11:15 AM',
        'plate': 'GA 1 KA 5566',
        'status': 'New Vehicle',
        'statusColor': AppColors.warning,
        'camera': 'CAM 01',
      },
      {
        'time': '11:02 AM',
        'plate': 'BA 3 GA 1122',
        'status': 'Unauthorized',
        'statusColor': AppColors.danger,
        'camera': 'CAM 04',
      },
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(
                  Icons.camera_alt,
                  color: AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Vehicle Detections',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurface,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    '12 today',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            itemCount: detections.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final detection = detections[index];
              return _buildDetectionRow(
                detection['time'] as String,
                detection['plate'] as String,
                detection['status'] as String,
                detection['statusColor'] as Color,
                detection['camera'] as String,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDetectionRow(
    String time,
    String plate,
    String status,
    Color statusColor,
    String camera,
  ) {
    return Row(
      children: [
        Container(
          width: 60,
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Text(
            time,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainer,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: AppColors.outlineVariant.withValues(alpha: 0.5),
              width: 1,
            ),
          ),
          child: Text(
            plate,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
              fontFamily: 'monospace',
              letterSpacing: 0.5,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: statusColor.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (status == 'Verified')
                      Icon(
                        Icons.check_circle,
                        size: 11,
                        color: statusColor,
                      ),
                    if (status == 'Verified') const SizedBox(width: 4),
                    Text(
                      status,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Text(
          camera,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: AppColors.onSurfaceVariant.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildAiAlerts() {
    final alerts = [
      {
        'icon': Icons.warning_amber,
        'message': 'Unauthorized vehicle detected in Reserved Bay 04',
        'time': '2 min ago',
        'priority': 'High',
        'color': AppColors.danger,
      },
      {
        'icon': Icons.check_circle,
        'message': 'Vehicle BA 1 JA 2345 matched with reservation #R-4521',
        'time': '5 min ago',
        'priority': 'Info',
        'color': AppColors.success,
      },
      {
        'icon': Icons.warning_amber,
        'message': 'Queue area approaching capacity (8/10)',
        'time': '12 min ago',
        'priority': 'Medium',
        'color': AppColors.warning,
      },
      {
        'icon': Icons.check_circle,
        'message': 'Vehicle BA 5 PA 9988 verified via ANPR',
        'time': '15 min ago',
        'priority': 'Info',
        'color': AppColors.success,
      },
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  Icons.notifications_active,
                  color: AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Text(
                  'AI Alerts',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurface,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            itemCount: alerts.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final alert = alerts[index];
              return _buildAlertRow(
                alert['icon'] as IconData,
                alert['message'] as String,
                alert['time'] as String,
                alert['priority'] as String,
                alert['color'] as Color,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAlertRow(
    IconData icon,
    String message,
    String time,
    String priority,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: color,
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      time,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w400,
                        color: AppColors.onSurfaceVariant.withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 3,
                      height: 3,
                      decoration: BoxDecoration(
                        color: AppColors.onSurfaceVariant.withValues(alpha: 0.5),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      priority,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStationZones() {
    final zones = [
      {
        'name': 'Entry Gate',
        'status': 'Active',
        'color': AppColors.success,
      },
      {
        'name': 'Charging Bay A',
        'status': '3/6 occupied',
        'color': AppColors.warning,
      },
      {
        'name': 'Charging Bay B',
        'status': '2/6 occupied',
        'color': const Color(0xFF3B82F6),
      },
      {
        'name': 'Waiting Area',
        'status': '3 vehicles',
        'color': AppColors.warning,
      },
      {
        'name': 'Exit Gate',
        'status': 'Active',
        'color': AppColors.success,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            'Station Zones',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.onSurface,
            ),
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            children: zones.map((zone) {
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: _buildZoneChip(
                  zone['name'] as String,
                  zone['status'] as String,
                  zone['color'] as Color,
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildZoneChip(String name, String status, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                status,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getCurrentTime() {
    final now = DateTime.now();
    final hour = now.hour % 12 == 0 ? 12 : now.hour % 12;
    final minute = now.minute.toString().padLeft(2, '0');
    final second = now.second.toString().padLeft(2, '0');
    final period = now.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute:$second $period';
  }
}
