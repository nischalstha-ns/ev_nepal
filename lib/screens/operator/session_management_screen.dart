import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class SessionManagementScreen extends StatefulWidget {
  const SessionManagementScreen({super.key});

  @override
  State<SessionManagementScreen> createState() =>
      _SessionManagementScreenState();
}

class _SessionManagementScreenState extends State<SessionManagementScreen> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 16),
            _buildTabSelector(),
            const SizedBox(height: 16),
            Expanded(
              child: _selectedTab == 0
                  ? _buildActiveSessionsTab()
                  : _buildCompletedSessionsTab(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Sessions',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0D1C2F),
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.filter_list_rounded),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(
              child: _buildTabButton('Active Sessions', 0),
            ),
            Expanded(
              child: _buildTabButton('Completed', 1),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton(String label, int index) {
    final isSelected = _selectedTab == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : const Color(0xFF6E7B6C),
          ),
        ),
      ),
    );
  }

  Widget _buildActiveSessionsTab() {
    final sessions = [
      _ActiveSession(
        sessionId: 'SESS-6672',
        vehiclePlate: 'BA 1 JA 2345',
        port: 'Port 02',
        chargerType: 'CCS2 120kW',
        startTime: '10:45',
        duration: '57min',
        energyDelivered: 34.5,
        currentPower: 89,
        progress: 0.72,
        estimatedCompletion: '11:15',
        runningCost: 1725,
      ),
      _ActiveSession(
        sessionId: 'SESS-6673',
        vehiclePlate: 'BA 2 KHA 7891',
        port: 'Port 03',
        chargerType: 'CHAdeMO 60kW',
        startTime: '11:02',
        duration: '40min',
        energyDelivered: 18.2,
        currentPower: 42,
        progress: 0.45,
        estimatedCompletion: '11:48',
        runningCost: 910,
      ),
      _ActiveSession(
        sessionId: 'SESS-6674',
        vehiclePlate: 'BA 3 GA 1122',
        port: 'Port 05',
        chargerType: 'AC 22kW',
        startTime: '09:30',
        duration: '2h 12min',
        energyDelivered: 42.8,
        currentPower: 19,
        progress: 0.82,
        estimatedCompletion: '12:00',
        runningCost: 2140,
      ),
      _ActiveSession(
        sessionId: 'SESS-6675',
        vehiclePlate: 'BA 5 PA 9988',
        port: 'Port 08',
        chargerType: 'CCS2 150kW',
        startTime: '11:15',
        duration: '27min',
        energyDelivered: 22.1,
        currentPower: 132,
        progress: 0.28,
        estimatedCompletion: '12:10',
        runningCost: 1105,
      ),
    ];

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      itemCount: sessions.length,
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: _buildActiveSessionCard(sessions[index]),
      ),
    );
  }

  Widget _buildActiveSessionCard(_ActiveSession session) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    session.sessionId,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0D1C2F),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.directions_car_rounded,
                        size: 14,
                        color: AppColors.outline,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        session.vehiclePlate,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.outline,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
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
                    const Text(
                      'Charging',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF007233),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildInfoChip(
                  Icons.ev_station_rounded,
                  '${session.port} ${session.chargerType}',
                ),
              ),
              const SizedBox(width: 8),
              _buildInfoChip(Icons.access_time_rounded, session.duration),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildMetric(
                  'Energy',
                  '${session.energyDelivered.toStringAsFixed(1)} kWh',
                ),
              ),
              Expanded(
                child: _buildMetric(
                  'Power',
                  '${session.currentPower} kW',
                ),
              ),
              Expanded(
                child: _buildMetric(
                  'Started',
                  session.startTime,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Progress',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.outline,
                    ),
                  ),
                  Text(
                    '${(session.progress * 100).toInt()}%',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF007233),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: session.progress,
                  minHeight: 8,
                  backgroundColor: const Color(0xFFE6EEFF),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Running Cost',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.outline,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'NPR ${session.runningCost.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      fontFeatures: [FontFeature.tabularFigures()],
                      color: Color(0xFF0D1C2F),
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Est. completion',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.outline,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    session.estimatedCompletion,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0D1C2F),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.danger,
              side: BorderSide(color: AppColors.danger),
              minimumSize: const Size(double.infinity, 44),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Stop Session'),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletedSessionsTab() {
    final sessions = [
      _CompletedSession(
        sessionId: 'SESS-6671',
        vehiclePlate: 'BA 4 CHA 3344',
        port: 'Port 01',
        duration: '45 min',
        totalKwh: 38.2,
        totalCost: 1910,
        paymentMethod: 'Digital Wallet',
        paymentIcon: Icons.account_balance_wallet_rounded,
        invoiceNumber: 'INV-2024-0891',
      ),
      _CompletedSession(
        sessionId: 'SESS-6670',
        vehiclePlate: 'KO 2 PA 1234',
        port: 'Port 06',
        duration: '1h 20min',
        totalKwh: 52.6,
        totalCost: 2630,
        paymentMethod: 'QR Payment',
        paymentIcon: Icons.qr_code_rounded,
        invoiceNumber: 'INV-2024-0890',
      ),
      _CompletedSession(
        sessionId: 'SESS-6669',
        vehiclePlate: 'BA 1 JA 2345',
        port: 'Port 02',
        duration: '35 min',
        totalKwh: 28.4,
        totalCost: 1420,
        paymentMethod: 'RFID Card',
        paymentIcon: Icons.credit_card_rounded,
        invoiceNumber: 'INV-2024-0889',
      ),
      _CompletedSession(
        sessionId: 'SESS-6668',
        vehiclePlate: 'GA 1 KA 5566',
        port: 'Port 12',
        duration: '55 min',
        totalKwh: 44.1,
        totalCost: 2205,
        paymentMethod: 'Credit Card',
        paymentIcon: Icons.credit_card_rounded,
        invoiceNumber: 'INV-2024-0888',
      ),
      _CompletedSession(
        sessionId: 'SESS-6667',
        vehiclePlate: 'BA 2 KHA 7891',
        port: 'Port 03',
        duration: '40 min',
        totalKwh: 19.8,
        totalCost: 990,
        paymentMethod: 'Mobile Banking',
        paymentIcon: Icons.phone_android_rounded,
        invoiceNumber: 'INV-2024-0887',
      ),
    ];

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      itemCount: sessions.length,
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: _buildCompletedSessionCard(sessions[index]),
      ),
    );
  }

  Widget _buildCompletedSessionCard(_CompletedSession session) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    session.sessionId,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0D1C2F),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.directions_car_rounded,
                        size: 14,
                        color: AppColors.outline,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        session.vehiclePlate,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.outline,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.check_circle_rounded,
                      size: 14,
                      color: AppColors.success,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Paid',
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
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildInfoChip(Icons.ev_station_rounded, session.port),
              ),
              const SizedBox(width: 8),
              _buildInfoChip(Icons.access_time_rounded, session.duration),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildMetric(
                  'Energy',
                  '${session.totalKwh.toStringAsFixed(1)} kWh',
                ),
              ),
              Expanded(
                child: _buildMetric(
                  'Total Cost',
                  'NPR ${session.totalCost}',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Divider(color: AppColors.outlineVariant),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    session.paymentIcon,
                    size: 18,
                    color: AppColors.outline,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    session.paymentMethod,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.outline,
                    ),
                  ),
                ],
              ),
              Text(
                session.invoiceNumber,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.outline,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => _showInvoiceBottomSheet(session),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 44),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('View Invoice'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FF),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: AppColors.outline,
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.onSurface,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetric(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.outline,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF0D1C2F),
          ),
        ),
      ],
    );
  }

  void _showInvoiceBottomSheet(_CompletedSession session) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 8),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(24),
                  child: _buildInvoiceContent(session),
                ),
              ),
              _buildInvoiceActions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInvoiceContent(_CompletedSession session) {
    final energyCost = session.totalCost - 50 - (session.totalCost * 0.13);
    final vat = session.totalCost * 0.13;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.receipt_long_rounded,
                  size: 40,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'EV Charging',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0D1C2F),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                session.invoiceNumber,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.outline,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        _buildInvoiceSection('Customer Information', [
          _buildInvoiceRow('Vehicle', session.vehiclePlate),
          _buildInvoiceRow('Session ID', session.sessionId),
        ]),
        const SizedBox(height: 24),
        _buildInvoiceSection('Station Details', [
          _buildInvoiceRow('Location', 'Ring Road Station, Kathmandu'),
          _buildInvoiceRow('Port', session.port),
        ]),
        const SizedBox(height: 24),
        _buildInvoiceSection('Charging Details', [
          _buildInvoiceRow('Start Time', 'Jul 11, 2026 • 10:30 AM'),
          _buildInvoiceRow('End Time', 'Jul 11, 2026 • 11:15 AM'),
          _buildInvoiceRow('Duration', session.duration),
          _buildInvoiceRow(
              'Energy Delivered', '${session.totalKwh.toStringAsFixed(1)} kWh'),
          _buildInvoiceRow('Rate', 'NPR 50 per kWh'),
        ]),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF8F9FF),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Cost Breakdown',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0D1C2F),
                ),
              ),
              const SizedBox(height: 16),
              _buildCostRow('Energy Cost', energyCost.toStringAsFixed(2)),
              const SizedBox(height: 8),
              _buildCostRow('Service Charge', '50.00'),
              const SizedBox(height: 8),
              _buildCostRow('Parking Fee', '0.00'),
              const SizedBox(height: 8),
              _buildCostRow('VAT (13%)', vat.toStringAsFixed(2)),
              const SizedBox(height: 16),
              Divider(color: AppColors.outlineVariant),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total Amount',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0D1C2F),
                    ),
                  ),
                  Text(
                    'NPR ${session.totalCost.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      fontFeatures: const [FontFeature.tabularFigures()],
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        _buildInvoiceSection('Payment Information', [
          _buildInvoiceRow('Method', session.paymentMethod),
          _buildInvoiceRow('Transaction ID', 'TXN-${session.sessionId}'),
          _buildInvoiceRow('Timestamp', 'Jul 11, 2026 • 11:15 AM'),
          _buildInvoiceRow('Status', 'Completed'),
        ]),
        const SizedBox(height: 32),
        Center(
          child: Text(
            'Thank you for choosing EV Charging',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.outline,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInvoiceSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0D1C2F),
          ),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _buildInvoiceRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.outline,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF0D1C2F),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCostRow(String label, String amount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: AppColors.outline,
          ),
        ),
        Text(
          'NPR $amount',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF0D1C2F),
          ),
        ),
      ],
    );
  }

  Widget _buildInvoiceActions() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: AppColors.outlineVariant),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.download_rounded),
              label: const Text('Download PDF'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: BorderSide(color: AppColors.primary),
                minimumSize: const Size(0, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.email_rounded),
              label: const Text('Send Email'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                minimumSize: const Size(0, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActiveSession {
  final String sessionId;
  final String vehiclePlate;
  final String port;
  final String chargerType;
  final String startTime;
  final String duration;
  final double energyDelivered;
  final int currentPower;
  final double progress;
  final String estimatedCompletion;
  final int runningCost;

  _ActiveSession({
    required this.sessionId,
    required this.vehiclePlate,
    required this.port,
    required this.chargerType,
    required this.startTime,
    required this.duration,
    required this.energyDelivered,
    required this.currentPower,
    required this.progress,
    required this.estimatedCompletion,
    required this.runningCost,
  });
}

class _CompletedSession {
  final String sessionId;
  final String vehiclePlate;
  final String port;
  final String duration;
  final double totalKwh;
  final int totalCost;
  final String paymentMethod;
  final IconData paymentIcon;
  final String invoiceNumber;

  _CompletedSession({
    required this.sessionId,
    required this.vehiclePlate,
    required this.port,
    required this.duration,
    required this.totalKwh,
    required this.totalCost,
    required this.paymentMethod,
    required this.paymentIcon,
    required this.invoiceNumber,
  });
}
