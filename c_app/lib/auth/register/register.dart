import 'package:c_app/auth/login/login_screen.dart';
import 'package:c_app/auth/register/registerservice.dart';
import 'package:c_app/auth/register/verify_otp.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ─────────────────────────────────────────────
//  Color constants
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
//  RegisterScreen
// ─────────────────────────────────────────────
class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {

  final _usernameCtrl = TextEditingController();
  final _emailCtrl    = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _usernameFN   = FocusNode();
  final _emailFN      = FocusNode();
  final _passwordFN   = FocusNode();
  final _api          = ApiService();

  bool _isLoading       = false;
  bool _obscurePassword = true;
  String? _usernameErr;
  String? _emailErr;
  String? _passwordErr;

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
      curve: Interval(i * 0.12, (i * 0.12 + 0.55).clamp(0,1), curve: Curves.easeOut)));
    _slides = List.generate(5, (i) => Tween<Offset>(
      begin: const Offset(0, 0.06), end: Offset.zero).animate(CurvedAnimation(
      parent: _entry,
      curve: Interval(i * 0.12, (i * 0.12 + 0.55).clamp(0,1), curve: Curves.easeOut))));
    _entry.forward();
  }

  @override
  void dispose() {
    _entry.dispose();
    _usernameCtrl.dispose(); _emailCtrl.dispose(); _passwordCtrl.dispose();
    _usernameFN.dispose();   _emailFN.dispose();   _passwordFN.dispose();
    super.dispose();
  }

  // ── Validation ──────────────────────────────
  bool _validate() {
    bool ok = true;
    setState(() {
      _usernameErr = _emailErr = _passwordErr = null;
      final u = _usernameCtrl.text.trim();
      final e = _emailCtrl.text.trim();
      final p = _passwordCtrl.text;
      if (u.isEmpty)        { _usernameErr = 'Username is required';        ok = false; }
      else if (u.length < 3){ _usernameErr = 'At least 3 characters';       ok = false; }
      if (e.isEmpty)        { _emailErr    = 'Email is required';            ok = false; }
      else if (!RegExp(r'^[\w.+-]+@[\w-]+\.[a-z]{2,}$').hasMatch(e))
                            { _emailErr    = 'Enter a valid email address';  ok = false; }
      if (p.isEmpty)        { _passwordErr = 'Password is required';         ok = false; }
      else if (p.length < 8){ _passwordErr = 'Minimum 8 characters';         ok = false; }
    });
    return ok;
  }

  void _goToLogin() {
    HapticFeedback.lightImpact();
    Navigator.push(context, PageRouteBuilder(
      pageBuilder: (_, __, ___) => LoginScreen(),
      transitionsBuilder: (_, a, __, c) => FadeTransition(opacity: a, child: c),
      transitionDuration: const Duration(milliseconds: 380)));
  }

  Future<void> _register() async {
    if (!_validate()) { HapticFeedback.mediumImpact(); return; }
    HapticFeedback.lightImpact();
    setState(() => _isLoading = true);
    final ok = await _api.register(
      _usernameCtrl.text.trim(), _emailCtrl.text.trim(), _passwordCtrl.text);
    if (!mounted) return;
    setState(() => _isLoading = false);
    if (ok) {
      Navigator.push(context, MaterialPageRoute(
        builder: (_) => OtpScreen(email: _emailCtrl.text.trim())));
    } else {
      _snack('Registration failed. Please try again.');
    }
  }

  void _snack(String msg) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(msg, style: const TextStyle(color: Colors.white, fontFamily: 'Georgia', fontSize: 13)),
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
                    _anim(2, _buildFields()),
                    const SizedBox(height: 28),
                    _anim(3, _buildCtas()),
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
        // Logo mark
        Container(
          width: 46, height: 46,
          decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(11)),
          child: const Center(
            child: Text('C',
              style: TextStyle(
                fontFamily: 'Georgia', fontSize: 26, color: Colors.black,
                fontWeight: FontWeight.w700, height: 1, letterSpacing: -0.5)))),
        const SizedBox(width: 13),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('CODOLOG',
              style: TextStyle(
                fontFamily: 'Georgia', fontSize: 25, color: Colors.white,
                fontWeight: FontWeight.w600, letterSpacing: 3)),
            Text('Always Learn Unique',
              style: TextStyle(
                fontFamily: 'Georgia', fontSize: 10,
                color: _C.w35, letterSpacing: 1.5)),
          ],
        ),
        const Spacer(),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(width: 22, height: 1.5, color: Colors.white),
            const SizedBox(height: 5),
            Container(width: 11, height: 1.5, color: _C.w35),
          ],
        ),
      ],
    ),
  );

  // ─────────────────────────────────────────────
  //  Headline
  // ─────────────────────────────────────────────
  Widget _buildHeadline() => Padding(
    padding: const EdgeInsets.fromLTRB(28, 44, 28, 0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('CREATE\nACCOUNT',
          style: TextStyle(
            fontFamily: 'Georgia', fontSize: 40, color: Colors.white,
            fontWeight: FontWeight.w300, height: 0.95, letterSpacing: -1.5)),
        const SizedBox(height: 14),
        Text('Join thousands of professionals\nalready on the platform.',
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
      ],
    ),
  );

  // ─────────────────────────────────────────────
  //  Fields
  // ─────────────────────────────────────────────
  Widget _buildFields() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 28),
    child: Column(
      children: [
        _PremiumField(
          controller: _usernameCtrl, focusNode: _usernameFN,
          label: 'Username', hint: 'e.g. johndoe',
          icon: Icons.person_outline_rounded,
          error: _usernameErr,
          textInputAction: TextInputAction.next,
          onChanged: (_) { if (_usernameErr != null) setState(() => _usernameErr = null); },
          onSubmitted: (_) => FocusScope.of(context).requestFocus(_emailFN)),
        const SizedBox(height: 14),
        _PremiumField(
          controller: _emailCtrl, focusNode: _emailFN,
          label: 'Email address', hint: 'you@example.com',
          icon: Icons.mail_outline_rounded,
          error: _emailErr,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          onChanged: (_) { if (_emailErr != null) setState(() => _emailErr = null); },
          onSubmitted: (_) => FocusScope.of(context).requestFocus(_passwordFN)),
        const SizedBox(height: 14),
        _PremiumField(
          controller: _passwordCtrl, focusNode: _passwordFN,
          label: 'Password', hint: '8+ characters',
          icon: Icons.lock_outline_rounded,
          error: _passwordErr,
          obscureText: _obscurePassword,
          textInputAction: TextInputAction.done,
          onChanged: (_) { if (_passwordErr != null) setState(() => _passwordErr = null); },
          onSubmitted: (_) => _register(),
          suffixIcon: GestureDetector(
            onTap: () => setState(() => _obscurePassword = !_obscurePassword),
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Icon(
                _obscurePassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: _C.w35, size: 18)))),
      ],
    ),
  );

  // ─────────────────────────────────────────────
  //  CTAs
  // ─────────────────────────────────────────────
  Widget _buildCtas() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 28),
    child: Column(
      children: [
        // Register
        _Press(
          onTap: _isLoading ? null : _register,
          child: Container(
            width: double.infinity, height: 56,
            decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(6)),
            child: Center(
              child: _isLoading
                ? const SizedBox(width: 20, height: 20,
                    child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
                : const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('CREATE ACCOUNT',
                        style: TextStyle(
                          fontFamily: 'Georgia', color: Colors.black,
                          fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 2.5)),
                      SizedBox(width: 10),
                      Icon(Icons.arrow_forward, color: Colors.black, size: 14),
                    ])))),
        const SizedBox(height: 16),
        // Divider
        Row(children: [
          Expanded(child: Divider(color: _C.w15, thickness: 1)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Text('OR',
              style: TextStyle(fontFamily: 'Georgia', fontSize: 9,
                color: _C.w35, letterSpacing: 3))),
          Expanded(child: Divider(color: _C.w15, thickness: 1)),
        ]),
        const SizedBox(height: 16),
        // Login
        _Press(
          onTap: _goToLogin,
          child: Container(
            width: double.infinity, height: 56,
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: _C.border, width: 1)),
            child: Center(
              child: RichText(
                text: TextSpan(
                  style: const TextStyle(fontFamily: 'Georgia', fontSize: 13, letterSpacing: 0.3),
                  children: [
                    TextSpan(text: 'Already have an account?  ', style: TextStyle(color: _C.w35)),
                    const TextSpan(text: 'Sign in',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, letterSpacing: 1)),
                  ]))))),
      ],
    ),
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
      Text('By creating an account you agree to our\nTerms of Service and Privacy Policy.',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: 'Georgia', fontSize: 11, color: _C.w35, height: 1.7, letterSpacing: 0.2)),
    ]),
  );
}

// ─────────────────────────────────────────────
//  Premium Field
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
    required this.label, required this.hint, required this.icon,
    this.error, this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.onChanged, this.onSubmitted, this.suffixIcon,
  });

  @override
  State<_PremiumField> createState() => _PremiumFieldState();
}

class _PremiumFieldState extends State<_PremiumField>
    with SingleTickerProviderStateMixin {
  late AnimationController _bCtrl;
  late Animation<double> _bAnim;
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _bCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 200));
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
          child: Row(
            children: [
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
      Tween<double>(begin: 1.0, end: 0.97).animate(
          CurvedAnimation(parent: _c, curve: Curves.easeOut));

  @override
  void dispose() { _c.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTapDown: (_) { if (widget.onTap != null) _c.forward(); },
    onTapUp: (_)  { _c.reverse(); widget.onTap?.call(); },
    onTapCancel:  () => _c.reverse(),
    child: ScaleTransition(scale: _s, child: widget.child));
}