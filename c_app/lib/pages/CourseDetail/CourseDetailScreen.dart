import 'package:c_app/Homescreen/homescreen.dart';
import 'package:c_app/pages/VideoPlayer/VideoPlayerScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


class CourseDetailScreen extends StatefulWidget {
  final Course course;
  const CourseDetailScreen({required this.course});
  @override
  _CourseDetailScreenState createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  bool _isEnrolled = false;
  bool _isWishlisted = false;

  // Dummy curriculum
  final _curriculum = [
    _Section('Getting Started', [
      _Lesson('Welcome & Course Overview', '05:30', true, false),
      _Lesson('Setup & Installation', '12:45', true, false),
      _Lesson('Understanding the Basics', '18:20', false, false),
    ]),
    _Section('Core Concepts', [
      _Lesson('State Management Intro', '22:10', false, false),
      _Lesson('Widgets Deep Dive', '31:05', false, false),
      _Lesson('Navigation & Routing', '19:50', false, false),
      _Lesson('Custom Animations', '28:30', false, false),
    ]),
    _Section('Advanced Topics', [
      _Lesson('Architecture Patterns', '35:00', false, false),
      _Lesson('Performance Optimization', '24:15', false, false),
      _Lesson('Deployment & Publishing', '16:40', false, false),
    ]),
  ];

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() { _tabCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: const Color(0xFF0A0A0A),
        body: Column(children: [
          // Hero
          _buildHero(),
          // Tabs
          _buildTabBar(),
          // Content
          Expanded(child: TabBarView(
            controller: _tabCtrl,
            children: [
              _buildOverviewTab(),
              _buildCurriculumTab(),
              _buildReviewsTab(),
            ],
          )),
          // Bottom CTA
          _buildBottomBar(),
        ]),
      ),
    );
  }

  // ── Hero ─────────────────────────────────
  Widget _buildHero() => Stack(children: [
    // Thumbnail
    Container(
      height: 240,
      color: const Color(0xFF141414),
      child: Stack(children: [
        Center(child: Icon(Icons.play_circle_outline,
            color: const Color(0x14FFFFFF), size: 80)),
        // Dark gradient overlay
        Container(decoration: const BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topCenter, end: Alignment.bottomCenter,
                colors: [Colors.transparent, Color(0xFF0A0A0A)]))),
        // Preview play button
        Center(child: _Press(
          onTap: () => Navigator.push(context, _fade(
              VideoPlayerScreen(
                title: 'Course Preview',
                lessonTitle: widget.course.title.replaceAll('\n', ' '),
              ))),
          child: Container(
            width: 64, height: 64,
            decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(
                    color: Colors.white.withOpacity(0.2),
                    blurRadius: 20, spreadRadius: 2)]),
            child: const Icon(Icons.play_arrow_rounded,
                color: Colors.black, size: 32)),
        )),
        // Preview label
        Positioned(bottom: 50, left: 0, right: 0,
            child: Center(child: Text('Watch Free Preview',
                style: TextStyle(fontFamily: 'Georgia', fontSize: 12,
                    color: Colors.white.withOpacity(0.7))))),
      ]),
    ),
    // Back button
    SafeArea(child: Padding(
      padding: const EdgeInsets.all(16),
      child: Row(children: [
        _Press(
          onTap: () => Navigator.pop(context),
          child: Container(
            width: 38, height: 38,
            decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0x26FFFFFF), width: 1)),
            child: const Center(child: Icon(Icons.arrow_back_ios_new_rounded,
                color: Colors.white, size: 14))),
        ),
        const Spacer(),
        _Press(
          onTap: () => setState(() => _isWishlisted = !_isWishlisted),
          child: Container(
            width: 38, height: 38,
            decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0x26FFFFFF), width: 1)),
            child: Icon(
                _isWishlisted ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                color: Colors.white, size: 18)),
        ),
        const SizedBox(width: 8),
        _Press(
          onTap: () {},
          child: Container(
            width: 38, height: 38,
            decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0x26FFFFFF), width: 1)),
            child: const Icon(Icons.share_outlined, color: Colors.white, size: 16)),
        ),
      ]),
    )),
  ]);

  // ── Tab bar ──────────────────────────────
  Widget _buildTabBar() => Container(
    color: const Color(0xFF0A0A0A),
    padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Title & meta
      Text(widget.course.title.replaceAll('\n', ' '),
          style: const TextStyle(fontFamily: 'Georgia', fontSize: 19,
              color: Colors.white, fontWeight: FontWeight.w600,
              height: 1.25, letterSpacing: -0.3)),
      const SizedBox(height: 8),
      Row(children: [
        Icon(Icons.star_rounded, color: Colors.white, size: 13),
        const SizedBox(width: 4),
        Text('${widget.course.rating}', style: TextStyle(
            fontFamily: 'Georgia', fontSize: 12,
            color: Colors.white.withOpacity(0.8),
            fontWeight: FontWeight.w600)),
        const SizedBox(width: 6),
        Text('(${_formatNum(widget.course.students)})',
            style: TextStyle(fontFamily: 'Georgia', fontSize: 12,
                color: Colors.white.withOpacity(0.4))),
        const SizedBox(width: 12),
        Text('${widget.course.lessons} lessons',
            style: TextStyle(fontFamily: 'Georgia', fontSize: 12,
                color: Colors.white.withOpacity(0.4))),
        const SizedBox(width: 12),
        Text(widget.course.level,
            style: TextStyle(fontFamily: 'Georgia', fontSize: 12,
                color: Colors.white.withOpacity(0.4))),
      ]),
      const SizedBox(height: 8),
      Row(children: [
        Container(
          width: 28, height: 28,
          decoration: BoxDecoration(
              color: const Color(0xFF2A2A2A), shape: BoxShape.circle),
          child: const Icon(Icons.person_outline, color: Colors.white, size: 14)),
        const SizedBox(width: 8),
        Text('By ${widget.course.instructor}',
            style: TextStyle(fontFamily: 'Georgia', fontSize: 12,
                color: Colors.white.withOpacity(0.6))),
      ]),
      const SizedBox(height: 16),
      // Tab bar
      TabBar(
        controller: _tabCtrl,
        labelStyle: const TextStyle(fontFamily: 'Georgia', fontSize: 12,
            fontWeight: FontWeight.w700),
        unselectedLabelStyle: const TextStyle(fontFamily: 'Georgia', fontSize: 12),
        labelColor: Colors.white,
        unselectedLabelColor: const Color(0x59FFFFFF),
        indicatorColor: Colors.white,
        indicatorWeight: 2,
        indicatorSize: TabBarIndicatorSize.label,
        tabs: const [
          Tab(text: 'Overview'),
          Tab(text: 'Curriculum'),
          Tab(text: 'Reviews'),
        ],
      ),
    ]),
  );

  // ── Overview tab ─────────────────────────
  Widget _buildOverviewTab() => ListView(
    padding: const EdgeInsets.all(24),
    physics: const BouncingScrollPhysics(),
    children: [
      // Stats row
      Row(children: [
        _InfoTile(Icons.access_time_outlined, 'Duration', widget.course.duration),
        const SizedBox(width: 10),
        _InfoTile(Icons.play_lesson_outlined, 'Lessons', '${widget.course.lessons}'),
        const SizedBox(width: 10),
        _InfoTile(Icons.people_outline, 'Students', _formatNum(widget.course.students)),
      ]),
      const SizedBox(height: 24),
      // What you'll learn
      _SectionTitle('What You\'ll Learn'),
      const SizedBox(height: 12),
      ...[
        'Build production-ready Flutter apps from scratch',
        'Master Dart programming language fundamentals',
        'Implement clean architecture and design patterns',
        'Integrate REST APIs and Firebase backend',
        'Publish apps to Play Store & App Store',
      ].map((s) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(margin: const EdgeInsets.only(top: 5),
              width: 5, height: 5,
              decoration: const BoxDecoration(
                  color: Colors.white, shape: BoxShape.circle)),
          const SizedBox(width: 12),
          Expanded(child: Text(s, style: TextStyle(
              fontFamily: 'Georgia', fontSize: 13,
              color: Colors.white.withOpacity(0.7), height: 1.5))),
        ]),
      )),
      const SizedBox(height: 24),
      _SectionTitle('Requirements'),
      const SizedBox(height: 12),
      ...[
        'Basic programming knowledge helpful but not required',
        'A computer with macOS, Windows, or Linux',
        'Enthusiasm to learn!',
      ].map((s) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(children: [
          Icon(Icons.check_circle_outline, color: Colors.white.withOpacity(0.5), size: 14),
          const SizedBox(width: 10),
          Expanded(child: Text(s, style: TextStyle(
              fontFamily: 'Georgia', fontSize: 13,
              color: Colors.white.withOpacity(0.6), height: 1.5))),
        ]),
      )),
      const SizedBox(height: 24),
      _SectionTitle('About the Instructor'),
      const SizedBox(height: 12),
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: const Color(0xFF141414),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF2A2A2A), width: 1)),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: 52, height: 52,
            decoration: BoxDecoration(
                color: const Color(0xFF2A2A2A), shape: BoxShape.circle),
            child: Center(child: Text(widget.course.instructor[0],
                style: const TextStyle(fontFamily: 'Georgia', fontSize: 20,
                    color: Colors.white, fontWeight: FontWeight.w600)))),
          const SizedBox(width: 14),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.course.instructor,
                  style: const TextStyle(fontFamily: 'Georgia', fontSize: 14,
                      color: Colors.white, fontWeight: FontWeight.w600)),
              const SizedBox(height: 2),
              Text('Senior ${widget.course.category} Developer',
                  style: TextStyle(fontFamily: 'Georgia', fontSize: 11,
                      color: Colors.white.withOpacity(0.4))),
              const SizedBox(height: 8),
              Text('Expert developer with 8+ years of experience building '
                  'production apps used by millions worldwide.',
                  style: TextStyle(fontFamily: 'Georgia', fontSize: 12,
                      color: Colors.white.withOpacity(0.5), height: 1.55)),
            ],
          )),
        ]),
      ),
      const SizedBox(height: 100),
    ],
  );

  // ── Curriculum tab ───────────────────────
  Widget _buildCurriculumTab() => ListView.builder(
    padding: const EdgeInsets.symmetric(vertical: 16),
    physics: const BouncingScrollPhysics(),
    itemCount: _curriculum.length,
    itemBuilder: (_, i) => _SectionExpansion(
        section: _curriculum[i],
        onLessonTap: (lesson) => Navigator.push(context, _fade(
            VideoPlayerScreen(
              title: lesson.title,
              lessonTitle: '${_curriculum[i].title} › ${lesson.title}',
            )))),
  );

  // ── Reviews tab ──────────────────────────
  Widget _buildReviewsTab() => ListView(
    padding: const EdgeInsets.all(24),
    physics: const BouncingScrollPhysics(),
    children: [
      // Average
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
            color: const Color(0xFF141414),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF2A2A2A), width: 1)),
        child: Row(children: [
          Column(children: [
            Text('${widget.course.rating}', style: const TextStyle(
                fontFamily: 'Georgia', fontSize: 48, color: Colors.white,
                fontWeight: FontWeight.w300, height: 1)),
            Row(children: List.generate(5, (i) => Icon(
                i < widget.course.rating.floor()
                    ? Icons.star_rounded
                    : Icons.star_outline_rounded,
                color: Colors.white, size: 14))),
            const SizedBox(height: 4),
            Text('${_formatNum(widget.course.students)} ratings',
                style: TextStyle(fontFamily: 'Georgia', fontSize: 10,
                    color: Colors.white.withOpacity(0.4))),
          ]),
          const SizedBox(width: 20),
          Expanded(child: Column(
            children: [5, 4, 3, 2, 1].map((star) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(children: [
                Text('$star', style: TextStyle(fontFamily: 'Georgia',
                    fontSize: 10, color: Colors.white.withOpacity(0.4))),
                const SizedBox(width: 6),
                Expanded(child: ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: LinearProgressIndicator(
                      value: star == 5 ? 0.72 : star == 4 ? 0.20 : 0.05,
                      minHeight: 4,
                      backgroundColor: const Color(0xFF2A2A2A),
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.white)),
                )),
              ]),
            )).toList(),
          )),
        ]),
      ),
      const SizedBox(height: 24),
      ..._reviews.map((r) => _ReviewCard(review: r)),
      const SizedBox(height: 80),
    ],
  );

  // ── Bottom bar ────────────────────────────
  Widget _buildBottomBar() => Container(
    padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
    decoration: const BoxDecoration(
        color: Color(0xFF0A0A0A),
        border: Border(top: BorderSide(color: Color(0xFF2A2A2A), width: 1))),
    child: SafeArea(
      top: false,
      child: Row(children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('FREE', style: const TextStyle(fontFamily: 'Georgia',
              fontSize: 22, color: Colors.white, fontWeight: FontWeight.w700)),
          Text('Full lifetime access', style: TextStyle(
              fontFamily: 'Georgia', fontSize: 11,
              color: Colors.white.withOpacity(0.4))),
        ]),
        const Spacer(),
        _Press(
          onTap: () => setState(() => _isEnrolled = !_isEnrolled),
          child: Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 28),
            decoration: BoxDecoration(
                color: _isEnrolled ? const Color(0xFF1A1A1A) : Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: _isEnrolled
                        ? const Color(0xFF2A2A2A)
                        : Colors.white,
                    width: 1)),
            child: Center(child: Text(
                _isEnrolled ? 'Continue Learning' : 'Enroll Now',
                style: TextStyle(
                    fontFamily: 'Georgia', fontSize: 13,
                    color: _isEnrolled ? Colors.white : Colors.black,
                    fontWeight: FontWeight.w700, letterSpacing: 0.5))),
          ),
        ),
      ]),
    ),
  );

  String _formatNum(int n) =>
      n >= 1000 ? '${(n / 1000).toStringAsFixed(1)}k' : '$n';

  PageRoute _fade(Widget page) => PageRouteBuilder(
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, a, __, c) => FadeTransition(opacity: a, child: c),
      transitionDuration: const Duration(milliseconds: 350));
}

// ─────────────────────────────────────────────
//  Supporting widgets
// ─────────────────────────────────────────────
class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label, value;
  const _InfoTile(this.icon, this.label, this.value);
  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
          color: const Color(0xFF141414),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFF2A2A2A), width: 1)),
      child: Column(children: [
        Icon(icon, color: Colors.white.withOpacity(0.5), size: 16),
        const SizedBox(height: 6),
        Text(value, style: const TextStyle(fontFamily: 'Georgia',
            fontSize: 13, color: Colors.white, fontWeight: FontWeight.w700)),
        Text(label, style: TextStyle(fontFamily: 'Georgia',
            fontSize: 10, color: Colors.white.withOpacity(0.35))),
      ]),
    ),
  );
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);
  @override
  Widget build(BuildContext context) => Text(text,
      style: const TextStyle(fontFamily: 'Georgia', fontSize: 15,
          color: Colors.white, fontWeight: FontWeight.w700));
}

class _SectionExpansion extends StatefulWidget {
  final _Section section;
  final ValueChanged<_Lesson> onLessonTap;
  const _SectionExpansion({required this.section, required this.onLessonTap});
  @override State<_SectionExpansion> createState() => _SectionExpansionState();
}
class _SectionExpansionState extends State<_SectionExpansion> {
  bool _open = true;
  @override Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      GestureDetector(
        onTap: () => setState(() => _open = !_open),
        child: Container(
          padding: const EdgeInsets.fromLTRB(24, 14, 24, 14),
          color: const Color(0xFF141414),
          child: Row(children: [
            Expanded(child: Text(widget.section.title,
                style: const TextStyle(fontFamily: 'Georgia', fontSize: 13,
                    color: Colors.white, fontWeight: FontWeight.w600))),
            Text('${widget.section.lessons.length} lessons',
                style: TextStyle(fontFamily: 'Georgia', fontSize: 11,
                    color: Colors.white.withOpacity(0.4))),
            const SizedBox(width: 8),
            Icon(_open ? Icons.expand_less : Icons.expand_more,
                color: Colors.white.withOpacity(0.4), size: 18),
          ]),
        ),
      ),
      if (_open) ...widget.section.lessons.map((l) => _Press(
        onTap: l.isFree ? () => widget.onLessonTap(l) : null,
        child: Container(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
          decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(
                  color: Color(0xFF1E1E1E), width: 1))),
          child: Row(children: [
            Icon(l.isFree ? Icons.play_circle_outline : Icons.lock_outline,
                color: l.isFree
                    ? Colors.white.withOpacity(0.8)
                    : Colors.white.withOpacity(0.3),
                size: 18),
            const SizedBox(width: 12),
            Expanded(child: Text(l.title,
                style: TextStyle(fontFamily: 'Georgia', fontSize: 13,
                    color: l.isFree
                        ? Colors.white.withOpacity(0.85)
                        : Colors.white.withOpacity(0.4)))),
            if (l.isFree) Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              decoration: BoxDecoration(
                  border: Border.all(color: const Color(0x26FFFFFF), width: 1),
                  borderRadius: BorderRadius.circular(5)),
              child: const Text('FREE', style: TextStyle(
                  fontFamily: 'Georgia', fontSize: 8, color: Colors.white,
                  letterSpacing: 1))),
            const SizedBox(width: 8),
            Text(l.duration, style: TextStyle(fontFamily: 'Georgia',
                fontSize: 11, color: Colors.white.withOpacity(0.35))),
          ]),
        ),
      )),
      const SizedBox(height: 4),
    ],
  );
}

class _ReviewCard extends StatelessWidget {
  final _Review review;
  const _ReviewCard({required this.review});
  @override Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 16),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2A2A2A), width: 1)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Container(
          width: 36, height: 36,
          decoration: BoxDecoration(
              color: const Color(0xFF2A2A2A), shape: BoxShape.circle),
          child: Center(child: Text(review.name[0],
              style: const TextStyle(fontFamily: 'Georgia', fontSize: 14,
                  color: Colors.white, fontWeight: FontWeight.w600)))),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(review.name, style: const TextStyle(
                  fontFamily: 'Georgia', fontSize: 13, color: Colors.white,
                  fontWeight: FontWeight.w600)),
              Text(review.date, style: TextStyle(
                  fontFamily: 'Georgia', fontSize: 10,
                  color: Colors.white.withOpacity(0.35))),
            ])),
        Row(children: List.generate(5, (i) => Icon(
            i < review.stars ? Icons.star_rounded : Icons.star_outline_rounded,
            color: Colors.white, size: 12))),
      ]),
      const SizedBox(height: 10),
      Text(review.text, style: TextStyle(fontFamily: 'Georgia', fontSize: 13,
          color: Colors.white.withOpacity(0.6), height: 1.55)),
    ]),
  );
}

// ─────────────────────────────────────────────
//  Models
// ─────────────────────────────────────────────
class _Section { final String title; final List<_Lesson> lessons;
  const _Section(this.title, this.lessons); }
class _Lesson  { final String title, duration; final bool isFree, isCompleted;
  const _Lesson(this.title, this.duration, this.isFree, this.isCompleted); }
class _Review  { final String name, date, text; final int stars;
  const _Review(this.name, this.date, this.text, this.stars); }

const _reviews = [
  _Review('Ankit Gupta', '2 weeks ago',
      'Absolutely brilliant course! The explanations are crystal clear and the projects are highly practical. Worth every minute.', 5),
  _Review('Meera Pillai', '1 month ago',
      'Best Flutter course out there. The instructor explains complex topics in a simple, digestible way. Already building my second app!', 5),
  _Review('Rohit Verma', '3 weeks ago',
      'Great content overall. Would love more advanced topics on state management, but the fundamentals are solid.', 4),
];

// Shared press widget (same as home_screen.dart — in a real app extract to common/)
class _Press extends StatefulWidget {
  final Widget child; final VoidCallback? onTap;
  const _Press({required this.child, this.onTap});
  @override State<_Press> createState() => _PressState();
}
class _PressState extends State<_Press> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 80));
  late final Animation<double> _s = Tween<double>(begin: 1.0, end: 0.96)
      .animate(CurvedAnimation(parent: _c, curve: Curves.easeOut));
  @override void dispose() { _c.dispose(); super.dispose(); }
  @override Widget build(BuildContext context) => GestureDetector(
      onTapDown: (_) { if (widget.onTap != null) _c.forward(); },
      onTapUp:   (_) { _c.reverse(); widget.onTap?.call(); },
      onTapCancel:   () => _c.reverse(),
      child: ScaleTransition(scale: _s, child: widget.child));
}