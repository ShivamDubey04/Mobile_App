import 'package:c_app/Homescreen/homescreen.dart';
import 'package:c_app/auth/register/registerservice.dart';
import 'package:c_app/auth/register/tokenstorageservice.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ─────────────────────────────────────────────
//  Color constants  (matches app design system)
// ─────────────────────────────────────────────
class _C {
  static const bg      = Color(0xFF0A0A0A);
  static const surface = Color(0xFF141414);
  static const border  = Color(0xFF2A2A2A);
  static const white   = Color(0xFFFFFFFF);
  static const w60     = Color(0x99FFFFFF);
  static const w35     = Color(0x59FFFFFF);
  static const w15     = Color(0x26FFFFFF);
  static const w08     = Color(0x14FFFFFF);
  static const error   = Color(0xFFE05555);
  static const success = Color(0xFF4CAF7D);
}

// ─────────────────────────────────────────────
//  OtpScreen  (Registration verification)
// ─────────────────────────────────────────────
class OtpScreen extends StatefulWidget {
  final String email;
  const OtpScreen({required this.email});

  @override
  _OtpScreenState createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen>
    with TickerProviderStateMixin {

  final List<TextEditingController> _boxCtrl =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _boxFN =
      List.generate(6, (_) => FocusNode());

  final _api          = ApiService();
  final _tokenService = TokenService();

  bool   _isLoading = false;
  bool   _hasError  = false;

  // Entry stagger
  late AnimationController _entry;
  late List<Animation<double>>  _fades;
  late List<Animation<Offset>>  _slides;

  // Shake on wrong OTP
  late AnimationController _shakeCtrl;
  late Animation<double>   _shakeAnim;

  // Success pulse on correct OTP
  late AnimationController _successCtrl;
  late Animation<double>   _successAnim;

  @override
  void initState() {
    super.initState();

    // Entry stagger
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

    // Shake
    _shakeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    _shakeAnim = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.0,   end: -10.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -10.0, end:  10.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin:  10.0, end: -10.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -10.0, end:  10.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin:  10.0, end:   0.0), weight: 1),
    ]).animate(CurvedAnimation(parent: _shakeCtrl, curve: Curves.easeOut));

    // Success scale pulse
    _successCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));
    _successAnim = Tween<double>(begin: 1.0, end: 1.04).animate(
        CurvedAnimation(parent: _successCtrl, curve: Curves.easeOut));

    _entry.forward();
  }

  @override
  void dispose() {
    _entry.dispose();
    _shakeCtrl.dispose();
    _successCtrl.dispose();
    for (final c in _boxCtrl) c.dispose();
    for (final f in _boxFN)   f.dispose();
    super.dispose();
  }

  // ── OTP box input ────────────────────────────
  void _onBoxChanged(String val, int index) {
    if (_hasError) setState(() => _hasError = false);
    if (val.length == 1 && index < 5) {
      _boxFN[index + 1].requestFocus();
    } else if (val.length == 1 && index == 5) {
      _boxFN[index].unfocus();
      _verifyOtp(); // auto-submit on last digit
    }
  }

  void _onBoxBackspace(int index) {
    if (_boxCtrl[index].text.isEmpty && index > 0) {
      _boxFN[index - 1].requestFocus();
      _boxCtrl[index - 1].clear();
    }
  }

  void _clearBoxes() {
    for (final c in _boxCtrl) c.clear();
    _boxFN[0].requestFocus();
  }

  // ── Verify ───────────────────────────────────
  Future<void> _verifyOtp() async {
    final otp = _boxCtrl.map((c) => c.text).join();
    if (otp.length < 6) {
      HapticFeedback.mediumImpact();
      setState(() => _hasError = true);
      _shakeCtrl.forward(from: 0);
      return;
    }

    HapticFeedback.lightImpact();
    setState(() { _isLoading = true; _hasError = false; });

    final result = await _api.verifyOtp(widget.email, otp);
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result != null) {
      final accessToken  = result['token'];
      final refreshToken = result['refreshToken'];
      await _tokenService.saveTokens(accessToken, refreshToken);

      // Brief success pulse before navigation
      await _successCtrl.forward();
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
            pageBuilder: (_, __, ___) => HomeScreen(),
            transitionsBuilder: (_, a, __, c) =>
                FadeTransition(opacity: a, child: c),
            transitionDuration: const Duration(milliseconds: 500)));
    } else {
      HapticFeedback.mediumImpact();
      setState(() => _hasError = true);
      _shakeCtrl.forward(from: 0);
      _clearBoxes();
      _snack('Invalid OTP. Please check and try again.');
    }
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
                    _anim(2, _buildEmailChip()),
                    const SizedBox(height: 32),
                    _anim(2, _buildOtpBoxes()),
                    const SizedBox(height: 28),
                    _anim(3, _buildVerifyButton()),
                    const SizedBox(height: 20),
                    _anim(3, _buildHelpRow()),
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
    child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
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
    ]),
  );

  // ─────────────────────────────────────────────
  //  Headline
  // ─────────────────────────────────────────────
  Widget _buildHeadline() => Padding(
    padding: const EdgeInsets.fromLTRB(28, 44, 28, 0),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Registration step badge
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
            border: Border.all(color: _C.w15, width: 1),
            borderRadius: BorderRadius.circular(20)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 6, height: 6,
              decoration: const BoxDecoration(
                  color: _C.success, shape: BoxShape.circle)),
          const SizedBox(width: 7),
          Text('Step 2 of 2 — Verify email',
              style: TextStyle(
                  fontFamily: 'Georgia', fontSize: 10,
                  color: _C.w60, letterSpacing: 0.5)),
        ]),
      ),
      const SizedBox(height: 16),
      const Text('ALMOST\nTHERE',
          style: TextStyle(
              fontFamily: 'Georgia', fontSize: 40, color: Colors.white,
              fontWeight: FontWeight.w300, height: 0.95, letterSpacing: -1.5)),
      const SizedBox(height: 14),
      Text('Enter the 6-digit code sent to verify\nyour new account.',
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
  //  Email chip
  // ─────────────────────────────────────────────
  Widget _buildEmailChip() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 28),
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
          color: _C.w08,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: _C.w15, width: 1)),
      child: Row(children: [
        Icon(Icons.mark_email_unread_outlined, color: _C.w35, size: 15),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('OTP sent to',
                  style: TextStyle(
                      fontFamily: 'Georgia', fontSize: 10,
                      color: _C.w35, letterSpacing: 0.5)),
              const SizedBox(height: 2),
              Text(widget.email,
                  style: TextStyle(
                      fontFamily: 'Georgia', fontSize: 13,
                      color: _C.w60, letterSpacing: 0.3)),
            ])),
        // Inbox icon indicator
        Container(
          width: 30, height: 30,
          decoration: BoxDecoration(
              color: _C.success.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(
                  color: _C.success.withOpacity(0.3), width: 1)),
          child: Center(
              child: Icon(Icons.inbox_outlined,
                  color: _C.success, size: 14))),
      ]),
    ),
  );

  // ─────────────────────────────────────────────
  //  OTP boxes
  // ─────────────────────────────────────────────
  Widget _buildOtpBoxes() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 28),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('ONE-TIME CODE',
          style: TextStyle(
              fontFamily: 'Georgia', fontSize: 9.5,
              color: _C.w35, letterSpacing: 2)),
      const SizedBox(height: 12),
      AnimatedBuilder(
        animation: _shakeAnim,
        builder: (_, child) => Transform.translate(
            offset: Offset(_shakeAnim.value, 0), child: child),
        child: ScaleTransition(
          scale: _successAnim,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(6, (i) => _OtpBox(
              controller:    _boxCtrl[i],
              focusNode:     _boxFN[i],
              hasError:      _hasError,
              onChanged:     (v) => _onBoxChanged(v, i),
              onBackspace:   () => _onBoxBackspace(i),
              isLastInGroup: i == 2,
            )),
          ),
        ),
      ),
      if (_hasError) ...[
        const SizedBox(height: 8),
        Row(children: [
          const Icon(Icons.error_outline, color: _C.error, size: 12),
          const SizedBox(width: 5),
          Text('Incorrect code. Please try again.',
              style: TextStyle(
                  fontFamily: 'Georgia', fontSize: 11,
                  color: _C.error, letterSpacing: 0.2)),
        ]),
      ],
    ]),
  );

  // ─────────────────────────────────────────────
  //  Verify button
  // ─────────────────────────────────────────────
  Widget _buildVerifyButton() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 28),
    child: _Press(
      onTap: _isLoading ? null : _verifyOtp,
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
                    Text('VERIFY & CONTINUE',
                        style: TextStyle(
                            fontFamily: 'Georgia', color: Colors.black,
                            fontSize: 12, fontWeight: FontWeight.w700,
                            letterSpacing: 2.5)),
                    SizedBox(width: 10),
                    Icon(Icons.verified_user_outlined,
                        color: Colors.black, size: 15),
                  ])),
      ),
    ),
  );

  // ─────────────────────────────────────────────
  //  Help row
  // ─────────────────────────────────────────────
  Widget _buildHelpRow() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 28),
    child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(Icons.help_outline_rounded, color: _C.w35, size: 14),
      const SizedBox(width: 8),
      Text("Didn't receive the code?  ",
          style: TextStyle(
              fontFamily: 'Georgia', fontSize: 13, color: _C.w35)),
      _Press(
        onTap: () => Navigator.pop(context),
        child: Text('Go back',
            style: const TextStyle(
                fontFamily: 'Georgia', fontSize: 13, color: Colors.white,
                fontWeight: FontWeight.w700, letterSpacing: 0.5,
                decoration: TextDecoration.underline,
                decorationColor: Colors.white))),
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
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.shield_outlined, color: _C.w35, size: 13),
        const SizedBox(width: 7),
        Text('OTP codes expire after 10 minutes.',
            style: TextStyle(
                fontFamily: 'Georgia', fontSize: 11,
                color: _C.w35, letterSpacing: 0.2)),
      ]),
    ]),
  );
}

// ─────────────────────────────────────────────
//  Individual OTP digit box
// ─────────────────────────────────────────────
class _OtpBox extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool hasError;
  final ValueChanged<String> onChanged;
  final VoidCallback onBackspace;
  final bool isLastInGroup;

  const _OtpBox({
    required this.controller,
    required this.focusNode,
    required this.hasError,
    required this.onChanged,
    required this.onBackspace,
    this.isLastInGroup = false,
  });

  @override
  State<_OtpBox> createState() => _OtpBoxState();
}

class _OtpBoxState extends State<_OtpBox>
    with SingleTickerProviderStateMixin {
  late AnimationController _bCtrl;
  late Animation<double>   _bAnim;
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _bCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 180));
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
    final filled = widget.controller.text.isNotEmpty;
    final hasErr = widget.hasError;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: _bAnim,
          builder: (_, child) {
            final borderColor = hasErr
                ? const Color(0xFFE05555)
                : _focused
                    ? Colors.white
                    : filled
                        ? const Color(0xFF888888)
                        : const Color(0xFF2A2A2A);
            return AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 44, height: 54,
              decoration: BoxDecoration(
                  color: hasErr
                      ? const Color(0xFFE05555).withOpacity(0.06)
                      : filled
                          ? const Color(0xFF1E1E1E)
                          : const Color(0xFF141414),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: borderColor,
                      width: _focused ? 1.5 : 1)),
              child: child);
          },
          child: KeyboardListener(
            focusNode: FocusNode(),
            onKeyEvent: (e) {
              if (e is KeyDownEvent &&
                  e.logicalKey == LogicalKeyboardKey.backspace) {
                widget.onBackspace();
              }
            },
            child: TextField(
              controller: widget.controller,
              focusNode: widget.focusNode,
              maxLength: 1,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChanged: widget.onChanged,
              style: const TextStyle(
                  fontFamily: 'Georgia', color: Colors.white,
                  fontSize: 20, fontWeight: FontWeight.w600,
                  height: 1, letterSpacing: 0),
              cursorColor: Colors.white,
              cursorWidth: 1.5,
              decoration: const InputDecoration(
                  border: InputBorder.none,
                  counterText: '',
                  contentPadding: EdgeInsets.zero),
            ),
          ),
        ),
        if (widget.isLastInGroup)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Text('–',
                style: TextStyle(
                    color: const Color(0xFF2A2A2A),
                    fontSize: 16, fontWeight: FontWeight.w300))),
      ],
    );
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