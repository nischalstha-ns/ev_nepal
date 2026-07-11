import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/branded_app_bar.dart';

class OperatorSettingsTab extends StatefulWidget {
  const OperatorSettingsTab({super.key});

  @override
  State<OperatorSettingsTab> createState() => _OperatorSettingsTabState();
}

class _OperatorSettingsTabState extends State<OperatorSettingsTab> {
  int _selectedTab = 0;

  // Profile data
  final _companyNameCtrl = TextEditingController(text: 'Nepal Grid Solutions Pvt. Ltd.');
  final _licenseCtrl = TextEditingController(text: 'REG-992-KTM-2023');
  final _emailCtrl = TextEditingController(text: 'admin@nepalgrid.solutions');
  final _phoneCtrl = TextEditingController(text: '+977-1-4400231');
  final _addressCtrl = TextEditingController(text: 'Level 4, Energy Park Tower,\nMinbhawan, Kathmandu, Nepal');

  // Station Info data
  final _stationNameCtrl = TextEditingController(text: 'KTM Central Hub');
  final _stationLocationCtrl = TextEditingController(text: 'Tripureshwor, Kathmandu');
  final _operatingHoursCtrl = TextEditingController(text: '24/7');
  final _totalChargersCtrl = TextEditingController(text: '12');
  final _fastChargersCtrl = TextEditingController(text: '6');
  final _amenitiesCtrl = TextEditingController(text: 'WiFi, Restroom, Cafe, Parking');

  // Notification settings
  bool _chargingCompleteNotif = true;
  bool _lowBatteryNotif = true;
  bool _maintenanceAlertNotif = true;
  bool _bookingNotif = false;
  bool _revenueReportNotif = true;
  bool _emailNotif = true;
  bool _smsNotif = false;
  bool _pushNotif = true;

  @override
  void dispose() {
    _companyNameCtrl.dispose();
    _licenseCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    _stationNameCtrl.dispose();
    _stationLocationCtrl.dispose();
    _operatingHoursCtrl.dispose();
    _totalChargersCtrl.dispose();
    _fastChargersCtrl.dispose();
    _amenitiesCtrl.dispose();
    super.dispose();
  }

  Future<void> _signOut() async {
    await AuthService.signOut();
    if (mounted) Navigator.pushReplacementNamed(context, '/login');
  }

  void _saveChanges() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Changes saved successfully!'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _downloadBusinessReport() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Downloading business report...'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),
      appBar: const BrandedAppBar(title: 'Settings'),
      body: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Settings',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Manage your account and preferences.',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 16),
                // Tab buttons
                Row(
                  children: [
                    _buildTabButton('Profile', 0),
                    const SizedBox(width: 8),
                    _buildTabButton('Station Info', 1),
                    const SizedBox(width: 8),
                    _buildTabButton('Notification', 2),
                  ],
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  if (_selectedTab == 0) _buildProfileTab(),
                  if (_selectedTab == 1) _buildStationInfoTab(),
                  if (_selectedTab == 2) _buildNotificationTab(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String label, int index) {
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

  Widget _buildProfileTab() {
    return Column(
      children: [
        // Profile Header Card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Column(
            children: [
              // Avatar with verified badge
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.primary, width: 3),
                    ),
                    child: const CircleAvatar(
                      backgroundColor: Color(0xFFE8F5E9),
                      child: Icon(
                        Icons.eco,
                        color: AppColors.success,
                        size: 40,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                'Nepal Grid Solutions',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(height: 4),
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Premium Operator Account',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                  SizedBox(width: 4),
                  Icon(Icons.verified, color: AppColors.success, size: 14),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.verified_user, color: AppColors.success, size: 14),
                    SizedBox(width: 4),
                    Text(
                      'KYC VERIFIED',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.success,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Business Information Card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.business, color: AppColors.primary, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Business Information',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildTextField('COMPANY NAME', _companyNameCtrl),
              const SizedBox(height: 16),
              _buildTextField('LICENSE/REG NUMBER', _licenseCtrl),
              const SizedBox(height: 16),
              _buildTextField('CONTACT EMAIL', _emailCtrl),
              const SizedBox(height: 16),
              _buildTextField('SUPPORT PHONE NUMBER', _phoneCtrl),
              const SizedBox(height: 16),
              _buildTextField('HEADQUARTERS ADDRESS', _addressCtrl, maxLines: 3),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _saveChanges,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  icon: const Icon(Icons.save, size: 18),
                  label: const Text(
                    'Save Changes',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Download Business Report
        InkWell(
          onTap: _downloadBusinessReport,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: const Row(
              children: [
                Icon(Icons.file_download_outlined, color: Color(0xFF6B7280), size: 20),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Download Business Report',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                ),
                Icon(Icons.chevron_right, color: Color(0xFF6B7280), size: 20),
              ],
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Log Out Session
        InkWell(
          onTap: _signOut,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.danger.withValues(alpha: 0.3)),
            ),
            child: const Row(
              children: [
                Icon(Icons.logout, color: AppColors.danger, size: 20),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Log Out Session',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.danger,
                    ),
                  ),
                ),
                Icon(Icons.chevron_right, color: AppColors.danger, size: 20),
              ],
            ),
          ),
        ),

        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildStationInfoTab() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.ev_station, color: AppColors.primary, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Station Details',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildTextField('STATION NAME', _stationNameCtrl),
              const SizedBox(height: 16),
              _buildTextField('LOCATION', _stationLocationCtrl),
              const SizedBox(height: 16),
              _buildTextField('OPERATING HOURS', _operatingHoursCtrl),
              const SizedBox(height: 16),
              _buildTextField('TOTAL CHARGERS', _totalChargersCtrl, keyboardType: TextInputType.number),
              const SizedBox(height: 16),
              _buildTextField('FAST CHARGERS', _fastChargersCtrl, keyboardType: TextInputType.number),
              const SizedBox(height: 16),
              _buildTextField('AMENITIES', _amenitiesCtrl, maxLines: 2),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _saveChanges,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  icon: const Icon(Icons.save, size: 18),
                  label: const Text(
                    'Update Station Info',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildNotificationTab() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.notifications_active, color: AppColors.primary, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Notification Preferences',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Charging Notifications',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF6B7280),
                ),
              ),
              const SizedBox(height: 12),
              _buildSwitchTile(
                'Charging Complete',
                'Get notified when charging session completes',
                _chargingCompleteNotif,
                (v) => setState(() => _chargingCompleteNotif = v),
              ),
              _buildSwitchTile(
                'Low Battery Alert',
                'Receive alerts for chargers with low battery',
                _lowBatteryNotif,
                (v) => setState(() => _lowBatteryNotif = v),
              ),
              const Divider(height: 24),
              const Text(
                'Station Alerts',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF6B7280),
                ),
              ),
              const SizedBox(height: 12),
              _buildSwitchTile(
                'Maintenance Alert',
                'Get notified about maintenance requirements',
                _maintenanceAlertNotif,
                (v) => setState(() => _maintenanceAlertNotif = v),
              ),
              _buildSwitchTile(
                'Booking Notifications',
                'Receive updates about new bookings',
                _bookingNotif,
                (v) => setState(() => _bookingNotif = v),
              ),
              _buildSwitchTile(
                'Revenue Reports',
                'Daily revenue and transaction summaries',
                _revenueReportNotif,
                (v) => setState(() => _revenueReportNotif = v),
              ),
              const Divider(height: 24),
              const Text(
                'Communication Channels',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF6B7280),
                ),
              ),
              const SizedBox(height: 12),
              _buildSwitchTile(
                'Email Notifications',
                'Receive notifications via email',
                _emailNotif,
                (v) => setState(() => _emailNotif = v),
              ),
              _buildSwitchTile(
                'SMS Alerts',
                'Get important alerts via SMS',
                _smsNotif,
                (v) => setState(() => _smsNotif = v),
              ),
              _buildSwitchTile(
                'Push Notifications',
                'Receive push notifications on mobile',
                _pushNotif,
                (v) => setState(() => _pushNotif = v),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: Color(0xFF6B7280),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFF3F4F6),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF1A1A1A),
          ),
        ),
      ],
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF9CA3AF),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}
