import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/branded_app_bar.dart';

class UserHistoryTab extends StatefulWidget {
  const UserHistoryTab({super.key});

  @override
  State<UserHistoryTab> createState() => _UserHistoryTabState();
}

class _UserHistoryTabState extends State<UserHistoryTab> {
  int _selectedTab = 0;

  final List<Map<String, dynamic>> _chargingHistory = [
    {
      'sessionId': 'SESS-6671',
      'invoiceNo': 'INV-2024-0891',
      'date': '2024-07-11',
      'time': '14:30',
      'station': 'KTM Central Hub',
      'port': 'Port 02',
      'chargerType': 'CCS2 - 120 kW',
      'vehicle': 'BA 1 JA 2345',
      'startTime': '13:45',
      'endTime': '14:30',
      'duration': '45 min',
      'energyKwh': 38.2,
      'ratePerKwh': 50.0,
      'energyCost': 1910.0,
      'serviceCharge': 50.0,
      'parkingCharge': 0.0,
      'vat': 254.8,
      'totalAmount': 2214.8,
      'paymentMethod': 'Digital Wallet',
      'paymentIcon': Icons.account_balance_wallet,
      'transactionId': 'TXN-KTM-89214',
      'status': 'paid',
    },
    {
      'sessionId': 'SESS-6668',
      'invoiceNo': 'INV-2024-0888',
      'date': '2024-07-10',
      'time': '11:15',
      'station': 'Pokhara Highway',
      'port': 'Port 05',
      'chargerType': 'CHAdeMO - 60 kW',
      'vehicle': 'BA 1 JA 2345',
      'startTime': '10:20',
      'endTime': '11:15',
      'duration': '55 min',
      'energyKwh': 44.1,
      'ratePerKwh': 50.0,
      'energyCost': 2205.0,
      'serviceCharge': 50.0,
      'parkingCharge': 0.0,
      'vat': 293.2,
      'totalAmount': 2548.2,
      'paymentMethod': 'QR Payment',
      'paymentIcon': Icons.qr_code_2,
      'transactionId': 'TXN-PKR-78542',
      'status': 'paid',
    },
    {
      'sessionId': 'SESS-6665',
      'invoiceNo': 'INV-2024-0885',
      'date': '2024-07-09',
      'time': '16:45',
      'station': 'Bhaktapur Mall',
      'port': 'Port 01',
      'chargerType': 'AC Type 2 - 22 kW',
      'vehicle': 'BA 1 JA 2345',
      'startTime': '14:25',
      'endTime': '16:45',
      'duration': '2h 20min',
      'energyKwh': 42.8,
      'ratePerKwh': 45.0,
      'energyCost': 1926.0,
      'serviceCharge': 50.0,
      'parkingCharge': 100.0,
      'vat': 269.9,
      'totalAmount': 2345.9,
      'paymentMethod': 'Credit Card',
      'paymentIcon': Icons.credit_card,
      'transactionId': 'TXN-BKT-65231',
      'status': 'paid',
    },
    {
      'sessionId': 'SESS-6660',
      'invoiceNo': 'INV-2024-0880',
      'date': '2024-07-08',
      'time': '09:30',
      'station': 'Lalitpur Station',
      'port': 'Port 03',
      'chargerType': 'CCS2 - 150 kW',
      'vehicle': 'BA 1 JA 2345',
      'startTime': '09:00',
      'endTime': '09:30',
      'duration': '30 min',
      'energyKwh': 52.6,
      'ratePerKwh': 55.0,
      'energyCost': 2893.0,
      'serviceCharge': 50.0,
      'parkingCharge': 0.0,
      'vat': 382.6,
      'totalAmount': 3325.6,
      'paymentMethod': 'RFID Card',
      'paymentIcon': Icons.nfc,
      'transactionId': 'TXN-LTP-43218',
      'status': 'paid',
    },
    {
      'sessionId': 'SESS-6655',
      'invoiceNo': 'INV-2024-0875',
      'date': '2024-07-07',
      'time': '19:10',
      'station': 'Highway Oasis',
      'port': 'Port 08',
      'chargerType': 'CCS2 - 120 kW',
      'vehicle': 'BA 1 JA 2345',
      'startTime': '18:35',
      'endTime': '19:10',
      'duration': '35 min',
      'energyKwh': 28.4,
      'ratePerKwh': 50.0,
      'energyCost': 1420.0,
      'serviceCharge': 50.0,
      'parkingCharge': 0.0,
      'vat': 191.1,
      'totalAmount': 1661.1,
      'paymentMethod': 'Mobile Banking',
      'paymentIcon': Icons.phone_android,
      'transactionId': 'TXN-HWY-91247',
      'status': 'paid',
    },
  ];

  double get _totalEnergy =>
      _chargingHistory.fold(0.0, (s, e) => s + (e['energyKwh'] as double));
  double get _totalSpent =>
      _chargingHistory.fold(0.0, (s, e) => s + (e['totalAmount'] as double));
  int get _totalSessions => _chargingHistory.length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),
      appBar: BrandedAppBar(
        title: 'Charging History',
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {},
            tooltip: 'Filter',
          ),
        ],
      ),
      body: Column(
        children: [
          // Summary Stats
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(child: _buildStatCard('Total Energy', '${_totalEnergy.toStringAsFixed(1)} kWh', Icons.bolt, AppColors.primary)),
                    const SizedBox(width: 10),
                    Expanded(child: _buildStatCard('Total Spent', 'NPR ${_totalSpent.toStringAsFixed(0)}', Icons.account_balance_wallet, AppColors.success)),
                    const SizedBox(width: 10),
                    Expanded(child: _buildStatCard('Sessions', '$_totalSessions', Icons.ev_station, const Color(0xFF3B82F6))),
                  ],
                ),
                const SizedBox(height: 16),
                // Tab Selector
                Row(
                  children: [
                    _buildTabPill('All Sessions', 0),
                    const SizedBox(width: 8),
                    _buildTabPill('Invoices', 1),
                  ],
                ),
              ],
            ),
          ),

          // History List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _chargingHistory.length,
              itemBuilder: (context, index) {
                final session = _chargingHistory[index];
                return _buildSessionCard(session);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: color,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(fontSize: 10, color: Color(0xFF6B7280)),
          ),
        ],
      ),
    );
  }

  Widget _buildTabPill(String label, int index) {
    final isSelected = _selectedTab == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : const Color(0xFFE5E7EB),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : const Color(0xFF6B7280),
          ),
        ),
      ),
    );
  }

  Widget _buildSessionCard(Map<String, dynamic> session) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Main Info
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.ev_station, color: AppColors.primary, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            session['station'] as String,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1A1A1A),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${session['port']} • ${session['chargerType']}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'NPR ${(session['totalAmount'] as double).toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1A1A1A),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.success.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'Paid ✓',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: AppColors.success,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Details row
                Row(
                  children: [
                    _buildDetailChip(Icons.bolt, '${(session['energyKwh'] as double).toStringAsFixed(1)} kWh'),
                    const SizedBox(width: 12),
                    _buildDetailChip(Icons.timer_outlined, session['duration'] as String),
                    const SizedBox(width: 12),
                    _buildDetailChip(Icons.calendar_today, session['date'] as String),
                  ],
                ),
                const SizedBox(height: 10),
                // Payment & Invoice row
                Row(
                  children: [
                    Icon(session['paymentIcon'] as IconData, size: 14, color: const Color(0xFF6B7280)),
                    const SizedBox(width: 4),
                    Text(
                      session['paymentMethod'] as String,
                      style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
                    ),
                    const Spacer(),
                    Text(
                      session['invoiceNo'] as String,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF3B82F6),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Action buttons
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: const BoxDecoration(
              color: Color(0xFFF9FAFB),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(14),
                bottomRight: Radius.circular(14),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => _showInvoice(session),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.receipt_long, size: 16, color: AppColors.primary),
                        SizedBox(width: 6),
                        Text(
                          'View Invoice',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(width: 1, height: 20, color: const Color(0xFFE5E7EB)),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Downloading invoice PDF...'),
                          backgroundColor: AppColors.primary,
                        ),
                      );
                    },
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.download, size: 16, color: Color(0xFF6B7280)),
                        SizedBox(width: 6),
                        Text(
                          'Download PDF',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailChip(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: const Color(0xFF9CA3AF)),
        const SizedBox(width: 3),
        Text(
          text,
          style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
        ),
      ],
    );
  }

  void _showInvoice(Map<String, dynamic> session) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _InvoiceSheet(session: session),
    );
  }
}

class _InvoiceSheet extends StatelessWidget {
  final Map<String, dynamic> session;
  const _InvoiceSheet({required this.session});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, controller) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: ListView(
          controller: controller,
          padding: const EdgeInsets.all(24),
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Invoice Header
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF2E7D32), Color(0xFF62DF7D)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.receipt_long, color: Colors.white, size: 22),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'EV Charging',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      Text(
                        'EV Charging Invoice',
                        style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'PAID',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: AppColors.success,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 16),

            // Invoice & Transaction IDs
            _buildInfoRow('Invoice No.', session['invoiceNo'] as String),
            _buildInfoRow('Transaction ID', session['transactionId'] as String),
            _buildInfoRow('Session ID', session['sessionId'] as String),
            _buildInfoRow('Date', '${session['date']} at ${session['time']}'),

            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),

            // Customer & Vehicle
            const Text(
              'CUSTOMER & VEHICLE',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Color(0xFF6B7280),
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 10),
            _buildInfoRow('Vehicle', session['vehicle'] as String),
            _buildInfoRow('Station', session['station'] as String),
            _buildInfoRow('Port', session['port'] as String),
            _buildInfoRow('Charger Type', session['chargerType'] as String),

            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),

            // Charging Details
            const Text(
              'CHARGING DETAILS',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Color(0xFF6B7280),
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 10),
            _buildInfoRow('Start Time', session['startTime'] as String),
            _buildInfoRow('End Time', session['endTime'] as String),
            _buildInfoRow('Duration', session['duration'] as String),
            _buildInfoRow('Energy Delivered', '${(session['energyKwh'] as double).toStringAsFixed(1)} kWh'),
            _buildInfoRow('Rate', 'NPR ${(session['ratePerKwh'] as double).toStringAsFixed(0)}/kWh'),

            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),

            // Cost Breakdown
            const Text(
              'COST BREAKDOWN',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Color(0xFF6B7280),
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 10),
            _buildCostRow('Energy Cost', 'NPR ${(session['energyCost'] as double).toStringAsFixed(0)}'),
            _buildCostRow('Service Charge', 'NPR ${(session['serviceCharge'] as double).toStringAsFixed(0)}'),
            _buildCostRow('Parking Charge', 'NPR ${(session['parkingCharge'] as double).toStringAsFixed(0)}'),
            _buildCostRow('VAT (13%)', 'NPR ${(session['vat'] as double).toStringAsFixed(0)}'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total Amount',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  Text(
                    'NPR ${(session['totalAmount'] as double).toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),

            // Payment Info
            const Text(
              'PAYMENT INFORMATION',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Color(0xFF6B7280),
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 10),
            _buildInfoRow('Method', session['paymentMethod'] as String),
            _buildInfoRow('Transaction ID', session['transactionId'] as String),
            _buildInfoRow('Status', 'Payment Successful'),

            const SizedBox(height: 24),

            // Footer
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Column(
                children: [
                  Text(
                    'Thank you for choosing EV Charging',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'For support: support@evcharging.com.np | +977-1-4400231',
                    style: TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Downloading invoice PDF...'),
                          backgroundColor: AppColors.primary,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    icon: const Icon(Icons.download, size: 18),
                    label: const Text('Download PDF', style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Invoice sent to email'),
                          backgroundColor: AppColors.success,
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    icon: const Icon(Icons.email_outlined, size: 18),
                    label: const Text('Send Email', style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
          ),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A1A),
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCostRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A1A),
            ),
          ),
        ],
      ),
    );
  }
}
