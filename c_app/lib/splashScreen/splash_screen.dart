import 'package:c_app/Homescreen/homescreen.dart';
import 'package:c_app/onBoard/onboarding_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {

  final _storage = const FlutterSecureStorage();

  // ── Animation controllers ──────────────────
  late AnimationController _logoCtrl;
  late AnimationController _textCtrl;
  late AnimationController _sloganCtrl;
  late AnimationController _lineCtrl;
  late AnimationController _dotCtrl;
  late AnimationController _pulseCtrl;

  // Logo
  late Animation<double>  _logoScale;
  late Animation<double>  _logoFade;
  late Animation<double>  _logoRotate;

  // Brand name letters reveal
  late Animation<double>  _textFade;
  late Animation<Offset>  _textSlide;
  late Animation<double>  _textSpacing;

  // Slogan
  late Animation<double>  _sloganFade;
  late Animation<Offset>  _sloganSlide;

  // Decorative line
  late Animation<double>  _lineWidth;

  // Loading dots
  late Animation<double>  _dotFade;

  // Pulse ring around logo
  late Animation<double>  _pulseScale;
  late Animation<double>  _pulseFade;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _setupAnimations();
    _runSequence();
  }

  void _setupAnimations() {
    // Logo entrance
    _logoCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));
    _logoScale  = Tween<double>(begin: 0.6, end: 1.0).animate(
        CurvedAnimation(parent: _logoCtrl, curve: Curves.elasticOut));
    _logoFade   = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _logoCtrl,
            curve: const Interval(0.0, 0.5, curve: Curves.easeOut)));
    _logoRotate = Tween<double>(begin: -0.05, end: 0.0).animate(
        CurvedAnimation(parent: _logoCtrl, curve: Curves.easeOut));

    // Pulse ring
    _pulseCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200));
    _pulseScale = Tween<double>(begin: 1.0, end: 1.6).animate(
        CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeOut));
    _pulseFade  = Tween<double>(begin: 0.4, end: 0.0).animate(
        CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeOut));

    // Brand name
    _textCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _textFade    = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _textCtrl, curve: Curves.easeOut));
    _textSlide   = Tween<Offset>(begin: const Offset(0, 0.4), end: Offset.zero)
        .animate(CurvedAnimation(parent: _textCtrl, curve: Curves.easeOut));
    _textSpacing = Tween<double>(begin: 8.0, end: 4.0).animate(
        CurvedAnimation(parent: _textCtrl, curve: Curves.easeOut));

    // Decorative line
    _lineCtrl  = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _lineWidth = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _lineCtrl, curve: Curves.easeInOut));

    // Slogan
    _sloganCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _sloganFade  = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _sloganCtrl, curve: Curves.easeOut));
    _sloganSlide = Tween<Offset>(
        begin: const Offset(0, 0.3), end: Offset.zero)
        .animate(CurvedAnimation(parent: _sloganCtrl, curve: Curves.easeOut));

    // Loading dots
    _dotCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _dotFade = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _dotCtrl, curve: Curves.easeOut));
  }

  Future<void> _runSequence() async {
    // 1. Logo pops in
    await Future.delayed(const Duration(milliseconds: 200));
    _logoCtrl.forward();

    // 2. Pulse ring fires once
    await Future.delayed(const Duration(milliseconds: 400));
    _pulseCtrl.forward();

    // 3. Brand name slides up
    await Future.delayed(const Duration(milliseconds: 600));
    _textCtrl.forward();

    // 4. Decorative line expands
    await Future.delayed(const Duration(milliseconds: 300));
    _lineCtrl.forward();

    // 5. Slogan fades in
    await Future.delayed(const Duration(milliseconds: 200));
    _sloganCtrl.forward();

    // 6. Loading dots appear
    await Future.delayed(const Duration(milliseconds: 300));
    _dotCtrl.forward();

    // 7. Check auth & navigate
    await _checkLogin();
  }

  Future<void> _checkLogin() async {
    // Minimum display time from dot appearance = 1.2s
    await Future.delayed(const Duration(milliseconds: 1200));

    final token = await _storage.read(key: 'accessToken');
    if (!mounted) return;

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    final destination = (token != null && token.isNotEmpty)
        ? HomeScreen()
        : OnboardingScreen();

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
          pageBuilder: (_, __, ___) => destination,
          transitionsBuilder: (_, anim, __, child) =>
              FadeTransition(opacity: anim, child: child),
          transitionDuration: const Duration(milliseconds: 600)),
    );
  }

  @override
  void dispose() {
    _logoCtrl.dispose();
    _textCtrl.dispose();
    _sloganCtrl.dispose();
    _lineCtrl.dispose();
    _dotCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: const Color(0xFF0A0A0A),
        body: Stack(
          children: [

            // ── Background grid pattern ─────────────
            Positioned.fill(child: _GridPattern()),

            // ── Top-left accent corner ──────────────
            Positioned(
              top: 0, left: 0,
              child: _CornerAccent(flip: false)),

            // ── Bottom-right accent corner ──────────
            Positioned(
              bottom: 0, right: 0,
              child: _CornerAccent(flip: true)),

            // ── Main content ────────────────────────
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [

                  // ── Logo mark ──────────────────────
                  _buildLogo(),

                  const SizedBox(height: 28),

                  // ── Brand name ─────────────────────
                  _buildBrandName(),

                  const SizedBox(height: 12),

                  // ── Decorative rule ────────────────
                  _buildRule(),

                  const SizedBox(height: 16),

                  // ── Slogan ─────────────────────────
                  _buildSlogan(),

                  const SizedBox(height: 52),

                  // ── Loading indicator ──────────────
                  _buildLoadingDots(),
                ],
              ),
            ),

            // ── Version tag bottom-center ───────────
            Positioned(
              bottom: 40, left: 0, right: 0,
              child: FadeTransition(
                opacity: _sloganFade,
                child: Text('v1.0.0',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontFamily: 'Georgia',
                        fontSize: 10,
                        color: Color(0x26FFFFFF),
                        letterSpacing: 2)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Logo mark ──────────────────────────────────
  Widget _buildLogo() {
    return AnimatedBuilder(
      animation: _logoCtrl,
      builder: (_, __) => Opacity(
        opacity: _logoFade.value,
        child: Transform.scale(
          scale: _logoScale.value,
          child: Transform.rotate(
            angle: _logoRotate.value,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Pulse ring
                AnimatedBuilder(
                  animation: _pulseCtrl,
                  builder: (_, __) => Opacity(
                    opacity: _pulseFade.value,
                    child: Transform.scale(
                      scale: _pulseScale.value,
                      child: Container(
                        width: 100, height: 100,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: Colors.white, width: 1.5))))),
                ),

                // Outer ring (thin)
                Container(
                  width: 100, height: 100,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: const Color(0x26FFFFFF), width: 1))),

                // Real Codolog logo asset
                Container(
                  width: 90, height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                          color: Colors.white.withOpacity(0.10),
                          blurRadius: 40,
                          spreadRadius: 4),
                      BoxShadow(
                          color: Colors.white.withOpacity(0.05),
                          blurRadius: 80,
                          spreadRadius: 8),
                    ],
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/logo.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Brand name ─────────────────────────────────
  Widget _buildBrandName() => FadeTransition(
    opacity: _textFade,
    child: SlideTransition(
      position: _textSlide,
      child: AnimatedBuilder(
        animation: _textSpacing,
        builder: (_, __) => Text(
          'CODOLOG',
          style: TextStyle(
              fontFamily: 'Georgia',
              fontSize: 32,
              color: Colors.white,
              fontWeight: FontWeight.w600,
              letterSpacing: _textSpacing.value,
              height: 1),
        ),
      ),
    ),
  );

  // ── Rule ───────────────────────────────────────
  Widget _buildRule() => AnimatedBuilder(
    animation: _lineWidth,
    builder: (_, __) => Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 80 * _lineWidth.value,
          height: 1,
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    Colors.white.withOpacity(0.6),
                    Colors.white,
                  ]))),
        Container(
            width: 5, height: 5,
            decoration: const BoxDecoration(
                color: Colors.white, shape: BoxShape.circle)),
        Container(
          width: 80 * _lineWidth.value,
          height: 1,
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: [
                    Colors.white,
                    Colors.white.withOpacity(0.6),
                    Colors.transparent,
                  ]))),
      ],
    ),
  );

  // ── Slogan ─────────────────────────────────────
  Widget _buildSlogan() => FadeTransition(
    opacity: _sloganFade,
    child: SlideTransition(
      position: _sloganSlide,
      child: Column(children: [
        Text(
          'ALWAYS LEARN UNIQUE',
          style: TextStyle(
              fontFamily: 'Georgia',
              fontSize: 11,
              color: Colors.white.withOpacity(0.5),
              letterSpacing: 4,
              fontWeight: FontWeight.w400),
        ),
      ]),
    ),
  );

  // ── Loading dots ───────────────────────────────
  Widget _buildLoadingDots() => FadeTransition(
    opacity: _dotFade,
    child: _PulsingDots(),
  );
}

// ─────────────────────────────────────────────
//  Pulsing loading dots
// ─────────────────────────────────────────────
class _PulsingDots extends StatefulWidget {
  @override
  State<_PulsingDots> createState() => _PulsingDotsState();
}

class _PulsingDotsState extends State<_PulsingDots>
    with TickerProviderStateMixin {
  late List<AnimationController> _ctrls;
  late List<Animation<double>>   _anims;

  @override
  void initState() {
    super.initState();
    _ctrls = List.generate(3, (i) => AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600)));
    _anims = _ctrls.map((c) => Tween<double>(begin: 0.25, end: 1.0)
        .animate(CurvedAnimation(parent: c, curve: Curves.easeInOut))).toList();

    for (int i = 0; i < 3; i++) {
      Future.delayed(Duration(milliseconds: i * 160), () {
        if (mounted) _ctrls[i].repeat(reverse: true);
      });
    }
  }

  @override
  void dispose() {
    for (final c in _ctrls) c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: List.generate(3, (i) => Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: AnimatedBuilder(
        animation: _anims[i],
        builder: (_, __) => Opacity(
          opacity: _anims[i].value,
          child: Container(
            width: 5, height: 5,
            decoration: BoxDecoration(
                color: Colors.white.withOpacity(_anims[i].value),
                shape: BoxShape.circle)),
        ),
      ),
    )),
  );
}

// ─────────────────────────────────────────────
//  Background grid pattern
// ─────────────────────────────────────────────
class _GridPattern extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _GridPainter());
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0x08FFFFFF)
      ..strokeWidth = 0.5;

    const spacing = 40.0;
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    // Radial vignette: brighter in centre
    final radial = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0x00000000),
          const Color(0xCC0A0A0A),
        ],
        stops: const [0.35, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), radial);
  }

  @override
  bool shouldRepaint(_) => false;
}

// ─────────────────────────────────────────────
//  Corner accent lines
// ─────────────────────────────────────────────
class _CornerAccent extends StatelessWidget {
  final bool flip;
  const _CornerAccent({required this.flip});

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scaleX: flip ? -1 : 1,
      scaleY: flip ? -1 : 1,
      child: SizedBox(
        width: 80, height: 80,
        child: CustomPaint(painter: _CornerPainter()),
      ),
    );
  }
}

class _CornerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = const Color(0x33FFFFFF)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    canvas.drawLine(const Offset(0, 20), const Offset(0, 0), p);
    canvas.drawLine(const Offset(0, 0), const Offset(20, 0), p);

    p.color = const Color(0x15FFFFFF);
    canvas.drawLine(const Offset(0, 40), const Offset(0, 0), p);
    canvas.drawLine(const Offset(0, 0), const Offset(40, 0), p);
  }

  @override
  bool shouldRepaint(_) => false;
}