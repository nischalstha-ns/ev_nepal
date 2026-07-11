import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import '../../theme/app_theme.dart';
import '../../utils/responsive.dart';
import '../../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // 0 = User → /user   |   1 = EV Station → /operator
  int _roleIndex = 0;
  bool _rememberMe = false;
  bool _obscurePassword = true;
  bool _loading = false;

  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _signIn() async {
    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text;
    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter email and password')),
      );
      return;
    }

    // Bypass auth - accept any email/password
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 500)); // Simulate loading

    if (!mounted) return;

    // Set mock user based on role toggle
    if (_roleIndex == 0) {
      AuthService.setMockUser('user');
    } else {
      AuthService.setMockUser('operator');
    }

    Navigator.pushReplacementNamed(context, '/roles');
  }

  void _otp() => ScaffoldMessenger.of(context)
      .showSnackBar(const SnackBar(content: Text('OTP demo — use Sign In')));
  void _google() => ScaffoldMessenger.of(context)
      .showSnackBar(const SnackBar(content: Text('Google Sign-In not configured')));
  void _apple() => ScaffoldMessenger.of(context)
      .showSnackBar(const SnackBar(content: Text('Apple Sign-In not configured')));

  @override
  Widget build(BuildContext context) {
    if (Responsive.isDesktop(context)) return _desktop();
    return _mobileTablet();
  }

  // ── MOBILE / TABLET ──────────────────────────────────────────────────────────

  Widget _mobileTablet() {
    const hPad = 24.0;

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: Column(
        children: [
          // ── FIXED LOGO — respects status bar, never scrolls ───────────────
          SafeArea(
            bottom: false,
            child: SizedBox(
              width: double.infinity,
              child: Image.asset(
                'assets/images/logo.png',
                height: 120,
                fit: BoxFit.contain,
              ),
            ),
          ),

          // ── SCROLLABLE FORM — takes all remaining space ───────────────────
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(hPad, 8, hPad, 40),
              child: _form(hPad),
            ),
          ),
        ],
      ),
    );
  }

  // ── DESKTOP ──────────────────────────────────────────────────────────────────

  Widget _desktop() {
    return Scaffold(
      body: Row(
        children: [
          // Left hero panel
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF001a0d),
                    Color(0xFF003d18),
                    Color(0xFF006b2c),
                  ],
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 56, vertical: 48),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.asset('assets/images/logo.png',
                          width: 280, fit: BoxFit.contain),
                      const SizedBox(height: 40),
                      const Text(
                        "Nepal's #1\nEV Charging Network",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          height: 1.2,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'AI-powered smart charging infrastructure',
                        style: TextStyle(
                            color: Color(0xAAFFFFFF), fontSize: 16),
                      ),
                      const SizedBox(height: 48),
                      _feat(Icons.location_on_rounded,
                          'Find nearby chargers instantly'),
                      const SizedBox(height: 20),
                      _feat(Icons.auto_awesome_rounded,
                          'Smart AI route & range planning'),
                      const SizedBox(height: 20),
                      _feat(Icons.bolt_rounded,
                          'Real-time availability updates'),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Right form panel
          Expanded(
            child: Container(
              color: Colors.white,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 48),
                    child: _form(32),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _feat(IconData icon, String text) => Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0x1FFFFFFF),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 14),
          Text(text,
              style: const TextStyle(color: Colors.white, fontSize: 15)),
        ],
      );

  // ── SHARED FORM ──────────────────────────────────────────────────────────────

  Widget _form(double hPad) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Welcome heading
        const Text(
          'Welcome Back',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: AppColors.onSurface,
            letterSpacing: -0.4,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Sign in to continue your journey',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.onSurfaceVariant,
          ),
        ),

        const SizedBox(height: 24),

        // Role toggle
        _RoleToggle(
          selected: _roleIndex,
          onChanged: (i) => setState(() => _roleIndex = i),
        ),

        const SizedBox(height: 24),

        // Email
        const Text('Email or Phone',
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.onSurface)),
        const SizedBox(height: 8),
        _InputField(
          controller: _emailCtrl,
          hint: 'Enter your email or phone',
          keyboardType: TextInputType.emailAddress,
          prefixIcon: Icons.mail_outline_rounded,
        ),

        const SizedBox(height: 16),

        // Password
        const Text('Password',
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.onSurface)),
        const SizedBox(height: 8),
        _InputField(
          controller: _passwordCtrl,
          hint: 'Enter your password',
          obscure: _obscurePassword,
          prefixIcon: Icons.lock_outline_rounded,
          suffix: IconButton(
            icon: Icon(
              _obscurePassword
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              size: 20,
              color: AppColors.outline,
            ),
            onPressed: () =>
                setState(() => _obscurePassword = !_obscurePassword),
          ),
        ),

        const SizedBox(height: 14),

        // Remember me + forgot password
        Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: Checkbox(
                value: _rememberMe,
                onChanged: (v) =>
                    setState(() => _rememberMe = v ?? false),
                activeColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4)),
                side: const BorderSide(
                    color: AppColors.outlineVariant, width: 1.5),
              ),
            ),
            const SizedBox(width: 8),
            const Text('Remember me',
                style: TextStyle(
                    fontSize: 13, color: AppColors.onSurface)),
            const Spacer(),
            GestureDetector(
              onTap: () {},
              child: const Text('Forgot password?',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  )),
            ),
          ],
        ),

        const SizedBox(height: 24),

        // Sign In button
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: _loading ? null : _signIn,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
            child: _loading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                        strokeWidth: 2.5, color: Colors.white),
                  )
                : const Text('Sign In',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w700)),
          ),
        ),

        const SizedBox(height: 20),

        // OR divider
        Row(
          children: [
            Expanded(
                child: Divider(
                    color: AppColors.outlineVariant.withValues(alpha: 0.7),
                    thickness: 1)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Text('OR',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.outline,
                      letterSpacing: 0.8)),
            ),
            Expanded(
                child: Divider(
                    color: AppColors.outlineVariant.withValues(alpha: 0.7),
                    thickness: 1)),
          ],
        ),

        const SizedBox(height: 16),

        // Continue with OTP
        SizedBox(
          width: double.infinity,
          height: 50,
          child: OutlinedButton.icon(
            onPressed: _otp,
            icon: const Icon(Icons.smartphone_outlined, size: 18),
            label: const Text('Continue with OTP',
                style: TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w600)),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.onSurface,
              side: BorderSide(
                  color: AppColors.outlineVariant
                      .withValues(alpha: 0.8)),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Google + Apple
        Row(
          children: [
            Expanded(
              child: _SocialBtn(
                onTap: _google,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    SizedBox(
                        width: 18,
                        height: 18,
                        child: CustomPaint(painter: _GLogoPainter())),
                    SizedBox(width: 8),
                    Text('Google',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.onSurface)),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _SocialBtn(
                onTap: _apple,
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.apple,
                        size: 20, color: AppColors.onSurface),
                    SizedBox(width: 8),
                    Text('Apple',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.onSurface)),
                  ],
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 28),

        // Register link
        Center(
          child: RichText(
            text: TextSpan(
              text: 'New to EVCharging? ',
              style: const TextStyle(
                  fontSize: 14, color: AppColors.onSurfaceVariant),
              children: [
                TextSpan(
                  text: 'Register',
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () =>
                        Navigator.pushNamed(context, '/register'),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Terms
        Center(
          child: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              text: 'By continuing, you agree to our ',
              style: const TextStyle(
                  fontSize: 11, color: AppColors.outline),
              children: [
                TextSpan(
                  text: 'Terms of Service',
                  style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.primary,
                      decoration: TextDecoration.underline),
                  recognizer: TapGestureRecognizer()..onTap = () {},
                ),
                const TextSpan(text: ' & '),
                TextSpan(
                  text: 'Privacy Policy',
                  style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.primary,
                      decoration: TextDecoration.underline),
                  recognizer: TapGestureRecognizer()..onTap = () {},
                ),
                const TextSpan(text: '.'),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ── Role toggle ───────────────────────────────────────────────────────────────

class _RoleToggle extends StatelessWidget {
  final int selected;
  final ValueChanged<int> onChanged;

  const _RoleToggle({required this.selected, required this.onChanged});

  static const _labels = ['User', 'EV Station'];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: const Color(0xFFF0F4F0),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
            color: AppColors.outlineVariant.withValues(alpha: 0.45),
            width: 1),
      ),
      child: Row(
        children: List.generate(_labels.length, (i) {
          final active = selected == i;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutCubic,
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: active ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(26),
                  boxShadow: active
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.25),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: Text(
                    _labels[i],
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: active ? Colors.white : AppColors.primary,
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ── Input field ───────────────────────────────────────────────────────────────

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool obscure;
  final TextInputType keyboardType;
  final IconData prefixIcon;
  final Widget? suffix;

  const _InputField({
    required this.controller,
    required this.hint,
    required this.prefixIcon,
    this.obscure = false,
    this.keyboardType = TextInputType.text,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      style: const TextStyle(fontSize: 15, color: AppColors.onSurface),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle:
            const TextStyle(color: AppColors.outline, fontSize: 14),
        filled: true,
        fillColor: const Color(0xFFF7F9F7),
        prefixIcon: Icon(prefixIcon, size: 20, color: AppColors.outline),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
              color: AppColors.outlineVariant.withValues(alpha: 0.6)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
              color: AppColors.outlineVariant.withValues(alpha: 0.6)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: AppColors.primary, width: 1.8),
        ),
        suffixIcon: suffix,
      ),
    );
  }
}

// ── Social button ─────────────────────────────────────────────────────────────

class _SocialBtn extends StatelessWidget {
  final VoidCallback onTap;
  final Widget child;

  const _SocialBtn({required this.onTap, required this.child});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: AppColors.outlineVariant.withValues(alpha: 0.65)),
        ),
        child: child,
      ),
    );
  }
}

// ── Google G painter ──────────────────────────────────────────────────────────

class _GLogoPainter extends CustomPainter {
  const _GLogoPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2;
    const segs = [
      (0.0, 90.0, Color(0xFF4285F4)),
      (90.0, 90.0, Color(0xFF34A853)),
      (180.0, 90.0, Color(0xFFFBBC05)),
      (270.0, 90.0, Color(0xFFEA4335)),
    ];
    for (final s in segs) {
      canvas.drawArc(
        Rect.fromCircle(center: c, radius: r * 0.78),
        s.$1 * 3.14159265 / 180,
        s.$2 * 3.14159265 / 180,
        false,
        Paint()
          ..color = s.$3
          ..style = PaintingStyle.stroke
          ..strokeWidth = size.width * 0.22,
      );
    }
    canvas.drawLine(
      Offset(size.width * 0.5, size.height * 0.5),
      Offset(size.width * 0.95, size.height * 0.5),
      Paint()
        ..color = const Color(0xFF4285F4)
        ..strokeWidth = size.height * 0.22
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter _) => false;
}
