import 'dart:io';
import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/vehicle_model.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/shimmer_card.dart';

class UserProfileScreenDebug extends StatefulWidget {
  const UserProfileScreenDebug({super.key});

  @override
  State<UserProfileScreenDebug> createState() => _UserProfileScreenDebugState();
}

class _UserProfileScreenDebugState extends State<UserProfileScreenDebug> {
  static const _demoUserId = '11111111-1111-1111-1111-111111111111';
  String get _userId => AuthService.currentUserId ?? _demoUserId;

  bool _loading = true;
  String? _loadError;
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
    developer.log('🔵 Profile Screen: initState called', name: 'ProfileDebug');
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
    developer.log('🟡 Starting profile load...', name: 'ProfileDebug');
    developer.log('   User ID: $_userId', name: 'ProfileDebug');
    developer.log('   Auth currentUserId: ${AuthService.currentUserId}', name: 'ProfileDebug');

    setState(() {
      _loading = true;
      _loadError = null;
    });

    try {
      developer.log('📡 Fetching data from API...', name: 'ProfileDebug');

      final results = await Future.wait([
        ApiService.getUserProfile(_userId),
        ApiService.getVehicles(_userId),
        ApiService.getCurrentMembership(_userId),
      ]);

      developer.log('✅ API calls completed', name: 'ProfileDebug');

      final profile = results[0] as Map<String, dynamic>?;
      final vehicles = results[1] as List;
      final membership = results[2] as Map<String, dynamic>?;

      developer.log('📦 Profile data: ${profile?.toString() ?? "NULL"}', name: 'ProfileDebug');
      developer.log('📦 Vehicles count: ${vehicles.length}', name: 'ProfileDebug');
      developer.log('📦 Membership: ${membership != null ? "exists" : "null"}', name: 'ProfileDebug');

      if (profile == null) {
        developer.log('⚠️ WARNING: Profile is NULL!', name: 'ProfileDebug');
      } else {
        developer.log('   full_name: ${profile['full_name']}', name: 'ProfileDebug');
        developer.log('   email: ${profile['email']}', name: 'ProfileDebug');
        developer.log('   phone: ${profile['phone']}', name: 'ProfileDebug');
        developer.log('   address: ${profile['address']}', name: 'ProfileDebug');
        developer.log('   bio: ${profile['bio']}', name: 'ProfileDebug');
        developer.log('   tier: ${profile['tier']}', name: 'ProfileDebug');
      }

      if (mounted) {
        setState(() {
          _profile = profile;
          _vehicles = vehicles
              .map((e) => Vehicle.fromJson(e as Map<String, dynamic>))
              .toList();
          _membership = membership;
          _loading = false;

          if (profile != null) {
            _nameCtrl.text = profile['full_name'] ?? '';
            _emailCtrl.text = profile['email'] ?? '';
            _phoneCtrl.text = profile['phone'] ?? '';
            _addressCtrl.text = profile['address'] ?? '';
            _bioCtrl.text = profile['bio'] ?? '';
          }
        });

        developer.log('🟢 State updated successfully', name: 'ProfileDebug');
        developer.log('   _loading: $_loading', name: 'ProfileDebug');
        developer.log('   _profile != null: ${_profile != null}', name: 'ProfileDebug');
      }
    } catch (e, stackTrace) {
      developer.log('❌ ERROR loading profile: $e', name: 'ProfileDebug');
      developer.log('Stack trace: $stackTrace', name: 'ProfileDebug');

      if (mounted) {
        setState(() {
          _loading = false;
          _loadError = e.toString();
        });
      }
    }
  }

  String get _initials {
    final name = _profile?['full_name'] as String? ?? 'U';
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return name.isNotEmpty ? name[0].toUpperCase() : 'U';
  }

  @override
  Widget build(BuildContext context) {
    developer.log('🎨 Build called - loading: $_loading, profile: ${_profile != null}, error: $_loadError', name: 'ProfileDebug');

    final tt = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Profile (Debug)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bug_report),
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Debug Info'),
                  content: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Loading: $_loading'),
                        Text('Error: ${_loadError ?? "none"}'),
                        Text('Profile: ${_profile != null ? "loaded" : "null"}'),
                        Text('User ID: $_userId'),
                        Text('Auth ID: ${AuthService.currentUserId ?? "null"}'),
                        if (_profile != null) ...[
                          const Divider(),
                          Text('Name: ${_profile!['full_name']}'),
                          Text('Email: ${_profile!['email']}'),
                          Text('Phone: ${_profile!['phone']}'),
                          Text('Address: ${_profile!['address']}'),
                          Text('Bio: ${_profile!['bio']}'),
                        ],
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Close'),
                    ),
                  ],
                ),
              );
            },
          ),
          if (!_editingProfile && !_loading)
            TextButton.icon(
              onPressed: () => setState(() => _editingProfile = true),
              icon: const Icon(Icons.edit_outlined, size: 16),
              label: const Text('Edit'),
            ),
        ],
      ),
      body: _loading
          ? Column(
              children: [
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: ShimmerList(count: 4, itemHeight: 80),
                ),
                const Text('Loading profile data...'),
              ],
            )
          : _loadError != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline, size: 48, color: AppColors.danger),
                        const SizedBox(height: 16),
                        Text('Error: $_loadError', textAlign: TextAlign.center),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _load,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                )
              : _profile == null
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.person_off, size: 48, color: AppColors.warning),
                            const SizedBox(height: 16),
                            const Text('No profile data found'),
                            const SizedBox(height: 8),
                            Text('User ID: $_userId', style: const TextStyle(fontSize: 12)),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _load,
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _load,
                      child: ListView(
                        padding: const EdgeInsets.all(16),
                        children: [
                          Container(
                            color: Colors.green.withValues(alpha: 0.1),
                            padding: const EdgeInsets.all(8),
                            child: Text('✅ Profile loaded: ${_profile!['full_name']}'),
                          ),
                          const SizedBox(height: 16),
                          SurfaceCard(
                            aiAccent: true,
                            borderAccentColor: AppColors.primary,
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 40,
                                      backgroundColor: AppColors.secondaryContainer,
                                      child: Text(
                                        _initials,
                                        style: const TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            _profile!['full_name'] ?? 'No name',
                                            style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(_profile!['email'] ?? 'No email'),
                                          if (_profile!['phone'] != null)
                                            Text(_profile!['phone']),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                if (_profile!['address'] != null || _profile!['bio'] != null) ...[
                                  const Divider(height: 24),
                                  if (_profile!['address'] != null)
                                    Text('Address: ${_profile!['address']}'),
                                  if (_profile!['bio'] != null)
                                    Text('Bio: ${_profile!['bio']}'),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text('Vehicles: ${_vehicles.length}'),
                          Text('Membership: ${_membership != null ? "Active" : "None"}'),
                        ],
                      ),
                    ),
    );
  }
}
