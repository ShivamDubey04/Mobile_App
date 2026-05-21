import 'package:c_app/auth/register/registerservice.dart';
import 'package:c_app/course/service/ApiService.dart';
import 'package:c_app/pages/CourseDetail/CourseDetailScreen.dart';
import 'package:c_app/pages/Screens/screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:c_app/course/model/course_model.dart';

// ─────────────────────────────────────────────
//  Design tokens
// ─────────────────────────────────────────────
class _C {
  static const bg      = Color(0xFF0A0A0A);
  static const surface = Color(0xFF141414);
  static const card    = Color(0xFF181818);
  static const border  = Color(0xFF2A2A2A);
  static const white   = Color(0xFFFFFFFF);
  static const w80     = Color(0xCCFFFFFF);
  static const w60     = Color(0x99FFFFFF);
  static const w35     = Color(0x59FFFFFF);
  static const w15     = Color(0x26FFFFFF);
  static const w08     = Color(0x14FFFFFF);
  static const accent  = Color(0xFFFFFFFF);
}

// ─────────────────────────────────────────────
//  Data models
// ─────────────────────────────────────────────
// class Course {
  
//   final String id, title, instructor, duration, level, category;
//   final int lessons, students;
//   final double rating, progress;
//   final bool isNew, isTrending;
//     final String imageUrl;

//   const Course({
//     required this.imageUrl,
//     required this.id, required this.title, required this.instructor,
//     required this.duration, required this.level, required this.category,
//     required this.lessons, required this.students,
//     required this.rating, this.progress = 0,
//     this.isNew = false, this.isTrending = false,
//   });
// }

const _kCourses = [
  // Course (id:'1',imageUrl: 'assets/imgs.png', title:'Flutter Masvvvterclass\nZero to Hero', instructor:'Rahul Sharma',
  //     duration:'24h 30m', level:'Beginner', category:'Flutter',
  //     lessons:148, students:12400, rating:4.9, isNew:true),
  // Course(id:'2',imageUrl: 'assets/imgs.png', title:'Advanced Dart\nPatterns & Architecture', instructor:'Priya Mehta',
  //     duration:'18h 15m', level:'Advanced', category:'Dart',
  //     lessons:96, students:8200, rating:4.8, isTrending:true),
  // Course(id:'3',imageUrl: 'assets/imgs.png', title:'UI/UX Design\nfor Developers', instructor:'Arjun Nair',
  //     duration:'12h 00m', level:'Intermediate', category:'Design',
  //     lessons:72, students:15600, rating:4.7),
  // Course(id:'4',imageUrl: 'assets/imgs.png', title:'Firebase &\nBackend Integration', instructor:'Sneha Patel',
  //     duration:'16h 45m', level:'Intermediate', category:'Backend',
  //     lessons:88, students:9800, rating:4.8, isTrending:true),
  // Course(id:'5',imageUrl: 'assets/imgs.png', title:'State Management\nComplete Guide', instructor:'Vikram Rao',
  //     duration:'10h 20m', level:'Advanced', category:'Flutter',
  //     lessons:64, students:7300, rating:4.9),
];

const _kContinueCourses = [
  // Course(
  //   id: '2',
  //   imageUrl: 'assets/imgs.png',
  //   title: 'Advanced Dart\nPatterns',
  //   instructor: 'Priya Mehta',
  //   duration: '18h 15m',
  //   level: 'Advanced',
  //   category: 'Dart',
  //   lessons: 96,
  //   students: 8200,
  //   rating: 4.8,
  //   progress: 0.42,
  // ),
  // Course(
  //   id: '3',
  //   imageUrl: 'assets/imgs.png',
  //   title: 'UI/UX Design\nfor Developers',
  //   instructor: 'Arjun Nair',
  //   duration: '12h 00m',
  //   level: 'Intermediate',
  //   category: 'Design',
  //   lessons: 72,
  //   students: 15600,
  //   rating: 4.7,
  //   progress: 0.78,
  // ),
];

const _kCategories = ['All','Flutter','Dart','Design','Backend','DevOps','Python'];

// ─────────────────────────────────────────────
//  HomeScreen
// ─────────────────────────────────────────────
class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}
  List<Course> courses = [];

List<Course> allcourses = [];
class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  @override
Widget build(BuildContext context) {
  return AnnotatedRegion<SystemUiOverlayStyle>(
    value: SystemUiOverlayStyle.light,
    child: Scaffold(
      backgroundColor: _C.bg,
      body: _navIndex == 0
          ? _buildHome()
          : _navIndex == 1
              ? SearchScreen()
              : _navIndex == 2
                  ? _buildMyLearning()
                  : Container(), // or ProfileScreen()
      bottomNavigationBar: _buildNavBar(),
    ),
  );
}
  int _navIndex = 0;
  int _selectedCat = 0;

  late AnimationController _headerCtrl;
  late Animation<double> _headerFade;
  late Animation<Offset> _headerSlide;

  @override
  void initState() {
  


    super.initState();
 fetchCourses();

    _headerCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));
    _headerFade  = CurvedAnimation(parent: _headerCtrl, curve: Curves.easeOut);
    _headerSlide = Tween<Offset>(
        begin: const Offset(0, -0.03), end: Offset.zero)
        .animate(CurvedAnimation(parent: _headerCtrl, curve: Curves.easeOut));
    _headerCtrl.forward();
  }

  @override
  void dispose() { _headerCtrl.dispose(); super.dispose(); }

  final _pages = <Widget>[];

  // @override
  // Widget build(BuildContext context) {
  //   return AnnotatedRegion<SystemUiOverlayStyle>(
  //     value: SystemUiOverlayStyle.light,
  //     child: Scaffold(
  //       backgroundColor: _C.bg,
  //       body: _navIndex == 0
  //           ? _buildHome()
  //           : _navIndex == 1
  //               ? SearchScreen()
  //               : _navIndex == 2
  //                   ? _buildMyLearning()
  //                   // : ProfileScreen(),
  //       bottomNavigationBar: _buildNavBar(),
  //     ),
  //   );
  // }
Future<void> fetchCourses() async {
  try {

    final data = await ApiServices().getCourses();

    final newdata = await ApiServices().getAllCourses();

    setState(() {
      courses = data;
      allcourses = newdata;
    });

    print(courses.length);

  } catch (e) {
    print(e);
  }
}
  // ── Bottom nav ─────────────────────────────
  Widget _buildNavBar() => Container(
    decoration: BoxDecoration(
        color: _C.surface,
        border: Border(top: BorderSide(color: _C.border, width: 1))),
    child: SafeArea(
      top: false,
      child: SizedBox(
        height: 60,
        child: Row(
          children: [
            _NavItem(icon: Icons.home_outlined, activeIcon: Icons.home_rounded,
                label: 'Home',   index: 0, current: _navIndex, onTap: (i) => setState(() => _navIndex = i)),
            _NavItem(icon: Icons.search_outlined, activeIcon: Icons.search_rounded,
                label: 'Search', index: 1, current: _navIndex, onTap: (i) => setState(() => _navIndex = i)),
            _NavItem(icon: Icons.play_circle_outline, activeIcon: Icons.play_circle_rounded,
                label: 'Learn',  index: 2, current: _navIndex, onTap: (i) => setState(() => _navIndex = i)),
            _NavItem(icon: Icons.person_outline_rounded, activeIcon: Icons.person_rounded,
                label: 'Profile',index: 3, current: _navIndex, onTap: (i) => setState(() => _navIndex = i)),
          ],
        ),
      ),
    ),
  );

  // ── Home tab ───────────────────────────────
  Widget _buildHome() => CustomScrollView(
    physics: const BouncingScrollPhysics(),
    slivers: [
      // Header
      SliverToBoxAdapter(child: _buildHeader()),
      // Continue learning
      if (courses.isNotEmpty) ...[
        _SectionHeader(title: 'Continue Learning', onSeeAll: () {}),
        SliverToBoxAdapter(child: _buildContinueRow()),
      ],
      // Categories
      SliverToBoxAdapter(child: _buildCategoryRow()),
      // Featured
      _SectionHeader(title: 'Featured Courses', onSeeAll: () {}),
      SliverToBoxAdapter(child: _buildFeaturedRow()),
      // All courses
      _SectionHeader(title: 'All Courses', onSeeAll: () {}),
      SliverList(
        delegate: SliverChildBuilderDelegate(
          (_, i) => _CourseListTile(course: allcourses[i],
              onTap: () => _openCourse(allcourses[i])),
          childCount: allcourses.length,
        ),
      ),
      const SliverToBoxAdapter(child: SizedBox(height: 24)),
    ],
  );

  // ── Header ────────────────────────────────
  Widget _buildHeader() => FadeTransition(
    opacity: _headerFade,
    child: SlideTransition(
      position: _headerSlide,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              // Logo + greeting
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Container(
                      width: 28, height: 28,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(7)),
                      child: Center(child: Image.asset('assets/logo.png',
                          width: 22, height: 22, fit: BoxFit.cover))),
                    const SizedBox(width: 8),
                    Text('CODOLOG',
                        style: TextStyle(fontFamily: 'Georgia',
                            fontSize: 13, color: _C.white,
                            fontWeight: FontWeight.w700, letterSpacing: 3)),
                  ]),
                  const SizedBox(height: 14),
                  Text('Good Morning 👋', style: TextStyle(
                      fontFamily: 'Georgia', fontSize: 12, color: _C.w35,
                      letterSpacing: 0.5)),
                  const SizedBox(height: 2),
                  Text('What will you\nlearn today?', style: TextStyle(
                      fontFamily: 'Georgia', fontSize: 24, color: _C.white,
                      fontWeight: FontWeight.w600, height: 1.15,
                      letterSpacing: -0.5)),
                ],
              )),
              // Notification bell
              _Press(
                onTap: () => Navigator.push(context, _fade(NotificationsScreen())),
                child: Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                      color: _C.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _C.border, width: 1)),
                  child: Stack(alignment: Alignment.center, children: [
                    Icon(Icons.notifications_outlined, color: _C.white, size: 20),
                    Positioned(top: 10, right: 10,
                        child: Container(width: 7, height: 7,
                            decoration: const BoxDecoration(
                                color: Colors.white, shape: BoxShape.circle))),
                  ])),
              ),
            ]),
            const SizedBox(height: 20),
            // Search bar shortcut
            _Press(
              onTap: () => setState(() => _navIndex = 1),
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                    color: _C.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _C.border, width: 1)),
                child: Row(children: [
                  const SizedBox(width: 16),
                  Icon(Icons.search_rounded, color: _C.w35, size: 18),
                  const SizedBox(width: 10),
                  Text('Search courses, topics…',
                      style: TextStyle(fontFamily: 'Georgia',
                          fontSize: 13, color: _C.w35)),
                  const Spacer(),
                  Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                        color: _C.w08,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: _C.border, width: 1)),
                    child: Text('⌘K', style: TextStyle(
                        fontFamily: 'Georgia', fontSize: 10, color: _C.w35))),
                ]),
              ),
            ),
            const SizedBox(height: 28),
            // Stats row
            Row(children: [
              _StatChip(icon: Icons.play_circle_outline, value: '12', label: 'Courses'),
              const SizedBox(width: 12),
              _StatChip(icon: Icons.access_time_outlined, value: '48h', label: 'Learned'),
              const SizedBox(width: 12),
              _StatChip(icon: Icons.emoji_events_outlined, value: '5', label: 'Badges'),
            ]),
            const SizedBox(height: 8),
          ]),
        ),
      ),
    ),
  );

  // ── Continue learning row ─────────────────
  Widget _buildContinueRow() => SizedBox(
    height: 150,
    child: ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
      itemCount: courses.length,
      separatorBuilder: (_, __) => const SizedBox(width: 14),
      itemBuilder: (_, i) => _ContinueCard(
          course: courses[i],
          onTap: () => _openCourse(courses[i])),
    ),
  );

  // ── Category chips ───────────────────────
  Widget _buildCategoryRow() => SizedBox(
    height: 44,
    child: ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: _kCategories.length,
      separatorBuilder: (_, __) => const SizedBox(width: 8),
      itemBuilder: (_, i) {
        final sel = i == _selectedCat;
        return _Press(
          onTap: () => setState(() => _selectedCat = i),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            decoration: BoxDecoration(
                color: sel ? Colors.white : _C.surface,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                    color: sel ? Colors.white : _C.border, width: 1)),
            child: Text(_kCategories[i],
                style: TextStyle(
                    fontFamily: 'Georgia', fontSize: 12,
                    color: sel ? Colors.black : _C.w60,
                    fontWeight: sel ? FontWeight.w700 : FontWeight.w400,
                    letterSpacing: 0.3)),
          ),
        );
      },
    ),
  );

  // ── Featured row ──────────────────────────
Widget _buildFeaturedRow() => SizedBox(
      height: 230,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),

        // API list length
        itemCount: courses.length,

        separatorBuilder: (_, __) => const SizedBox(width: 14),

        itemBuilder: (_, i) => _FeaturedCard(
          course: courses[i],

          // open selected course
          onTap: () => _openCourse(courses[i]),
        ),
      ),
    );
  // ── My Learning tab ───────────────────────
  Widget _buildMyLearning() => CustomScrollView(
    physics: const BouncingScrollPhysics(),
    slivers: [
      SliverToBoxAdapter(child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('My Learning', style: TextStyle(
                fontFamily: 'Georgia', fontSize: 26, color: _C.white,
                fontWeight: FontWeight.w600, letterSpacing: -0.5)),
            const SizedBox(height: 4),
            Text('Track your progress', style: TextStyle(
                fontFamily: 'Georgia', fontSize: 13, color: _C.w35)),
            const SizedBox(height: 24),
          ]),
        ),
      )),
      SliverList(
        delegate: SliverChildBuilderDelegate(
          (_, i) {
            final c = _kContinueCourses[i % _kContinueCourses.length];
            return _CourseListTile(course: c, showProgress: true,
                onTap: () => _openCourse(c));
          },
          childCount: 4,
        ),
      ),
      const SliverToBoxAdapter(child: SizedBox(height: 24)),
    ],
  );

  void _openCourse(Course c) => Navigator.push(context,
      _fade(CourseDetailScreen(course: c)));

  PageRoute _fade(Widget page) => PageRouteBuilder(
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, a, __, c) => FadeTransition(opacity: a, child: c),
      transitionDuration: const Duration(milliseconds: 350));
}

// ─────────────────────────────────────────────
//  Section header sliver
// ─────────────────────────────────────────────
class _SectionHeader extends SliverToBoxAdapter {
  _SectionHeader({required String title, required VoidCallback onSeeAll})
      : super(child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 14),
          child: Row(children: [
            Text(title, style: const TextStyle(
                fontFamily: 'Georgia', fontSize: 17, color: Color(0xFFFFFFFF),
                fontWeight: FontWeight.w600, letterSpacing: -0.3)),
            const Spacer(),
            _Press(
              onTap: onSeeAll,
              child: Text('See all', style: TextStyle(
                  fontFamily: 'Georgia', fontSize: 12,
                  color: const Color(0x59FFFFFF))),
            ),
          ]),
        ));
}

// ─────────────────────────────────────────────
//  Stat chip
// ─────────────────────────────────────────────
class _StatChip extends StatelessWidget {
  final IconData icon;
  final String value, label;
  const _StatChip({required this.icon, required this.value, required this.label});
  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
          color: _C.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: _C.border, width: 1)),
      child: Column(children: [
        Icon(icon, color: _C.w60, size: 16),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(
            fontFamily: 'Georgia', fontSize: 15, color: Colors.white,
            fontWeight: FontWeight.w700)),
        Text(label, style: TextStyle(
            fontFamily: 'Georgia', fontSize: 10, color: _C.w35,
            letterSpacing: 0.3)),
      ]),
    ),
  );
}

// ─────────────────────────────────────────────
//  Continue learning card
// ─────────────────────────────────────────────
class _ContinueCard extends StatelessWidget {
  final Course course;
  final VoidCallback onTap;
  const _ContinueCard({required this.course, required this.onTap});

  @override
  Widget build(BuildContext context) => _Press(
    onTap: onTap,
    child: Container(
      width: 260,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: const Color.fromARGB(255, 24, 39, 37),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _C.border, width: 1)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          _CategoryBadge(course.category),
          const Spacer(),
          Text('${(course.rating * 100).round()}%',
              style: TextStyle(fontFamily: 'Georgia', fontSize: 11,
                  color: _C.white, fontWeight: FontWeight.w700)),
        ]),
        const SizedBox(height: 8),
        Text(course.title.replaceAll('\n', ' '),
            maxLines: 2, overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontFamily: 'Georgia', fontSize: 13,
                color: Colors.white, fontWeight: FontWeight.w600, height: 1.3)),
        const Spacer(),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: course.rating,
            backgroundColor: _C.w08,
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            minHeight: 3,
          ),
        ),
        const SizedBox(height: 6),
        Text('${course.lessons} lessons · ${course.duration}',
            style: TextStyle(fontFamily: 'Georgia', fontSize: 10, color: _C.w35)),
      ]),
    ),
  );
}

// ─────────────────────────────────────────────
//  Featured course card
// ─────────────────────────────────────────────
class _FeaturedCard extends StatelessWidget {
  final Course course;
  final VoidCallback onTap;
  const _FeaturedCard({required this.course, required this.onTap});

  @override
  Widget build(BuildContext context) => _Press(
    onTap: onTap,
    child: Container(
      width: 200,
      decoration: BoxDecoration(
          color: _C.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _C.border, width: 1)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Thumbnail
Container(
  height: 110,
  decoration: BoxDecoration(
    color: _C.surface,
    borderRadius: const BorderRadius.vertical(
      top: Radius.circular(15),
    ),
  ),
  child: Stack(
    children: [

      // Course Image
      ClipRRect(
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(15),
        ),
        child: Image.network(
          course.imageUrl, // add image url in your course model
          height: 110,
          width: double.infinity,
          fit: BoxFit.cover,
        ),
      ),

      // Dark overlay (optional for better visibility)
      Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(15),
          ),
          color: Colors.black.withOpacity(0.25),
        ),
      ),

      // Play Icon
      Center(
        child: Icon(
          Icons.play_circle_outline,
          color: Colors.white,
          size: 48,
        ),
      ),

      // NEW Badge
      if (course.isNew)
        Positioned(
          top: 10,
          left: 10,
          child: _Badge(
            'NEW',
            Colors.white,
            Colors.black,
          ),
        ),

      // HOT Badge
      if (course.isTrending)
        Positioned(
          top: 10,
          right: 10,
          child: _Badge(
            '🔥 HOT',
            _C.surface,
            Colors.white,
          ),
        ),

      // Duration Chip
      Positioned(
        bottom: 10,
        right: 10,
        child: _DurationChip(course.duration),
      ),
    ],
  ),
),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _CategoryBadge(course.category),
            const SizedBox(height: 6),
            Text(course.title.replaceAll('\n', ' '),
                maxLines: 2, overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontFamily: 'Georgia', fontSize: 13,
                    color: Colors.white, fontWeight: FontWeight.w600, height: 1.3)),
            const SizedBox(height: 6),
            Row(children: [
              Icon(Icons.star_rounded, color: Colors.white, size: 12),
              const SizedBox(width: 3),
              Text('${course.rating}', style: TextStyle(
                  fontFamily: 'Georgia', fontSize: 11,
                  color: _C.w60, fontWeight: FontWeight.w600)),
              const Spacer(),
              Text(course.level, style: TextStyle(
                  fontFamily: 'Georgia', fontSize: 10, color: _C.w35)),
            ]),
          ]),
        ),
      ]),
    ),
  );
}

// ─────────────────────────────────────────────
//  Course list tile
// ─────────────────────────────────────────────
class _CourseListTile extends StatelessWidget {
  final Course course;
  final VoidCallback onTap;
  final bool showProgress;
  const _CourseListTile({required this.course, required this.onTap,
      this.showProgress = false});

  @override
  Widget build(BuildContext context) => _Press(
    onTap: onTap,
    child: Container(
      margin: const EdgeInsets.fromLTRB(24, 0, 24, 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: _C.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _C.border, width: 1)),
      child: Row(children: [
        // Thumb
        Container(
          width: 64, height: 64,
          decoration: BoxDecoration(
              color: _C.surface,
              borderRadius: BorderRadius.circular(10)),
          child: Center(child: Icon(Icons.play_circle_outline,
              color: _C.w35, size: 28))),
        const SizedBox(width: 12),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(course.title.replaceAll('\n', ' '),
                maxLines: 2, overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontFamily: 'Georgia', fontSize: 13,
                    color: Colors.white, fontWeight: FontWeight.w600, height: 1.3)),
            const SizedBox(height: 4),
            Text(course.instructor, style: TextStyle(
                fontFamily: 'Georgia', fontSize: 11, color: _C.w35)),
            const SizedBox(height: 6),
            if (showProgress && course.rating > 0) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: LinearProgressIndicator(
                    value: course.rating, minHeight: 2,
                    backgroundColor: _C.w08,
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.white)),
              ),
              const SizedBox(height: 4),
            ],
            Row(children: [
              Icon(Icons.star_rounded, color: Colors.white, size: 11),
              const SizedBox(width: 3),
              Text('${course.rating}', style: TextStyle(
                  fontFamily: 'Georgia', fontSize: 11, color: _C.w60)),
              const SizedBox(width: 10),
              Icon(Icons.book_outlined, color: _C.w35, size: 11),
              const SizedBox(width: 3),
              Text('${course.lessons}', style: TextStyle(
                  fontFamily: 'Georgia', fontSize: 11, color: _C.w35)),
              const SizedBox(width: 10),
              Icon(Icons.access_time_outlined, color: _C.w35, size: 11),
              const SizedBox(width: 3),
              Text(course.duration, style: TextStyle(
                  fontFamily: 'Georgia', fontSize: 11, color: _C.w35)),
            ]),
          ],
        )),
        Icon(Icons.chevron_right_rounded, color: _C.w35, size: 18),
      ]),
    ),
  );
}

// ─────────────────────────────────────────────
//  Nav item
// ─────────────────────────────────────────────
class _NavItem extends StatelessWidget {
  final IconData icon, activeIcon;
  final String label;
  final int index, current;
  final ValueChanged<int> onTap;
  const _NavItem({required this.icon, required this.activeIcon,
      required this.label, required this.index, required this.current,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    final active = index == current;
    return Expanded(child: GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () { HapticFeedback.lightImpact(); onTap(index); },
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: Icon(active ? activeIcon : icon,
              key: ValueKey(active),
              color: active ? Colors.white : const Color(0x59FFFFFF),
              size: 22)),
        const SizedBox(height: 3),
        Text(label, style: TextStyle(
            fontFamily: 'Georgia', fontSize: 10,
            color: active ? Colors.white : const Color(0x59FFFFFF),
            fontWeight: active ? FontWeight.w700 : FontWeight.w400)),
        const SizedBox(height: 2),
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: active ? 16 : 0, height: 2,
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(1))),
      ]),
    ));
  }
}

// ─────────────────────────────────────────────
//  Small reusable widgets
// ─────────────────────────────────────────────
class _CategoryBadge extends StatelessWidget {
  final String label;
  const _CategoryBadge(this.label);
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
        color: _C.w08, borderRadius: BorderRadius.circular(5),
        border: Border.all(color: _C.w15, width: 1)),
    child: Text(label, style: TextStyle(
        fontFamily: 'Georgia', fontSize: 9, color: _C.w60, letterSpacing: 0.5)),
  );
}

class _Badge extends StatelessWidget {
  final String text;
  final Color bg, fg;
  const _Badge(this.text, this.bg, this.fg);
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
    child: Text(text, style: TextStyle(fontFamily: 'Georgia', fontSize: 9,
        color: fg, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
  );
}

class _DurationChip extends StatelessWidget {
  final String duration;
  const _DurationChip(this.duration);
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
    decoration: BoxDecoration(
        color: Colors.black54, borderRadius: BorderRadius.circular(5)),
    child: Text(duration, style: const TextStyle(
        fontFamily: 'Georgia', fontSize: 9, color: Colors.white)),
  );
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
      vsync: this, duration: const Duration(milliseconds: 80));
  late final Animation<double> _s = Tween<double>(begin: 1.0, end: 0.96)
      .animate(CurvedAnimation(parent: _c, curve: Curves.easeOut));
  @override void dispose() { _c.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => GestureDetector(
      onTapDown: (_) { if (widget.onTap != null) _c.forward(); },
      onTapUp:   (_) { _c.reverse(); widget.onTap?.call(); },
      onTapCancel:   () => _c.reverse(),
      child: ScaleTransition(scale: _s, child: widget.child));
}