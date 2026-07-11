import 'dart:async';
import 'package:flutter/material.dart';

class LiveStationMonitorScreen extends StatefulWidget {
  const LiveStationMonitorScreen({super.key});

  @override
  State<LiveStationMonitorScreen> createState() =>
      _LiveStationMonitorScreenState();
}

class _LiveStationMonitorScreenState extends State<LiveStationMonitorScreen> {
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FF),
        body: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildStatsBar(),
                    const SizedBox(height: 20),
                    _buildPortGrid(),
                    const SizedBox(height: 20),
                    _buildAIPredictionCard(),
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(
            Icons.monitor_outlined,
            color: Color(0xFF006b2c),
            size: 28,
          ),
          const SizedBox(width: 12),
          const Text(
            'Live Station Monitor',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xFF0D1C2F),
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: () {
              setState(() {});
            },
            icon: const Icon(Icons.refresh),
            color: const Color(0xFF006b2c),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsBar() {
    return Row(
      children: [
        Expanded(
          child: _buildStatChip('Total', '12', Colors.grey),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildStatChip('Available', '4', const Color(0xFF10B981)),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildStatChip('Charging', '5', const Color(0xFFF59E0B)),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildStatChip('Reserved', '2', const Color(0xFF3B82F6)),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildStatChip('Maint.', '1', const Color(0xFFEF4444)),
        ),
      ],
    );
  }

  Widget _buildStatChip(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: const Color(0xFF0D1C2F).withValues(alpha: 0.6),
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildPortGrid() {
    final ports = _getMockPorts();
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.85,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: ports.length,
      itemBuilder: (context, index) => _buildPortCard(ports[index]),
    );
  }

  Widget _buildPortCard(Map<String, dynamic> port) {
    final status = port['status'] as String;
    final statusColor = _getStatusColor(status);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border(
          left: BorderSide(
            color: statusColor,
            width: 4,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Port ${port['number']}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0D1C2F),
                ),
              ),
              const Spacer(),
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: statusColor,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            port['type'],
            style: TextStyle(
              fontSize: 11,
              color: const Color(0xFF0D1C2F).withValues(alpha: 0.6),
            ),
          ),
          Text(
            port['power'],
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF006b2c),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              status,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: statusColor,
              ),
            ),
          ),
          const Spacer(),
          if (status == 'Charging') ...[
            const SizedBox(height: 8),
            Text(
              port['vehicle'],
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Color(0xFF0D1C2F),
              ),
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: port['progress'] / 100,
                backgroundColor: Colors.grey.withValues(alpha: 0.2),
                valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                minHeight: 6,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${port['progress']}%',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF0D1C2F).withValues(alpha: 0.7),
                  ),
                ),
                Text(
                  '${port['timeLeft']} left',
                  style: TextStyle(
                    fontSize: 10,
                    color: const Color(0xFF0D1C2F).withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              '${port['kwhDelivered']} kWh delivered',
              style: TextStyle(
                fontSize: 10,
                color: const Color(0xFF0D1C2F).withValues(alpha: 0.5),
              ),
            ),
          ] else if (status == 'Reserved') ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.person_outline,
                  size: 14,
                  color: statusColor,
                ),
                const SizedBox(width: 4),
                Text(
                  port['reservedBy'],
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0D1C2F),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Arriving in ${port['arrivalTime']}',
              style: TextStyle(
                fontSize: 10,
                color: const Color(0xFF0D1C2F).withValues(alpha: 0.6),
              ),
            ),
          ] else if (status == 'Available') ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.check_circle_outline,
                  size: 14,
                  color: statusColor,
                ),
                const SizedBox(width: 4),
                Text(
                  'Ready for charging',
                  style: TextStyle(
                    fontSize: 11,
                    color: const Color(0xFF0D1C2F).withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ] else if (status == 'Maintenance') ...[
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  size: 14,
                  color: statusColor,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    'Under maintenance\n${port['reason']}',
                    style: TextStyle(
                      fontSize: 10,
                      color: const Color(0xFF0D1C2F).withValues(alpha: 0.6),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAIPredictionCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF006b2c), Color(0xFF00873a)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF006b2c).withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'AI Availability Prediction',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Text(
            '15 min: 6 ports free  |  30 min: 7 ports free  |  60 min: 9 ports free',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.white,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      size: 14,
                      color: Colors.white,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Confidence: 92%',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
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

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Available':
        return const Color(0xFF10B981);
      case 'Charging':
        return const Color(0xFFF59E0B);
      case 'Reserved':
        return const Color(0xFF3B82F6);
      case 'Maintenance':
        return const Color(0xFFEF4444);
      default:
        return Colors.grey;
    }
  }

  List<Map<String, dynamic>> _getMockPorts() {
    return [
      {
        'number': '01',
        'type': 'CCS2',
        'power': '120 kW',
        'status': 'Available',
      },
      {
        'number': '02',
        'type': 'CCS2',
        'power': '120 kW',
        'status': 'Charging',
        'vehicle': 'BA 1 JA 2345',
        'progress': 72,
        'timeLeft': '18 min',
        'kwhDelivered': '34.5',
      },
      {
        'number': '03',
        'type': 'CHAdeMO',
        'power': '60 kW',
        'status': 'Charging',
        'vehicle': 'BA 2 KHA 7891',
        'progress': 45,
        'timeLeft': '35 min',
        'kwhDelivered': '18.2',
      },
      {
        'number': '04',
        'type': 'CCS2',
        'power': '150 kW',
        'status': 'Reserved',
        'reservedBy': 'Arun B.',
        'arrivalTime': '12 min',
      },
      {
        'number': '05',
        'type': 'AC Type 2',
        'power': '22 kW',
        'status': 'Charging',
        'vehicle': 'BA 3 GA 1122',
        'progress': 82,
        'timeLeft': '25 min',
        'kwhDelivered': '42.8',
      },
      {
        'number': '06',
        'type': 'CCS2',
        'power': '60 kW',
        'status': 'Available',
      },
      {
        'number': '07',
        'type': 'CHAdeMO',
        'power': '60 kW',
        'status': 'Maintenance',
        'reason': 'Comm. failure',
      },
      {
        'number': '08',
        'type': 'CCS2',
        'power': '150 kW',
        'status': 'Charging',
        'vehicle': 'BA 5 PA 9988',
        'progress': 28,
        'timeLeft': '55 min',
        'kwhDelivered': '22.1',
      },
      {
        'number': '09',
        'type': 'AC Type 2',
        'power': '22 kW',
        'status': 'Available',
      },
      {
        'number': '10',
        'type': 'CCS2',
        'power': '120 kW',
        'status': 'Charging',
        'vehicle': 'BA 1 CHA 4455',
        'progress': 91,
        'timeLeft': '5 min',
        'kwhDelivered': '48.3',
      },
      {
        'number': '11',
        'type': 'CHAdeMO',
        'power': '60 kW',
        'status': 'Reserved',
        'reservedBy': 'Sunita K.',
        'arrivalTime': '25 min',
      },
      {
        'number': '12',
        'type': 'CCS2',
        'power': '60 kW',
        'status': 'Available',
      },
    ];
  }
}
