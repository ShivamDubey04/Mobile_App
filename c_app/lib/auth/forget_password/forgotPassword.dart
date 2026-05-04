import 'package:c_app/auth/login/login_api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ─────────────────────────────────────────────
//  Color constants  (matches app design system)
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
  static const success = Color(0xFF4CAF7D);
}

// ─────────────────────────────────────────────
//  ForgotPasswordScreen
// ─────────────────────────────────────────────
class ForgotPasswordScreen extends StatefulWidget {
  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen>
    with SingleTickerProviderStateMixin {

  final _emailCtrl = TextEditingController();
  final _emailFN   = FocusNode();
  final _api       = LoginApiService();

  bool    _isLoading = false;
  String? _emailErr;

  late AnimationController _entry;
  late List<Animation<double>>  _fades;
  late List<Animation<Offset>>  _slides;

  @override
  void initState() {
    super.initState();
    _entry = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1000));
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
  bool _validate() {
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

  // ── Send reset link ──────────────────────────
  Future<void> _sendResetLink() async {
    if (!_validate()) { HapticFeedback.mediumImpact(); return; }
    HapticFeedback.lightImpact();
    setState(() => _isLoading = true);

    final success = await _api.forgotPassword(_emailCtrl.text.trim());

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      _showSuccessDialog();
    } else {
      _snack('Failed to send reset email. Please try again.');
    }
  }

  // ── Success dialog ───────────────────────────
  void _showSuccessDialog() {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black87,
      transitionDuration: const Duration(milliseconds: 350),
      transitionBuilder: (_, anim, __, child) => ScaleTransition(
          scale: CurvedAnimation(parent: anim, curve: Curves.easeOutBack),
          child: FadeTransition(opacity: anim, child: child)),
      pageBuilder: (_, __, ___) => Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 32),
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
                color: _C.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _C.border, width: 1)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Icon ──
                Container(
                  width: 64, height: 64,
                  decoration: BoxDecoration(
                      color: _C.success.withOpacity(0.12),
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: _C.success.withOpacity(0.4), width: 1)),
                  child: Center(
                      child: Icon(Icons.mark_email_read_outlined,
                          color: _C.success, size: 28))),
                const SizedBox(height: 20),
                // ── Title ──
                const Text('Check Your Inbox',
                    style: TextStyle(
                        fontFamily: 'Georgia', fontSize: 20,
                        color: Colors.white, fontWeight: FontWeight.w600,
                        letterSpacing: -0.5)),
                const SizedBox(height: 12),
                // ── Body ──
                Text(
                  'A password reset link has been sent to\n${_emailCtrl.text.trim()}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontFamily: 'Georgia', fontSize: 13,
                      color: _C.w35, height: 1.65, letterSpacing: 0.2)),
                const SizedBox(height: 8),
                Text('Please check your inbox and spam folder.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontFamily: 'Georgia', fontSize: 12,
                        color: _C.w15, letterSpacing: 0.1)),
                const SizedBox(height: 28),
                Divider(color: _C.w08, thickness: 1),
                const SizedBox(height: 20),
                // ── CTA ──
                _Press(
                  onTap: () {
                    Navigator.pop(context); // close dialog
                    Navigator.pop(context); // go back to login
                  },
                  child: Container(
                    width: double.infinity, height: 50,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6)),
                    child: const Center(
                      child: Text('BACK TO LOGIN',
                          style: TextStyle(
                              fontFamily: 'Georgia', color: Colors.black,
                              fontSize: 11, fontWeight: FontWeight.w700,
                              letterSpacing: 2.5))))),
              ],
            ),
          ),
        ),
      ),
    );
  }

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
                    _anim(2, _buildInfoCard()),
                    const SizedBox(height: 20),
                    _anim(2, _buildEmailField()),
                    const SizedBox(height: 28),
                    _anim(3, _buildSendButton()),
                    const SizedBox(height: 12),
                    _anim(3, _buildBackButton()),
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
        _Press(
          onTap: () => Navigator.pop(context),
          child: Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
                color: _C.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _C.border, width: 1)),
            child: const Center(
                child: Icon(Icons.arrow_back_ios_new_rounded,
                    color: Colors.white, size: 14)))),
        const SizedBox(width: 16),
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(10)),
          child: const Center(
              child: Text('C',
                  style: TextStyle(
                      fontFamily: 'Georgia', fontSize: 22,
                      color: Colors.black, fontWeight: FontWeight.w700,
                      height: 1)))),
        const SizedBox(width: 11),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('CAPP',
              style: TextStyle(
                  fontFamily: 'Georgia', fontSize: 14, color: Colors.white,
                  fontWeight: FontWeight.w600, letterSpacing: 3)),
          Text('Premium Platform',
              style: TextStyle(
                  fontFamily: 'Georgia', fontSize: 9,
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
      const Text('FORGOT\nPASSWORD',
          style: TextStyle(
              fontFamily: 'Georgia', fontSize: 40, color: Colors.white,
              fontWeight: FontWeight.w300, height: 0.95, letterSpacing: -1.5)),
      const SizedBox(height: 14),
      Text('No worries. We\'ll send a reset link\nstraight to your inbox.',
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
  //  Info card  (steps)
  // ─────────────────────────────────────────────
  Widget _buildInfoCard() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 28),
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: _C.w08,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: _C.w15, width: 1)),
      child: Column(children: [
        _Step(number: '1', text: 'Enter your registered email address below'),
        const SizedBox(height: 14),
        _StepDivider(),
        const SizedBox(height: 14),
        _Step(number: '2', text: 'Open the reset link sent to your inbox'),
        const SizedBox(height: 14),
        _StepDivider(),
        const SizedBox(height: 14),
        _Step(number: '3', text: 'Create a new secure password and sign in'),
      ]),
    ),
  );

  // ─────────────────────────────────────────────
  //  Email field
  // ─────────────────────────────────────────────
  Widget _buildEmailField() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 28),
    child: _PremiumField(
      controller: _emailCtrl,
      focusNode: _emailFN,
      label: 'Registered email address',
      hint: 'you@example.com',
      icon: Icons.mail_outline_rounded,
      error: _emailErr,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.done,
      onChanged: (_) { if (_emailErr != null) setState(() => _emailErr = null); },
      onSubmitted: (_) => _sendResetLink(),
    ),
  );

  // ─────────────────────────────────────────────
  //  Send button
  // ─────────────────────────────────────────────
  Widget _buildSendButton() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 28),
    child: _Press(
      onTap: _isLoading ? null : _sendResetLink,
      child: Container(
        width: double.infinity, height: 56,
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(6)),
        child: Center(
          child: _isLoading
              ? const SizedBox(
                  width: 20, height: 20,
                  child: CircularProgressIndicator(
                      color: Colors.black, strokeWidth: 2))
              : const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('SEND RESET LINK',
                        style: TextStyle(
                            fontFamily: 'Georgia', color: Colors.black,
                            fontSize: 12, fontWeight: FontWeight.w700,
                            letterSpacing: 2.5)),
                    SizedBox(width: 10),
                    Icon(Icons.send_rounded, color: Colors.black, size: 14),
                  ])),
      ),
    ),
  );

  // ─────────────────────────────────────────────
  //  Back to login
  // ─────────────────────────────────────────────
  Widget _buildBackButton() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 28),
    child: _Press(
      onTap: () => Navigator.pop(context),
      child: Container(
        width: double.infinity, height: 50,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: _C.border, width: 1)),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.arrow_back_rounded, color: _C.w35, size: 14),
              const SizedBox(width: 8),
              Text('Back to Login',
                  style: TextStyle(
                      fontFamily: 'Georgia', fontSize: 13,
                      color: _C.w35, letterSpacing: 0.3)),
            ],
          ),
        ),
      ),
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
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.shield_outlined, color: _C.w35, size: 13),
        const SizedBox(width: 7),
        Text('Reset links expire after 15 minutes.',
            style: TextStyle(
                fontFamily: 'Georgia', fontSize: 11,
                color: _C.w35, letterSpacing: 0.2)),
      ]),
    ]),
  );
}

// ─────────────────────────────────────────────
//  Step row widget
// ─────────────────────────────────────────────
class _Step extends StatelessWidget {
  final String number;
  final String text;
  const _Step({required this.number, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 22, height: 22,
          decoration: BoxDecoration(
              border: Border.all(color: const Color(0x59FFFFFF), width: 1),
              shape: BoxShape.circle),
          child: Center(
              child: Text(number,
                  style: const TextStyle(
                      fontFamily: 'Georgia', fontSize: 10,
                      color: Colors.white, fontWeight: FontWeight.w600)))),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 3),
            child: Text(text,
                style: const TextStyle(
                    fontFamily: 'Georgia', fontSize: 12,
                    color: Color(0x59FFFFFF), height: 1.5,
                    letterSpacing: 0.2)))),
      ]);
  }
}

class _StepDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Row(children: [
    const SizedBox(width: 10),
    Container(width: 2, height: 10, color: const Color(0x14FFFFFF)),
  ]);
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
    required this.label,      required this.hint,
    required this.icon,
    this.error,
    this.obscureText     = false,
    this.keyboardType    = TextInputType.text,
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
                ? const Color(0xFFE05555)
                : Color.lerp(const Color(0xFF2A2A2A),
                    const Color(0xFF888888), _bAnim.value)!;
            return Container(
              height: 62,
              decoration: BoxDecoration(
                  color: const Color(0xFF141414),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: bc, width: 1)),
              child: child);
          },
          child: Row(children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Icon(widget.icon,
                  color: const Color(0x59FFFFFF), size: 18)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(widget.label,
                      style: TextStyle(
                          fontFamily: 'Georgia', fontSize: 9.5,
                          color: _focused
                              ? const Color(0x99FFFFFF)
                              : const Color(0x59FFFFFF),
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
                          hintStyle: const TextStyle(
                              fontFamily: 'Georgia',
                              color: Color(0x26FFFFFF),
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
              const Icon(Icons.error_outline,
                  color: Color(0xFFE05555), size: 12),
              const SizedBox(width: 5),
              Text(widget.error!,
                  style: const TextStyle(
                      fontFamily: 'Georgia', fontSize: 11,
                      color: Color(0xFFE05555), letterSpacing: 0.2)),
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
  late final AnimationController _c = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 90));
  late final Animation<double> _s = Tween<double>(begin: 1.0, end: 0.97)
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