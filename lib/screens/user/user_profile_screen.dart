import 'dart:io';
import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/vehicle_model.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/shimmer_card.dart';
import '../../widgets/branded_app_bar.dart';

enum ProfileLoadState {
  initial,
  loading,
  success,
  error,
  empty,
  offline,
}

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  static const _demoUserId = '11111111-1111-1111-1111-111111111111';
  String get _userId => AuthService.currentUserId ?? _demoUserId;

  ProfileLoadState _loadState = ProfileLoadState.initial;
  String? _errorMessage;
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
    developer.log(
      '🔵 ProfileScreen initialized',
      name: 'ProfileScreen',
      error: {'userId': _userId, 'authUserId': AuthService.currentUserId},
    );
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
    developer.log('📡 Starting profile load', name: 'ProfileScreen');

    setState(() {
      _loadState = ProfileLoadState.loading;
      _errorMessage = null;
    });

    try {
      await _checkNetworkConnectivity();

      developer.log('🔄 Fetching data from API...', name: 'ProfileScreen');

      final results = await Future.wait([
        ApiService.getUserProfile(_userId),
        ApiService.getVehicles(_userId),
        ApiService.getCurrentMembership(_userId),
      ]).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw TimeoutException('Request timed out after 15 seconds');
        },
      );

      final profile = results[0] as Map<String, dynamic>?;
      final vehicles = results[1] as List;
      final membership = results[2] as Map<String, dynamic>?;

      developer.log(
        '✅ Data fetched successfully',
        name: 'ProfileScreen',
        error: {
          'profile': profile != null ? 'loaded' : 'NULL',
          'profileData': profile?.toString() ?? 'null',
          'vehicles': vehicles.length,
          'membership': membership != null ? 'exists' : 'null',
        },
      );

      if (profile == null) {
        developer.log('⚠️ Profile is NULL - user not found', name: 'ProfileScreen');

        if (mounted) {
          setState(() {
            _loadState = ProfileLoadState.empty;
            _errorMessage = 'Profile not found. User ID: $_userId';
          });
        }
        return;
      }

      if (mounted) {
        setState(() {
          _profile = profile;
          _vehicles = vehicles
              .map((e) => Vehicle.fromJson(e as Map<String, dynamic>))
              .toList();
          _membership = membership;
          _loadState = ProfileLoadState.success;
          _errorMessage = null;

          _nameCtrl.text = profile['full_name'] ?? '';
          _emailCtrl.text = profile['email'] ?? '';
          _phoneCtrl.text = profile['phone'] ?? '';
          _addressCtrl.text = profile['address'] ?? '';
          _bioCtrl.text = profile['bio'] ?? '';
        });

        developer.log('🟢 State updated - profile loaded', name: 'ProfileScreen');
      }
    } on TimeoutException catch (e) {
      developer.log('❌ Timeout error', name: 'ProfileScreen', error: e);
      if (mounted) {
        setState(() {
          _loadState = ProfileLoadState.error;
          _errorMessage = 'Request timed out. Please try again.';
        });
      }
    } on SocketException catch (e) {
      developer.log('❌ Network error', name: 'ProfileScreen', error: e);
      if (mounted) {
        setState(() {
          _loadState = ProfileLoadState.offline;
          _errorMessage = 'No internet connection';
        });
      }
    } on FormatException catch (e) {
      developer.log('❌ JSON parsing error', name: 'ProfileScreen', error: e);
      if (mounted) {
        setState(() {
          _loadState = ProfileLoadState.error;
          _errorMessage = 'Invalid data format received';
        });
      }
    } catch (e, stackTrace) {
      developer.log(
        '❌ Unexpected error loading profile',
        name: 'ProfileScreen',
        error: e,
        stackTrace: stackTrace,
      );

      if (mounted) {
        setState(() {
          _loadState = ProfileLoadState.error;
          _errorMessage = e.toString().replaceAll('Exception: ', '');
        });
      }
    }
  }

  Future<void> _checkNetworkConnectivity() async {
    try {
      final result = await InternetAddress.lookup('supabase.co');
      if (result.isEmpty || result[0].rawAddress.isEmpty) {
        throw const SocketException('No network connectivity');
      }
    } on SocketException {
      throw const SocketException('No internet connection');
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
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      developer.log('❌ Error saving profile', name: 'ProfileScreen', error: e);

      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString().replaceAll("Exception: ", "")}'),
            backgroundColor: AppColors.danger,
          ),
        );
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

  void _showAddVehicleDialog() {
    showDialog(
      context: context,
      builder: (context) => _AddVehicleDialog(
        userId: _userId,
        onAdded: () {
          _load(); // Reload vehicles
        },
      ),
    );
  }

  void _editVehicle(Vehicle vehicle) {
    showDialog(
      context: context,
      builder: (context) => _AddVehicleDialog(
        userId: _userId,
        existingVehicle: vehicle,
        onAdded: () {
          _load(); // Reload vehicles
        },
      ),
    );
  }

  Future<void> _deleteVehicle(String vehicleId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Vehicle'),
        content: const Text('Are you sure you want to delete this vehicle?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        // In a real app, call API to delete
        // await ApiService.deleteVehicle(vehicleId);

        setState(() {
          _vehicles.removeWhere((v) => v.id == vehicleId);
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Vehicle deleted'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to delete: $e')),
          );
        }
      }
    }
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
      appBar: BrandedAppBar(
        title: 'Profile',
        showBackButton: Navigator.of(context).canPop(),
        showProfileAvatar: !Navigator.of(context).canPop(),
        actions: [
          if (_loadState == ProfileLoadState.success && !_editingProfile)
            TextButton.icon(
              onPressed: () => setState(() => _editingProfile = true),
              icon: const Icon(Icons.edit_outlined, size: 16),
              label: const Text('Edit'),
            ),
        ],
      ),
      body: _buildBody(tt),
    );
  }

  Widget _buildBody(TextTheme tt) {
    switch (_loadState) {
      case ProfileLoadState.initial:
      case ProfileLoadState.loading:
        return _buildLoadingState();

      case ProfileLoadState.error:
        return _buildErrorState(tt);

      case ProfileLoadState.empty:
        return _buildEmptyState(tt);

      case ProfileLoadState.offline:
        return _buildOfflineState(tt);

      case ProfileLoadState.success:
        if (_profile == null) {
          return _buildEmptyState(tt);
        }
        return _buildSuccessState(tt);
    }
  }

  Widget _buildLoadingState() {
    return const Padding(
      padding: EdgeInsets.all(16),
      child: ShimmerList(count: 4, itemHeight: 80),
    );
  }

  Widget _buildErrorState(TextTheme tt) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.errorContainer,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline,
                size: 40,
                color: AppColors.danger,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Unable to Load Profile',
              style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? 'An unexpected error occurred',
              style: tt.bodyMedium?.copyWith(color: AppColors.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton.icon(
                  onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
                  icon: const Icon(Icons.logout, size: 16),
                  label: const Text('Sign Out'),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: _load,
                  icon: const Icon(Icons.refresh, size: 16),
                  label: const Text('Retry'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(TextTheme tt) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerHigh,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person_off_outlined,
                size: 40,
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Profile Not Found',
              style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              'No profile exists for this account',
              style: tt.bodyMedium?.copyWith(color: AppColors.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              'User ID: $_userId',
              style: tt.bodySmall?.copyWith(
                color: AppColors.onSurfaceVariant,
                fontFamily: 'monospace',
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _load,
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOfflineState(TextTheme tt) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerHigh,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.cloud_off_outlined,
                size: 40,
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Internet Connection',
              style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              'Please check your network connection and try again',
              style: tt.bodyMedium?.copyWith(color: AppColors.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _load,
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessState(TextTheme tt) {
    return RefreshIndicator(
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
                    borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
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
                                  child: (_selectedImage == null &&
                                          _profile?['profile_image_url'] == null)
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
                                  Text(
                                    'Edit Profile',
                                    style: tt.titleLarge?.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  )
                                else ...[
                                  Text(
                                    _profile!['full_name'] ?? 'EV User',
                                    style: tt.titleLarge?.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(Icons.email_outlined,
                                          size: 14, color: AppColors.onSurfaceVariant),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          _profile!['email'] ?? 'No email',
                                          style: tt.bodySmall
                                              ?.copyWith(color: AppColors.onSurfaceVariant),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (_profile!['phone'] != null &&
                                      (_profile!['phone'] as String).isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Icon(Icons.phone_outlined,
                                            size: 14, color: AppColors.onSurfaceVariant),
                                        const SizedBox(width: 4),
                                        Text(
                                          _profile!['phone'],
                                          style: tt.bodySmall
                                              ?.copyWith(color: AppColors.onSurfaceVariant),
                                        ),
                                      ],
                                    ),
                                  ],
                                  const SizedBox(height: 6),
                                  Container(
                                    padding:
                                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryContainer.withValues(alpha: 0.3),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      (_profile!['tier'] as String?)?.toUpperCase() ?? 'STANDARD',
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
                      if (!_editingProfile &&
                          (_profile!['address'] != null || _profile!['bio'] != null)) ...[
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
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Text('Save'),
                              ),
                            ),
                          ],
                        ),
                      ] else ...[
                        if (_profile!['address'] != null &&
                            (_profile!['address'] as String).isNotEmpty)
                          _ProfileRow(
                            icon: Icons.location_on_outlined,
                            label: 'Address',
                            value: _profile!['address'],
                          ),
                        if (_profile!['address'] != null &&
                            _profile!['bio'] != null &&
                            (_profile!['address'] as String).isNotEmpty &&
                            (_profile!['bio'] as String).isNotEmpty)
                          const SizedBox(height: 12),
                        if (_profile!['bio'] != null && (_profile!['bio'] as String).isNotEmpty)
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
                      onPressed: () => Navigator.pushNamed(context, '/user/membership'),
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
                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
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
                                _membership!['membership_plans']['name'] ?? 'Plan',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                ),
                              ),
                              Text(
                                'Active',
                                style: tt.bodySmall?.copyWith(color: AppColors.success),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right, color: AppColors.primary),
                      ],
                    ),
                  ),
                ] else
                  Text(
                    'No active membership',
                    style: tt.bodyMedium?.copyWith(color: AppColors.onSurfaceVariant),
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
                      onPressed: _showAddVehicleDialog,
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text('Add'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (_vehicles.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.outlineVariant, style: BorderStyle.solid, width: 1.5),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.directions_car_outlined, size: 48, color: AppColors.onSurfaceVariant.withValues(alpha: 0.5)),
                        const SizedBox(height: 12),
                        Text(
                          'No vehicles added yet',
                          style: tt.titleSmall?.copyWith(color: AppColors.onSurfaceVariant),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Add your EV to get personalized recommendations',
                          textAlign: TextAlign.center,
                          style: tt.bodySmall?.copyWith(color: AppColors.onSurfaceVariant.withValues(alpha: 0.7)),
                        ),
                      ],
                    ),
                  )
                else
                  ..._vehicles.map((v) => _VehicleCard(
                        vehicle: v,
                        onEdit: () => _editVehicle(v),
                        onDelete: () => _deleteVehicle(v.id),
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
        fillColor:
            readOnly ? AppColors.surfaceContainerLow.withValues(alpha: 0.5) : null,
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
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(value, style: const TextStyle(fontSize: 14)),
            ],
          ),
        ),
      ],
    );
  }
}

class _VehicleCard extends StatelessWidget {
  final Vehicle vehicle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _VehicleCard({
    required this.vehicle,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(
        children: [
          // Header with model and actions
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.electric_car, color: AppColors.primary, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        vehicle.modelName,
                        style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      if (vehicle.plateNumber != null)
                        Text(
                          vehicle.plateNumber!,
                          style: tt.bodySmall?.copyWith(color: AppColors.onSurfaceVariant),
                        ),
                    ],
                  ),
                ),
                if (vehicle.isPrimary)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'PRIMARY',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                const SizedBox(width: 8),
                PopupMenuButton(
                  icon: const Icon(Icons.more_vert, size: 20),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 18),
                          SizedBox(width: 8),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 18, color: AppColors.danger),
                          SizedBox(width: 8),
                          Text('Delete', style: TextStyle(color: AppColors.danger)),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (value) {
                    if (value == 'edit') onEdit();
                    if (value == 'delete') onDelete();
                  },
                ),
              ],
            ),
          ),
          // Details
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: _VehicleDetailChip(
                    icon: Icons.battery_charging_full,
                    label: '${vehicle.batteryCapacity.toStringAsFixed(1)} kWh',
                    color: AppColors.success,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _VehicleDetailChip(
                    icon: Icons.cable,
                    label: vehicle.connectorType,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _VehicleDetailChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _VehicleDetailChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _AddVehicleDialog extends StatefulWidget {
  final String userId;
  final Vehicle? existingVehicle;
  final VoidCallback onAdded;

  const _AddVehicleDialog({
    required this.userId,
    this.existingVehicle,
    required this.onAdded,
  });

  @override
  State<_AddVehicleDialog> createState() => _AddVehicleDialogState();
}

class _AddVehicleDialogState extends State<_AddVehicleDialog> {
  final _formKey = GlobalKey<FormState>();
  final _modelCtrl = TextEditingController();
  final _plateCtrl = TextEditingController();
  final _batteryCtrl = TextEditingController();

  String _connectorType = 'CCS2';
  bool _isPrimary = false;
  bool _saving = false;

  // Popular EV models in Nepal
  final List<String> _popularModels = [
    'BYD Atto 3',
    'BYD Seal',
    'MG ZS EV',
    'MG4 Electric',
    'Tesla Model 3',
    'Tesla Model Y',
    'Hyundai Ioniq 5',
    'Kia EV6',
    'Nissan Leaf',
    'Tata Nexon EV',
    'Mahindra e20',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.existingVehicle != null) {
      _modelCtrl.text = widget.existingVehicle!.modelName;
      _plateCtrl.text = widget.existingVehicle!.plateNumber ?? '';
      _batteryCtrl.text = widget.existingVehicle!.batteryCapacity.toString();
      _connectorType = widget.existingVehicle!.connectorType;
      _isPrimary = widget.existingVehicle!.isPrimary;
    }
  }

  @override
  void dispose() {
    _modelCtrl.dispose();
    _plateCtrl.dispose();
    _batteryCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    try {
      // In a real app, call API to add/update vehicle
      // await ApiService.addVehicle(...);

      await Future.delayed(const Duration(milliseconds: 500)); // Simulate API call

      if (mounted) {
        Navigator.pop(context);
        widget.onAdded();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.existingVehicle != null ? 'Vehicle updated' : 'Vehicle added'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final screenWidth = MediaQuery.of(context).size.width;
    final dialogWidth = screenWidth > 500 ? 500.0 : screenWidth * 0.9;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: dialogWidth),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.electric_car, color: AppColors.primary, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          widget.existingVehicle != null ? 'Edit Vehicle' : 'Add Vehicle',
                          style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close, size: 20),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                      ),
                    ],
                  ),
                const SizedBox(height: 24),

                // Model Name with suggestions
                Text('Vehicle Model*', style: tt.labelLarge),
                const SizedBox(height: 8),
                Autocomplete<String>(
                  optionsBuilder: (textEditingValue) {
                    if (textEditingValue.text.isEmpty) {
                      return _popularModels;
                    }
                    return _popularModels.where((model) =>
                        model.toLowerCase().contains(textEditingValue.text.toLowerCase()));
                  },
                  onSelected: (selection) => _modelCtrl.text = selection,
                  fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                    _modelCtrl.text = controller.text;
                    return TextFormField(
                      controller: controller,
                      focusNode: focusNode,
                      decoration: const InputDecoration(
                        hintText: 'e.g., BYD Atto 3',
                        prefixIcon: Icon(Icons.directions_car, size: 20),
                      ),
                      validator: (v) => v?.trim().isEmpty ?? true ? 'Required' : null,
                    );
                  },
                ),
                const SizedBox(height: 16),

                // Plate Number
                Text('Plate Number', style: tt.labelLarge),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _plateCtrl,
                  textCapitalization: TextCapitalization.characters,
                  decoration: const InputDecoration(
                    hintText: 'BA 1 PA 1234',
                    prefixIcon: Icon(Icons.badge, size: 20),
                  ),
                ),
                const SizedBox(height: 16),

                // Battery Capacity
                Text('Battery Capacity (kWh)*', style: tt.labelLarge),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _batteryCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    hintText: 'e.g., 60.5',
                    prefixIcon: Icon(Icons.battery_charging_full, size: 20),
                    suffixText: 'kWh',
                  ),
                  validator: (v) {
                    if (v?.trim().isEmpty ?? true) return 'Required';
                    final val = double.tryParse(v!);
                    if (val == null || val <= 0) return 'Invalid value';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Connector Type
                Text('Connector Type*', style: tt.labelLarge),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _connectorType,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.cable, size: 20),
                  ),
                  items: [
                    DropdownMenuItem(
                      value: 'CCS2',
                      child: Text(
                        'CCS2 (Combined Charging)',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'CHAdeMO',
                      child: Text(
                        'CHAdeMO',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'Type2',
                      child: Text(
                        'Type 2 (AC)',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'GB/T',
                      child: Text(
                        'GB/T (Chinese Standard)',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                  onChanged: (v) => setState(() => _connectorType = v!),
                ),
                const SizedBox(height: 16),

                // Primary vehicle checkbox
                CheckboxListTile(
                  value: _isPrimary,
                  onChanged: (v) => setState(() => _isPrimary = v ?? false),
                  title: const Text('Set as primary vehicle'),
                  subtitle: const Text('Your main EV for recommendations'),
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                ),

                const SizedBox(height: 24),

                // Actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: _saving ? null : () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: _saving ? null : _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                      child: _saving
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : Text(widget.existingVehicle != null ? 'Update' : 'Add Vehicle'),
                    ),
                  ],
                ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
