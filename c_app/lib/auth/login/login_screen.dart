import 'package:c_app/auth/forget_password/forgotPassword.dart';
import 'package:c_app/auth/login/login_api_service.dart';
import 'package:c_app/auth/login/loginwithotp.dart';
import 'package:c_app/auth/login/loginwithpassword.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ─────────────────────────────────────────────
//  Color constants  (matches RegisterScreen)
// ─────────────────────────────────────────────
class _C {
  static const bg      = Color(0xFF0A0A0A);
  static const surface = Color(0xFF141414);
  static const border  = Color(0xFF2A2A2A);
  static const borderF = Color(0xFF888888);
  static const white   = Color(0xFFFFFFFF);
  static const w60     = Color(0x99FFFFFF);
  static const w35     = Color(0x59FFFFFF);
  static const w15     = Color(0x26FFFFFF);
  static const w08     = Color(0x14FFFFFF);
  static const error   = Color(0xFFE05555);
}

// ─────────────────────────────────────────────
//  LoginScreen
// ─────────────────────────────────────────────
class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {

  final _emailCtrl = TextEditingController();
  final _emailFN   = FocusNode();
  final _api       = LoginApiService();

  bool _isLoadingOtp = false;
  String? _emailErr;

  late AnimationController _entry;
  late List<Animation<double>>  _fades;
  late List<Animation<Offset>>  _slides;

  @override
  void initState() {
    super.initState();
    _entry = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1100));
    _fades  = List.generate(5, (i) => CurvedAnimation(
        parent: _entry,
        curve: Interval(i * 0.12, (i * 0.12 + 0.55).clamp(0, 1),
            curve: Curves.easeOut)));
    _slides = List.generate(5, (i) => Tween<Offset>(
        begin: const Offset(0, 0.06), end: Offset.zero).animate(
        CurvedAnimation(
            parent: _entry,
            curve: Interval(i * 0.12, (i * 0.12 + 0.55).clamp(0, 1),
                curve: Curves.easeOut))));
    _entry.forward();
  }

  @override
  void dispose() {
    _entry.dispose();
    _emailCtrl.dispose();
    _emailFN.dispose();
    super.dispose();
  }

  // ── Validation ──────────────────────────────
  bool _validateEmail() {
    final e = _emailCtrl.text.trim();
    if (e.isEmpty) {
      setState(() => _emailErr = 'Email is required');
      return false;
    }
    if (!RegExp(r'^[\w.+-]+@[\w-]+\.[a-z]{2,}$').hasMatch(e)) {
      setState(() => _emailErr = 'Enter a valid email address');
      return false;
    }
    setState(() => _emailErr = null);
    return true;
  }

  // ── Login with OTP ───────────────────────────
  Future<void> _loginWithOtp() async {
    if (!_validateEmail()) { HapticFeedback.mediumImpact(); return; }
    HapticFeedback.lightImpact();
    setState(() => _isLoadingOtp = true);
    final success = await _api.sendOtp(_emailCtrl.text.trim());
    if (!mounted) return;
    setState(() => _isLoadingOtp = false);
    if (success) {
      Navigator.push(context, _fade(OtpLoginScreen(email: _emailCtrl.text.trim())));
    } else {
      _snack('Failed to send OTP. Please try again.');
    }
  }

  // ── Login with Password ──────────────────────
  void _loginWithPassword() {
    if (!_validateEmail()) { HapticFeedback.mediumImpact(); return; }
    HapticFeedback.lightImpact();
    Navigator.push(context,
        _fade(PasswordLoginScreen(email: _emailCtrl.text.trim())));
  }

  // ── Forgot password ──────────────────────────
  void _forgotPassword() {
    HapticFeedback.lightImpact();
    Navigator.push(context, _fade(ForgotPasswordScreen()));
  }

  PageRoute _fade(Widget page) => PageRouteBuilder(
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, a, __, c) => FadeTransition(opacity: a, child: c),
      transitionDuration: const Duration(milliseconds: 380));

  void _snack(String msg) => ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(msg,
              style: const TextStyle(
                  color: Colors.white, fontFamily: 'Georgia', fontSize: 13)),
          backgroundColor: const Color(0xFF1A1A1A),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
              side: const BorderSide(color: Color(0xFFE05555), width: 0.8)),
          margin: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          duration: const Duration(seconds: 3)));

  // ─────────────────────────────────────────────
  //  Build
  // ─────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: _C.bg,
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height -
                      MediaQuery.of(context).padding.vertical),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _anim(0, _buildBrand()),
                    _anim(1, _buildHeadline()),
                    const SizedBox(height: 32),
                    _anim(2, _buildEmailField()),
                    const SizedBox(height: 28),
                    _anim(3, _buildButtons()),
                    const Spacer(),
                    _anim(4, _buildFooter()),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _anim(int i, Widget child) => FadeTransition(
      opacity: _fades[i],
      child: SlideTransition(position: _slides[i], child: child));

  // ─────────────────────────────────────────────
  //  Brand header
  // ─────────────────────────────────────────────
  Widget _buildBrand() => Padding(
    padding: const EdgeInsets.fromLTRB(28, 40, 28, 0),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 48, height: 48,
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(12)),
          child: const Center(
              child: Text('C',
                  style: TextStyle(
                      fontFamily: 'Georgia', fontSize: 26, color: Colors.black,
                      fontWeight: FontWeight.w700, height: 1, letterSpacing: -0.5)))),
        const SizedBox(width: 13),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('CAPP',
              style: TextStyle(
                  fontFamily: 'Georgia', fontSize: 15, color: Colors.white,
                  fontWeight: FontWeight.w600, letterSpacing: 3)),
          Text('Premium Platform',
              style: TextStyle(
                  fontFamily: 'Georgia', fontSize: 10,
                  color: _C.w35, letterSpacing: 1.5)),
        ]),
        const Spacer(),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Container(width: 22, height: 1.5, color: Colors.white),
          const SizedBox(height: 5),
          Container(width: 11, height: 1.5, color: _C.w35),
        ]),
      ],
    ),
  );

  // ─────────────────────────────────────────────
  //  Headline
  // ─────────────────────────────────────────────
  Widget _buildHeadline() => Padding(
    padding: const EdgeInsets.fromLTRB(28, 44, 28, 0),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('WELCOME\nBACK',
          style: TextStyle(
              fontFamily: 'Georgia', fontSize: 40, color: Colors.white,
              fontWeight: FontWeight.w300, height: 0.95, letterSpacing: -1.5)),
      const SizedBox(height: 14),
      Text('Sign in to continue to your\npremium workspace.',
          style: TextStyle(
              fontFamily: 'Georgia', fontSize: 13, color: _C.w35,
              height: 1.65, letterSpacing: 0.2)),
      const SizedBox(height: 20),
      Row(children: [
        Container(width: 32, height: 1.5, color: Colors.white),
        const SizedBox(width: 6),
        Container(width: 6,  height: 1.5, color: _C.w35),
        const SizedBox(width: 3),
        Container(width: 3,  height: 1.5, color: _C.w15),
      ]),
    ]),
  );

  // ─────────────────────────────────────────────
  //  Email field
  // ─────────────────────────────────────────────
  Widget _buildEmailField() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 28),
    child: _PremiumField(
      controller: _emailCtrl,
      focusNode: _emailFN,
      label: 'Email address',
      hint: 'you@example.com',
      icon: Icons.mail_outline_rounded,
      error: _emailErr,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.done,
      onChanged: (_) { if (_emailErr != null) setState(() => _emailErr = null); },
      onSubmitted: (_) => _loginWithOtp(),
    ),
  );

  // ─────────────────────────────────────────────
  //  Buttons
  // ─────────────────────────────────────────────
  Widget _buildButtons() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 28),
    child: Column(children: [

      // ── Send OTP (primary) ──
      _Press(
        onTap: (_isLoadingOtp) ? null : _loginWithOtp,
        child: Container(
          width: double.infinity, height: 56,
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(6)),
          child: Center(
            child: _isLoadingOtp
                ? const SizedBox(
                    width: 20, height: 20,
                    child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
                : const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('SEND OTP',
                          style: TextStyle(
                              fontFamily: 'Georgia', color: Colors.black,
                              fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 2.5)),
                      SizedBox(width: 10),
                      Icon(Icons.send_rounded, color: Colors.black, size: 14),
                    ]),
          ),
        ),
      ),

      const SizedBox(height: 12),

      // ── Login with password (ghost) ──
      _Press(
        onTap: _loginWithPassword,
        child: Container(
          width: double.infinity, height: 56,
          decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: _C.border, width: 1)),
          child: const Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.lock_outline_rounded, color: Colors.white, size: 15),
                SizedBox(width: 10),
                Text('LOGIN WITH PASSWORD',
                    style: TextStyle(
                        fontFamily: 'Georgia', color: Colors.white,
                        fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 2)),
              ],
            ),
          ),
        ),
      ),

      const SizedBox(height: 20),

      // ── Divider ──
      Row(children: [
        Expanded(child: Divider(color: _C.w15, thickness: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Text('OR', style: TextStyle(
              fontFamily: 'Georgia', fontSize: 9, color: _C.w35, letterSpacing: 3))),
        Expanded(child: Divider(color: _C.w15, thickness: 1)),
      ]),

      const SizedBox(height: 20),

      // ── Forgot password (text link styled) ──
      _Press(
        onTap: _forgotPassword,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: _C.w08, width: 1)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.help_outline_rounded, color: _C.w35, size: 14),
              const SizedBox(width: 8),
              Text('Forgot your password?',
                  style: TextStyle(
                      fontFamily: 'Georgia', fontSize: 13,
                      color: _C.w35, letterSpacing: 0.3)),
              const SizedBox(width: 6),
              Text('Reset',
                  style: TextStyle(
                      fontFamily: 'Georgia', fontSize: 13,
                      color: Colors.white, fontWeight: FontWeight.w700,
                      letterSpacing: 0.5)),
            ],
          ),
        ),
      ),
    ]),
  );

  // ─────────────────────────────────────────────
  //  Footer
  // ─────────────────────────────────────────────
  Widget _buildFooter() => Container(
    width: double.infinity,
    padding: const EdgeInsets.fromLTRB(28, 20, 28, 32),
    child: Column(children: [
      Divider(color: _C.w08, thickness: 1),
      const SizedBox(height: 14),
      Text('Don\'t have an account yet?',
          style: TextStyle(
              fontFamily: 'Georgia', fontSize: 12,
              color: _C.w35, letterSpacing: 0.2)),
      const SizedBox(height: 6),
      GestureDetector(
        onTap: () => Navigator.pop(context),
        child: const Text('Create one — it\'s free.',
            style: TextStyle(
                fontFamily: 'Georgia', fontSize: 13, color: Colors.white,
                fontWeight: FontWeight.w600, letterSpacing: 0.5,
                decoration: TextDecoration.underline,
                decorationColor: Colors.white)),
      ),
    ]),
  );
}

// ─────────────────────────────────────────────
//  Premium Field  (identical to RegisterScreen)
// ─────────────────────────────────────────────
class _PremiumField extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final String label;
  final String hint;
  final IconData icon;
  final String? error;
  final bool obscureText;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final Widget? suffixIcon;

  const _PremiumField({
    required this.controller, required this.focusNode,
    required this.label,      required this.hint,
    required this.icon,
    this.error,
    this.obscureText    = false,
    this.keyboardType   = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.onChanged, this.onSubmitted, this.suffixIcon,
  });

  @override
  State<_PremiumField> createState() => _PremiumFieldState();
}

class _PremiumFieldState extends State<_PremiumField>
    with SingleTickerProviderStateMixin {
  late AnimationController _bCtrl;
  late Animation<double>   _bAnim;
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _bCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 200));
    _bAnim = CurvedAnimation(parent: _bCtrl, curve: Curves.easeOut);
    widget.focusNode.addListener(_onFocus);
  }

  void _onFocus() {
    setState(() => _focused = widget.focusNode.hasFocus);
    _focused ? _bCtrl.forward() : _bCtrl.reverse();
  }

  @override
  void dispose() {
    _bCtrl.dispose();
    widget.focusNode.removeListener(_onFocus);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasErr = widget.error != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedBuilder(
          animation: _bAnim,
          builder: (_, child) {
            final bc = hasErr
                ? _C.error
                : Color.lerp(_C.border, _C.borderF, _bAnim.value)!;
            return Container(
              height: 62,
              decoration: BoxDecoration(
                  color: _C.surface,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: bc, width: 1)),
              child: child);
          },
          child: Row(children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Icon(widget.icon, color: _C.w35, size: 18)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(widget.label,
                      style: TextStyle(
                          fontFamily: 'Georgia', fontSize: 9.5,
                          color: _focused ? _C.w60 : _C.w35,
                          letterSpacing: 1.5)),
                  const SizedBox(height: 2),
                  TextField(
                    controller: widget.controller,
                    focusNode: widget.focusNode,
                    obscureText: widget.obscureText,
                    keyboardType: widget.keyboardType,
                    textInputAction: widget.textInputAction,
                    onChanged: widget.onChanged,
                    onSubmitted: widget.onSubmitted,
                    style: const TextStyle(
                        fontFamily: 'Georgia', color: Colors.white,
                        fontSize: 15, letterSpacing: 0.3, height: 1),
                    cursorColor: Colors.white,
                    decoration: InputDecoration(
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                        border: InputBorder.none,
                        hintText: widget.hint,
                        hintStyle: TextStyle(
                            fontFamily: 'Georgia', color: _C.w15,
                            fontSize: 14, letterSpacing: 0.2))),
                ])),
            if (widget.suffixIcon != null) widget.suffixIcon!,
          ]),
        ),
        if (hasErr) ...[
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Row(children: [
              Icon(Icons.error_outline, color: _C.error, size: 12),
              const SizedBox(width: 5),
              Text(widget.error!,
                  style: TextStyle(
                      fontFamily: 'Georgia', fontSize: 11,
                      color: _C.error, letterSpacing: 0.2)),
            ])),
        ],
      ]);
  }
}

// ─────────────────────────────────────────────
//  Press scale wrapper
// ─────────────────────────────────────────────
class _Press extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  const _Press({required this.child, this.onTap});
  @override
  State<_Press> createState() => _PressState();
}

class _PressState extends State<_Press> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 90));
  late final Animation<double> _s =
      Tween<double>(begin: 1.0, end: 0.97)
          .animate(CurvedAnimation(parent: _c, curve: Curves.easeOut));
  @override
  void dispose() { _c.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => GestureDetector(
      onTapDown: (_) { if (widget.onTap != null) _c.forward(); },
      onTapUp:   (_) { _c.reverse(); widget.onTap?.call(); },
      onTapCancel:   () => _c.reverse(),
      child: ScaleTransition(scale: _s, child: widget.child));
}