import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  static SupabaseClient get _client => Supabase.instance.client;

  // Mock user IDs for bypassed auth
  static String _mockUserId = '11111111-1111-1111-1111-111111111111'; // Default: user
  static String _mockRole = 'user';

  /// Set the mock user for demo mode
  static void setMockUser(String role) {
    switch (role) {
      case 'user':
        _mockUserId = '11111111-1111-1111-1111-111111111111';
        _mockRole = 'user';
        break;
      case 'operator':
        _mockUserId = '22222222-2222-2222-2222-222222222222';
        _mockRole = 'operator';
        break;
      case 'admin':
        _mockUserId = '33333333-3333-3333-3333-333333333333';
        _mockRole = 'admin';
        break;
      default:
        _mockUserId = '11111111-1111-1111-1111-111111111111';
        _mockRole = 'user';
    }
  }

  static Future<String> signIn(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      throw Exception('Enter email and password');
    }

    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw Exception('Login failed');
      }

      return response.user!.id;
    } catch (e) {
      if (e.toString().contains('Invalid login credentials')) {
        throw Exception('Invalid email or password');
      }
      rethrow;
    }
  }

  static Future<String> signUp({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String role,
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': name,
          'phone': phone,
          'role': role,
        },
      );

      if (response.user == null) {
        throw Exception('Sign up failed');
      }

      await _client.from('users').insert({
        'id': response.user!.id,
        'full_name': name,
        'email': email,
        'phone': phone,
        'role': role,
        'tier': 'standard',
        'status': 'active',
      });

      return response.user!.id;
    } catch (e) {
      if (e.toString().contains('User already registered')) {
        throw Exception('Email already registered');
      }
      rethrow;
    }
  }

  static Future<void> signOut() async {
    await _client.auth.signOut();
  }

  static User? get currentUser => _client.auth.currentUser;

  // Bypass auth - return mock user ID based on role
  static String? get currentUserId => _mockUserId;

  static Stream<AuthState> get authStateChanges =>
      _client.auth.onAuthStateChange;

  static Future<String> getUserRole(String userId) async {
    // Bypass auth - return mock role
    return _mockRole;
  }

  static Future<void> updatePassword(String newPassword) async {
    await _client.auth.updateUser(
      UserAttributes(password: newPassword),
    );
  }
}
