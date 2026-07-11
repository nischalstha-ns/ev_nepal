import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/vehicle_model.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/shimmer_card.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  static const _demoUserId = '11111111-1111-1111-1111-111111111111';
  String get _userId => AuthService.currentUserId ?? _demoUserId;

  bool _loading = true;
  Map<String, dynamic>? _profile;
  List<Vehicle> _vehicles = [];
  Map<String, dynamic>? _membership;

  bool _editingProfile = false;
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _bioCtrl = TextEditingController();
  bool _saving = false;
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    _bioCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final results = await Future.wait([
        ApiService.getUserProfile(_userId),
        ApiService.getVehicles(_userId),
        ApiService.getCurrentMembership(_userId),
      ]);
      if (mounted) {
        final profile = results[0] as Map<String, dynamic>?;
        setState(() {
          _profile = profile;
          _vehicles = (results[1] as List)
              .map((e) => Vehicle.fromJson(e as Map<String, dynamic>))
              .toList();
          _membership = results[2] as Map<String, dynamic>?;
          _loading = false;
          if (profile != null) {
            _nameCtrl.text = profile['full_name'] ?? '';
            _emailCtrl.text = profile['email'] ?? '';
            _phoneCtrl.text = profile['phone'] ?? '';
            _addressCtrl.text = profile['address'] ?? '';
            _bioCtrl.text = profile['bio'] ?? '';
          }
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final result = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85,
    );
    if (result != null && mounted) {
      setState(() => _selectedImage = File(result.path));
    }
  }

  Future<void> _saveProfile() async {
    if (_nameCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name is required')),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      String? imageUrl;
      if (_selectedImage != null) {
        imageUrl = 'demo://profile/$_userId.jpg';
      }

      await ApiService.updateUserProfile(
        userId: _userId,
        name: _nameCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
        address: _addressCtrl.text.trim().isEmpty ? null : _addressCtrl.text.trim(),
        bio: _bioCtrl.text.trim().isEmpty ? null : _bioCtrl.text.trim(),
        profileImageUrl: imageUrl,
      );
      if (mounted) {
        setState(() {
          _saving = false;
          _editingProfile = false;
          _selectedImage = null;
          if (_profile != null) {
            _profile!['full_name'] = _nameCtrl.text.trim();
            _profile!['phone'] = _phoneCtrl.text.trim();
            _profile!['address'] = _addressCtrl.text.trim();
            _profile!['bio'] = _bioCtrl.text.trim();
            if (imageUrl != null) _profile!['profile_image_url'] = imageUrl;
          }
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Profile updated'),
              backgroundColor: AppColors.success),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  void _cancelEdit() {
    setState(() {
      _editingProfile = false;
      _selectedImage = null;
      if (_profile != null) {
        _nameCtrl.text = _profile!['full_name'] ?? '';
        _emailCtrl.text = _profile!['email'] ?? '';
        _phoneCtrl.text = _profile!['phone'] ?? '';
        _addressCtrl.text = _profile!['address'] ?? '';
        _bioCtrl.text = _profile!['bio'] ?? '';
      }
    });
  }

  void _showAddVehicleSheet() {
    final modelCtrl = TextEditingController();
    final plateCtrl = TextEditingController();
    final kwhCtrl = TextEditingController(text: '40.5');
    String connector = 'CCS2';
    bool isPrimary = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Add Vehicle',
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 16),
              _SheetField(ctrl: modelCtrl, label: 'Vehicle Model',
                  hint: 'e.g. Tata Nexon EV'),
              const SizedBox(height: 12),
              _SheetField(ctrl: plateCtrl, label: 'Plate Number',
                  hint: 'e.g. BAA 1234 PA'),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: connector,
                      decoration: const InputDecoration(
                          labelText: 'Connector', isDense: true),
                      items: ['CCS2', 'CCS', 'Type2', 'CHAdeMO', 'GB/T']
                          .map((c) => DropdownMenuItem(
                              value: c, child: Text(c)))
                          .toList(),
                      onChanged: (v) =>
                          setSheet(() => connector = v ?? 'CCS2'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _SheetField(
                      ctrl: kwhCtrl,
                      label: 'Battery (kWh)',
                      hint: '40.5',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Set as primary vehicle',
                    style: TextStyle(fontSize: 14)),
                value: isPrimary,
                onChanged: (v) => setSheet(() => isPrimary = v ?? false),
                controlAffinity: ListTileControlAffinity.leading,
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    if (modelCtrl.text.trim().isEmpty) {
                      ScaffoldMessenger.of(ctx).showSnackBar(
                        const SnackBar(content: Text('Enter vehicle model')),
                      );
                      return;
                    }
                    final kwh = double.tryParse(kwhCtrl.text.trim());
                    if (kwh == null || kwh <= 0) {
                      ScaffoldMessenger.of(ctx).showSnackBar(
                        const SnackBar(
                            content: Text('Enter valid battery capacity')),
                      );
                      return;
                    }
                    try {
                      await ApiService.addVehicle(
                        userId: _userId,
                        modelName: modelCtrl.text.trim(),
                        plateNumber: plateCtrl.text.trim().isEmpty
                            ? null
                            : plateCtrl.text.trim(),
                        connectorType: connector,
                        batteryCapacity: kwh,
                        isPrimary: isPrimary,
                      );
                      if (ctx.mounted) {
                        Navigator.pop(ctx);
                      }
                      if (mounted) {
                        _load();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Vehicle added'),
                              backgroundColor: AppColors.success),
                        );
                      }
                    } catch (e) {
                      if (ctx.mounted) {
                        ScaffoldMessenger.of(ctx).showSnackBar(
                          SnackBar(content: Text('Error: $e')),
                        );
                      }
                    }
                  },
                  child: const Text('Add Vehicle'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _signOut() async {
    await AuthService.signOut();
    if (mounted) Navigator.pushReplacementNamed(context, '/login');
  }

  String get _initials {
    final name = _profile?['full_name'] as String? ?? 'U';
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return name.isNotEmpty ? name[0].toUpperCase() : 'U';
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Profile'),
        actions: [
          if (!_editingProfile && !_loading)
            TextButton.icon(
              onPressed: () => setState(() => _editingProfile = true),
              icon: const Icon(Icons.edit_outlined, size: 16),
              label: const Text('Edit'),
            ),
        ],
      ),
      body: _loading
          ? const Padding(
              padding: EdgeInsets.all(16),
              child: ShimmerList(count: 4, itemHeight: 80))
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  SurfaceCard(
                    aiAccent: true,
                    borderAccentColor: AppColors.primary,
                    padding: EdgeInsets.zero,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 4,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [AppColors.primary, Color(0xFF62DF7D)],
                            ),
                            borderRadius: BorderRadius.vertical(
                                top: Radius.circular(12)),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Stack(
                                    children: [
                                      GestureDetector(
                                        onTap: _editingProfile ? _pickImage : null,
                                        child: CircleAvatar(
                                          radius: 45,
                                          backgroundColor: AppColors.secondaryContainer,
                                          backgroundImage: _selectedImage != null
                                              ? FileImage(_selectedImage!)
                                              : (_profile?['profile_image_url'] != null
                                                  ? NetworkImage(_profile!['profile_image_url'])
                                                  : null) as ImageProvider?,
                                          child: (_selectedImage == null && _profile?['profile_image_url'] == null)
                                              ? Text(
                                                  _initials,
                                                  style: const TextStyle(
                                                    fontSize: 28,
                                                    fontWeight: FontWeight.bold,
                                                    color: AppColors.primary,
                                                  ),
                                                )
                                              : null,
                                        ),
                                      ),
                                      if (_editingProfile)
                                        Positioned(
                                          bottom: 0,
                                          right: 0,
                                          child: GestureDetector(
                                            onTap: _pickImage,
                                            child: Container(
                                              width: 32,
                                              height: 32,
                                              decoration: BoxDecoration(
                                                color: AppColors.primary,
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                  color: AppColors.surface,
                                                  width: 2,
                                                ),
                                              ),
                                              child: const Icon(
                                                Icons.camera_alt,
                                                size: 16,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        if (_editingProfile)
                                          Text('Edit Profile',
                                            style: tt.titleLarge?.copyWith(
                                              fontWeight: FontWeight.w700,
                                            ),
                                          )
                                        else ...[
                                          Text(
                                            _profile?['full_name'] ?? 'EV User',
                                            style: tt.titleLarge?.copyWith(
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              Icon(Icons.email_outlined, size: 14, color: AppColors.onSurfaceVariant),
                                              const SizedBox(width: 4),
                                              Expanded(
                                                child: Text(
                                                  _profile?['email'] ?? '',
                                                  style: tt.bodySmall?.copyWith(
                                                      color: AppColors.onSurfaceVariant),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                          if (_profile?['phone'] != null && (_profile!['phone'] as String).isNotEmpty) ...[
                                            const SizedBox(height: 4),
                                            Row(
                                              children: [
                                                Icon(Icons.phone_outlined, size: 14, color: AppColors.onSurfaceVariant),
                                                const SizedBox(width: 4),
                                                Text(
                                                  _profile!['phone'],
                                                  style: tt.bodySmall?.copyWith(
                                                      color: AppColors.onSurfaceVariant),
                                                ),
                                              ],
                                            ),
                                          ],
                                          const SizedBox(height: 6),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                            decoration: BoxDecoration(
                                              color: AppColors.primaryContainer.withValues(alpha: 0.3),
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              (_profile?['tier'] as String?)?.toUpperCase() ?? 'STANDARD',
                                              style: const TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w700,
                                                color: AppColors.primary,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ],
                              ),

                              if (!_editingProfile && (_profile?['address'] != null || _profile?['bio'] != null)) ...[
                                const SizedBox(height: 16),
                                const Divider(),
                                const SizedBox(height: 12),
                              ],

                              if (_editingProfile) ...[
                                const SizedBox(height: 20),
                                _ProfileField(
                                  ctrl: _nameCtrl,
                                  label: 'Full Name',
                                  icon: Icons.person_outline,
                                ),
                                const SizedBox(height: 14),
                                _ProfileField(
                                  ctrl: _emailCtrl,
                                  label: 'Email',
                                  icon: Icons.email_outlined,
                                  readOnly: true,
                                ),
                                const SizedBox(height: 14),
                                _ProfileField(
                                  ctrl: _phoneCtrl,
                                  label: 'Phone Number',
                                  icon: Icons.phone_outlined,
                                  keyboardType: TextInputType.phone,
                                ),
                                const SizedBox(height: 14),
                                _ProfileField(
                                  ctrl: _addressCtrl,
                                  label: 'Address',
                                  icon: Icons.location_on_outlined,
                                  maxLines: 2,
                                  hint: 'Enter your address',
                                ),
                                const SizedBox(height: 14),
                                _ProfileField(
                                  ctrl: _bioCtrl,
                                  label: 'Bio',
                                  icon: Icons.info_outline,
                                  maxLines: 3,
                                  hint: 'Tell us about yourself',
                                ),
                                const SizedBox(height: 20),
                                Row(
                                  children: [
                                    Expanded(
                                      child: OutlinedButton(
                                        onPressed: _saving ? null : _cancelEdit,
                                        child: const Text('Cancel'),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: _saving ? null : _saveProfile,
                                        child: _saving
                                            ? const SizedBox(
                                                width: 20,
                                                height: 20,
                                                child: CircularProgressIndicator(
                                                    strokeWidth: 2,
                                                    color: Colors.white),
                                              )
                                            : const Text('Save'),
                                      ),
                                    ),
                                  ],
                                ),
                              ] else ...[
                                if (_profile?['address'] != null && (_profile!['address'] as String).isNotEmpty)
                                  _ProfileRow(
                                    icon: Icons.location_on_outlined,
                                    label: 'Address',
                                    value: _profile!['address'],
                                  ),
                                if (_profile?['address'] != null && _profile?['bio'] != null &&
                                    (_profile!['address'] as String).isNotEmpty && (_profile!['bio'] as String).isNotEmpty)
                                  const SizedBox(height: 12),
                                if (_profile?['bio'] != null && (_profile!['bio'] as String).isNotEmpty)
                                  _ProfileRow(
                                    icon: Icons.info_outline,
                                    label: 'Bio',
                                    value: _profile!['bio'],
                                  ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  SurfaceCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Membership', style: tt.titleMedium),
                            TextButton(
                              onPressed: () =>
                                  Navigator.pushNamed(context, '/user/membership'),
                              child: const Text('View Plans'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        if (_membership != null) ...[
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.primaryContainer.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  color: AppColors.primary.withValues(alpha: 0.3)),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(Icons.workspace_premium,
                                      color: Colors.white, size: 20),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _membership!['membership_plans']
                                                ['name'] ??
                                            'Plan',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 15),
                                      ),
                                      Text(
                                        'Active',
                                        style: tt.bodySmall?.copyWith(
                                            color: AppColors.success),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(Icons.chevron_right,
                                    color: AppColors.primary),
                              ],
                            ),
                          ),
                        ] else
                          Text(
                            'No active membership',
                            style: tt.bodyMedium
                                ?.copyWith(color: AppColors.onSurfaceVariant),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  SurfaceCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('My Vehicles', style: tt.titleMedium),
                            TextButton.icon(
                              onPressed: _showAddVehicleSheet,
                              icon: const Icon(Icons.add, size: 16),
                              label: const Text('Add'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        if (_vehicles.isEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Text(
                              'No vehicles added yet',
                              style: tt.bodyMedium
                                  ?.copyWith(color: AppColors.onSurfaceVariant),
                            ),
                          )
                        else
                          ..._vehicles.map((v) => _VehicleCard(
                                vehicle: v,
                                onDelete: v.isPrimary
                                    ? null
                                    : () async {
                                        final messenger = ScaffoldMessenger.of(context);
                                        final confirm = await showDialog<bool>(
                                          context: context,
                                          builder: (ctx) => AlertDialog(
                                            title: const Text('Delete Vehicle'),
                                            content: Text(
                                                'Remove ${v.modelName} from your vehicles?'),
                                            actions: [
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.pop(ctx, false),
                                                child: const Text('Cancel'),
                                              ),
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.pop(ctx, true),
                                                style: TextButton.styleFrom(
                                                    foregroundColor:
                                                        AppColors.danger),
                                                child: const Text('Delete'),
                                              ),
                                            ],
                                          ),
                                        );
                                        if (confirm == true && mounted) {
                                          try {
                                            await ApiService.deleteVehicle(v.id);
                                            _load();
                                            if (mounted) {
                                              messenger.showSnackBar(
                                                const SnackBar(
                                                    content:
                                                        Text('Vehicle deleted'),
                                                    backgroundColor:
                                                        AppColors.success),
                                              );
                                            }
                                          } catch (e) {
                                            if (mounted) {
                                              messenger.showSnackBar(
                                                SnackBar(
                                                    content: Text('Error: $e')),
                                              );
                                            }
                                          }
                                        }
                                      },
                              )),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _signOut,
                      icon: const Icon(Icons.logout),
                      label: const Text('Sign Out'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.danger,
                        side: const BorderSide(color: AppColors.danger),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }
}

class _ProfileField extends StatelessWidget {
  final TextEditingController ctrl;
  final String label;
  final IconData icon;
  final bool readOnly;
  final int maxLines;
  final String? hint;
  final TextInputType? keyboardType;

  const _ProfileField({
    required this.ctrl,
    required this.label,
    required this.icon,
    this.readOnly = false,
    this.maxLines = 1,
    this.hint,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: ctrl,
      readOnly: readOnly,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, size: 20),
        filled: readOnly,
        fillColor: readOnly
            ? AppColors.surfaceContainerLow.withValues(alpha: 0.5)
            : null,
      ),
    );
  }
}

class _ProfileRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ProfileRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.onSurfaceVariant),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.onSurfaceVariant,
                    fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _VehicleCard extends StatelessWidget {
  final Vehicle vehicle;
  final VoidCallback? onDelete;

  const _VehicleCard({
    required this.vehicle,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(10),
        border: vehicle.isPrimary
            ? Border.all(color: AppColors.primary.withValues(alpha: 0.4))
            : null,
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primaryContainer.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.directions_car, size: 20, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        vehicle.modelName,
                        style: const TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 14),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (vehicle.isPrimary)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'PRIMARY',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w700),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${vehicle.connectorType} • ${vehicle.batteryCapacity.toStringAsFixed(1)} kWh',
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.onSurfaceVariant),
                ),
                if (vehicle.plateNumber != null &&
                    vehicle.plateNumber!.isNotEmpty)
                  Text(
                    vehicle.plateNumber!,
                    style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.onSurfaceVariant,
                        fontWeight: FontWeight.w500),
                  ),
              ],
            ),
          ),
          if (onDelete != null)
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 20),
              color: AppColors.danger,
              onPressed: onDelete,
            ),
        ],
      ),
    );
  }
}

class _SheetField extends StatelessWidget {
  final TextEditingController ctrl;
  final String label;
  final String hint;
  final TextInputType? keyboardType;

  const _SheetField({
    required this.ctrl,
    required this.label,
    required this.hint,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: ctrl,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        isDense: true,
      ),
    );
  }
}
