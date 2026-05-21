import 'package:c_app/Homescreen/homescreen.dart';
import 'package:c_app/course/model/course_model.dart';
import 'package:c_app/pages/CourseDetail/CourseDetailScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ═══════════════════════════════════════════════
//  PROFILE SCREEN
// ═══════════════════════════════════════════════
class ProfileScreen extends StatefulWidget {
  @override _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {

  late AnimationController _entry;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _entry = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 700));
    _fade = CurvedAnimation(parent: _entry, curve: Curves.easeOut);
    _entry.forward();
  }

  @override void dispose() { _entry.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => AnnotatedRegion<SystemUiOverlayStyle>(
    value: SystemUiOverlayStyle.light,
    child: FadeTransition(
      opacity: _fade,
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(child: _buildHeader()),
          SliverToBoxAdapter(child: _buildStatsRow()),
          SliverToBoxAdapter(child: _buildAchievements()),
          SliverToBoxAdapter(child: _buildSettingsSection()),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    ),
  );

  Widget _buildHeader() => SafeArea(
    bottom: false,
    child: Padding(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
      child: Column(children: [
        Row(children: [
          const Spacer(),
          _PressBtn(Icons.settings_outlined, onTap: _showSettings),
        ]),
        const SizedBox(height: 12),
        // Avatar
        Stack(alignment: Alignment.bottomRight, children: [
          Container(
            width: 88, height: 88,
            decoration: BoxDecoration(
                color: const Color(0xFF2A2A2A), shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF3A3A3A), width: 2)),
            child: const Center(child: Text('R',
                style: TextStyle(fontFamily: 'Georgia', fontSize: 38,
                    color: Colors.white, fontWeight: FontWeight.w600)))),
          Container(
            width: 26, height: 26,
            decoration: BoxDecoration(
                color: Colors.white, shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF0A0A0A), width: 2)),
            child: const Icon(Icons.camera_alt_rounded,
                color: Colors.black, size: 12)),
        ]),
        const SizedBox(height: 14),
        const Text('Rahul Sharma', style: TextStyle(
            fontFamily: 'Georgia', fontSize: 22, color: Colors.white,
            fontWeight: FontWeight.w600, letterSpacing: -0.3)),
        const SizedBox(height: 4),
        Text('rahul.sharma@gmail.com', style: TextStyle(
            fontFamily: 'Georgia', fontSize: 13,
            color: Colors.white.withOpacity(0.4))),
        const SizedBox(height: 12),
        // Member badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFF2A2A2A), width: 1),
              borderRadius: BorderRadius.circular(20)),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Container(width: 6, height: 6, decoration: const BoxDecoration(
                color: Colors.white, shape: BoxShape.circle)),
            const SizedBox(width: 7),
            const Text('Pro Member', style: TextStyle(
                fontFamily: 'Georgia', fontSize: 11, color: Colors.white,
                fontWeight: FontWeight.w600, letterSpacing: 0.5)),
          ])),
        const SizedBox(height: 24),
      ]),
    ),
  );

  Widget _buildStatsRow() => Padding(
    padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
          color: const Color(0xFF141414),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFF2A2A2A), width: 1)),
      child: Row(children: [
        _StatItem('12', 'Courses'),
        _Divider(),
        _StatItem('48h', 'Learned'),
        _Divider(),
        _StatItem('5', 'Badges'),
        _Divider(),
        _StatItem('320', 'Points'),
      ]),
    ),
  );

  Widget _buildAchievements() => Padding(
    padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Achievements', style: TextStyle(fontFamily: 'Georgia',
          fontSize: 16, color: Colors.white, fontWeight: FontWeight.w600)),
      const SizedBox(height: 14),
      Row(children: [
        _Badge2('🏆', 'Top\nLearner',  true),
        const SizedBox(width: 10),
        _Badge2('🔥', '7-Day\nStreak', true),
        const SizedBox(width: 10),
        _Badge2('⚡', 'Fast\nFinisher', true),
        const SizedBox(width: 10),
        _Badge2('🎯', 'Perfect\nScore',  false),
        const SizedBox(width: 10),
        _Badge2('💎', 'Pro\nMember',    false),
      ]),
    ]),
  );

  Widget _buildSettingsSection() => Padding(
    padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Account', style: TextStyle(fontFamily: 'Georgia',
          fontSize: 16, color: Colors.white, fontWeight: FontWeight.w600)),
      const SizedBox(height: 12),
      _SettingsTile(Icons.person_outline_rounded, 'Edit Profile', onTap: () {}),
      _SettingsTile(Icons.download_outlined, 'Downloaded Courses', onTap: () {}),
      _SettingsTile(Icons.notifications_outlined, 'Notifications', onTap: () {}),
      _SettingsTile(Icons.language_outlined, 'Language', trailing: 'English', onTap: () {}),
      const SizedBox(height: 20),
      const Text('Support', style: TextStyle(fontFamily: 'Georgia',
          fontSize: 16, color: Colors.white, fontWeight: FontWeight.w600)),
      const SizedBox(height: 12),
      _SettingsTile(Icons.help_outline_rounded, 'Help & FAQ', onTap: () {}),
      _SettingsTile(Icons.privacy_tip_outlined, 'Privacy Policy', onTap: () {}),
      _SettingsTile(Icons.star_outline_rounded, 'Rate the App', onTap: () {}),
      const SizedBox(height: 20),
      _PressBtn2(label: 'Sign Out', onTap: _signOut),
    ]),
  );

  void _showSettings() => showModalBottomSheet(
    context: context,
    backgroundColor: const Color(0xFF141414),
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    builder: (_) => Padding(
      padding: const EdgeInsets.all(24),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 36, height: 3,
            decoration: BoxDecoration(color: Colors.white24,
                borderRadius: BorderRadius.circular(2))),
        const SizedBox(height: 20),
        const Text('Settings', style: TextStyle(fontFamily: 'Georgia',
            fontSize: 16, color: Colors.white, fontWeight: FontWeight.w600)),
        const SizedBox(height: 24),
      ]),
    ),
  );

  void _signOut() {
    showDialog(context: context, builder: (_) => AlertDialog(
      backgroundColor: const Color(0xFF141414),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Sign Out', style: TextStyle(fontFamily: 'Georgia',
          color: Colors.white, fontWeight: FontWeight.w600)),
      content: Text('Are you sure you want to sign out?',
          style: TextStyle(fontFamily: 'Georgia',
              color: Colors.white.withOpacity(0.6))),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(fontFamily: 'Georgia',
                color: Colors.white.withOpacity(0.5)))),
        TextButton(onPressed: () {
          Navigator.pop(context);
          // navigate to login
        },
            child: const Text('Sign Out', style: TextStyle(
                fontFamily: 'Georgia', color: Colors.white,
                fontWeight: FontWeight.w700))),
      ],
    ));
  }
}

// Helpers
class _StatItem extends StatelessWidget {
  final String value, label;
  const _StatItem(this.value, this.label);
  @override Widget build(BuildContext context) => Expanded(child: Column(children: [
    Text(value, style: const TextStyle(fontFamily: 'Georgia', fontSize: 18,
        color: Colors.white, fontWeight: FontWeight.w700)),
    Text(label, style: TextStyle(fontFamily: 'Georgia', fontSize: 10,
        color: Colors.white.withOpacity(0.4))),
  ]));
}
class _Divider extends StatelessWidget {
  @override Widget build(BuildContext context) =>
      Container(width: 1, height: 32, color: const Color(0xFF2A2A2A));
}
class _Badge2 extends StatelessWidget {
  final String emoji, label; final bool earned;
  const _Badge2(this.emoji, this.label, this.earned);
  @override Widget build(BuildContext context) => Expanded(child: Column(children: [
    Container(
      width: 52, height: 52,
      decoration: BoxDecoration(
          color: earned ? const Color(0xFF1E1E1E) : const Color(0xFF111111),
          shape: BoxShape.circle,
          border: Border.all(
              color: earned ? const Color(0xFF3A3A3A) : const Color(0xFF1E1E1E),
              width: 1)),
      child: Center(child: Text(emoji,
          style: TextStyle(fontSize: 22,
              color: earned ? null : const Color(0x26FFFFFF))))),
    const SizedBox(height: 6),
    Text(label, textAlign: TextAlign.center,
        style: TextStyle(fontFamily: 'Georgia', fontSize: 9,
            color: earned
                ? Colors.white.withOpacity(0.6)
                : Colors.white.withOpacity(0.2), height: 1.3)),
  ]));
}
class _SettingsTile extends StatelessWidget {
  final IconData icon; final String title;
  final String? trailing; final VoidCallback onTap;
  const _SettingsTile(this.icon, this.title, {this.trailing, required this.onTap});
  @override Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
          color: const Color(0xFF141414),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFF2A2A2A), width: 1)),
      child: Row(children: [
        Icon(icon, color: Colors.white.withOpacity(0.6), size: 18),
        const SizedBox(width: 14),
        Expanded(child: Text(title, style: const TextStyle(
            fontFamily: 'Georgia', fontSize: 13, color: Colors.white))),
        if (trailing != null) Text(trailing!, style: TextStyle(
            fontFamily: 'Georgia', fontSize: 12,
            color: Colors.white.withOpacity(0.35))),
        const SizedBox(width: 4),
        Icon(Icons.chevron_right_rounded,
            color: Colors.white.withOpacity(0.3), size: 18),
      ]),
    ),
  );
}
class _PressBtn extends StatelessWidget {
  final IconData icon; final VoidCallback onTap;
  const _PressBtn(this.icon, {required this.onTap});
  @override Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 40, height: 40,
      decoration: BoxDecoration(
          color: const Color(0xFF141414),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFF2A2A2A), width: 1)),
      child: Icon(icon, color: Colors.white.withOpacity(0.7), size: 18)));
}
class _PressBtn2 extends StatelessWidget {
  final String label; final VoidCallback onTap;
  const _PressBtn2({required this.label, required this.onTap});
  @override Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: double.infinity, height: 50,
      decoration: BoxDecoration(
          color: const Color(0xFF141414),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFF2A2A2A), width: 1)),
      child: Center(child: Text(label, style: const TextStyle(
          fontFamily: 'Georgia', fontSize: 13, color: Colors.white,
          fontWeight: FontWeight.w600)))));
}


// ═══════════════════════════════════════════════
//  SEARCH SCREEN
// ═══════════════════════════════════════════════
class SearchScreen extends StatefulWidget {
  @override _SearchScreenState createState() => _SearchScreenState();
}

final List<Course> _kCourses = [
  Course(
    id: '42',
    duration: '2',
    lessons: 2,
    students: 22,
    rating: 22,
    imageUrl: 'assets/imgs.png',
    level: '3',
    title: 'Flutter Masterclass',
    instructor: 'John Doe',
    category: 'Flutter',
  ),
  Course(
    id: '32',
    duration: '2',
    lessons: 2,
   imageUrl: 'assets/imgs.png',
    students: 22,
    rating: 22,
    level: '3',
    title: 'Dart for Beginners',
    instructor: 'Jane Smith',
    category: 'Dart',
  ),
  Course(
    id: '12',
    duration: '2',
    lessons: 2,
    imageUrl: 'assets/imgs.png',
    students: 22,
    rating: 22,
    level: '3',
    title: 'Firebase Complete Guide',
    instructor: 'Alex Johnson',
    category: 'Firebase',
  ),
  Course(
    id: '22',
    duration: '2',
    lessons: 2,
    students: 22,
    rating: 22,
    level: '3',
    imageUrl: 'assets/imgs.png',
    title: 'UI Design Basics',
    instructor: 'Emily Davis',
    category: 'Design',
  ),
];
class _SearchScreenState extends State<SearchScreen> {
  final _ctrl = TextEditingController();
  final _focus = FocusNode();
  String _query = '';
  int _selectedCat = 0;

  final _trending = ['Flutter', 'Dart', 'Firebase', 'UI Design',
      'State Management', 'API Integration'];

  List<Course> get _results => _query.isEmpty
      ? _kCourses
      : _kCourses.where((c) =>
          c.title.toLowerCase().contains(_query.toLowerCase()) ||
          c.instructor.toLowerCase().contains(_query.toLowerCase()) ||
          c.category.toLowerCase().contains(_query.toLowerCase())).toList();

  @override void dispose() {
    _ctrl.dispose(); _focus.dispose(); super.dispose();
  }

  @override Widget build(BuildContext context) => AnnotatedRegion<SystemUiOverlayStyle>(
    value: SystemUiOverlayStyle.light,
    child: Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: SafeArea(child: Column(children: [
        _buildSearchBar(),
        if (_query.isEmpty) _buildTrending(),
        if (_query.isNotEmpty) _buildResultsHeader(),
        Expanded(child: _query.isEmpty
            ? _buildAllCourses()
            : _buildResults()),
      ])),
    ),
  );

  Widget _buildSearchBar() => Padding(
    padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
    child: Container(
      height: 50,
      decoration: BoxDecoration(
          color: const Color(0xFF141414),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: _focus.hasFocus
                  ? Colors.white.withOpacity(0.4)
                  : const Color(0xFF2A2A2A), width: 1)),
      child: Row(children: [
        const SizedBox(width: 14),
        Icon(Icons.search_rounded, color: Colors.white.withOpacity(0.4), size: 18),
        const SizedBox(width: 10),
        Expanded(child: TextField(
          controller: _ctrl,
          focusNode: _focus,
          autofocus: true,
          onChanged: (v) => setState(() => _query = v),
          style: const TextStyle(fontFamily: 'Georgia',
              color: Colors.white, fontSize: 14),
          cursorColor: Colors.white,
          decoration: InputDecoration(
              border: InputBorder.none, isDense: true,
              contentPadding: EdgeInsets.zero,
              hintText: 'Search courses, topics…',
              hintStyle: TextStyle(fontFamily: 'Georgia', fontSize: 14,
                  color: Colors.white.withOpacity(0.25))),
        )),
        if (_query.isNotEmpty) GestureDetector(
          onTap: () { _ctrl.clear(); setState(() => _query = ''); },
          child: Padding(
            padding: const EdgeInsets.only(right: 14),
            child: Icon(Icons.close_rounded,
                color: Colors.white.withOpacity(0.4), size: 18))),
      ]),
    ),
  );

  Widget _buildTrending() => Padding(
    padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Trending', style: TextStyle(fontFamily: 'Georgia', fontSize: 13,
          color: Colors.white.withOpacity(0.5), letterSpacing: 1)),
      const SizedBox(height: 12),
      Wrap(spacing: 8, runSpacing: 8, children: _trending.map((t) =>
          GestureDetector(
            onTap: () { _ctrl.text = t; setState(() => _query = t); },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                  color: const Color(0xFF141414),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF2A2A2A), width: 1)),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.trending_up_rounded,
                    color: Colors.white.withOpacity(0.4), size: 12),
                const SizedBox(width: 6),
                Text(t, style: TextStyle(fontFamily: 'Georgia', fontSize: 12,
                    color: Colors.white.withOpacity(0.7))),
              ])),
          )).toList()),
    ]),
  );

  Widget _buildResultsHeader() => Padding(
    padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
    child: Row(children: [
      Text('${_results.length} results for "$_query"',
          style: TextStyle(fontFamily: 'Georgia', fontSize: 13,
              color: Colors.white.withOpacity(0.5))),
    ]),
  );

  Widget _buildAllCourses() => ListView.separated(
    physics: const BouncingScrollPhysics(),
    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
    itemCount: _kCourses.length,
    separatorBuilder: (_, __) => const SizedBox(height: 10),
    itemBuilder: (_, i) => _SearchResultTile(
        course: _kCourses[i],
        onTap: () => Navigator.push(context, _fade(
            CourseDetailScreen(course: _kCourses[i])))),
  );

  Widget _buildResults() => _results.isEmpty
      ? Center(child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off_rounded,
                color: Colors.white.withOpacity(0.2), size: 48),
            const SizedBox(height: 12),
            Text('No courses found', style: TextStyle(fontFamily: 'Georgia',
                fontSize: 15, color: Colors.white.withOpacity(0.4))),
          ]))
      : ListView.separated(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          itemCount: _results.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (_, i) => _SearchResultTile(
              course: _results[i],
              onTap: () => Navigator.push(context, _fade(
                  CourseDetailScreen(course: _results[i])))),
        );

  PageRoute _fade(Widget page) => PageRouteBuilder(
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, a, __, c) => FadeTransition(opacity: a, child: c),
      transitionDuration: const Duration(milliseconds: 350));
}

class _SearchResultTile extends StatelessWidget {
  final Course course; final VoidCallback onTap;
  const _SearchResultTile({required this.course, required this.onTap});
  @override Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: const Color(0xFF141414),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF2A2A2A), width: 1)),
      child: Row(children: [
        Container(width: 56, height: 56,
            decoration: BoxDecoration(color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(10)),
            child: Center(child: Icon(Icons.play_circle_outline,
                color: Colors.white.withOpacity(0.3), size: 24))),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(course.title.replaceAll('\n', ' '),
                  maxLines: 2, overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontFamily: 'Georgia', fontSize: 13,
                      color: Colors.white, fontWeight: FontWeight.w600,
                      height: 1.3)),
              const SizedBox(height: 4),
              Text(course.instructor, style: TextStyle(fontFamily: 'Georgia',
                  fontSize: 11, color: Colors.white.withOpacity(0.4))),
              const SizedBox(height: 4),
              Row(children: [
                Icon(Icons.star_rounded, color: Colors.white, size: 11),
                const SizedBox(width: 3),
                Text('${course.rating}', style: TextStyle(fontFamily: 'Georgia',
                    fontSize: 11, color: Colors.white.withOpacity(0.6))),
                const SizedBox(width: 8),
                Text(course.level, style: TextStyle(fontFamily: 'Georgia',
                    fontSize: 11, color: Colors.white.withOpacity(0.35))),
              ]),
            ])),
      ]),
    ),
  );
}


// ═══════════════════════════════════════════════
//  NOTIFICATIONS SCREEN
// ═══════════════════════════════════════════════
class NotificationsScreen extends StatelessWidget {
  final _notifs = const [
    _Notif('New lesson available', 'Flutter Masterclass › Advanced Animations is now live!',
        '2m ago', Icons.play_lesson_outlined, false),
    _Notif('Certificate earned! 🎉', 'You completed "Dart Fundamentals". Download your certificate.',
        '1h ago', Icons.emoji_events_outlined, false),
    _Notif('Streak reminder 🔥', "You're on a 7-day streak. Keep it up!",
        '3h ago', Icons.local_fire_department_outlined, true),
    _Notif('New course alert', 'Python for Data Science is now available.',
        '1d ago', Icons.new_releases_outlined, true),
    _Notif('Weekly progress', "You've learned 4.5 hours this week. Great job!",
        '2d ago', Icons.insights_outlined, true),
  ];

  @override Widget build(BuildContext context) => AnnotatedRegion<SystemUiOverlayStyle>(
    value: SystemUiOverlayStyle.light,
    child: Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: SafeArea(child: Column(children: [
        // Header
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
          child: Row(children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 38, height: 38,
                decoration: BoxDecoration(
                    color: const Color(0xFF141414),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFF2A2A2A), width: 1)),
                child: const Center(child: Icon(Icons.arrow_back_ios_new_rounded,
                    color: Colors.white, size: 14)))),
            const SizedBox(width: 14),
            const Text('Notifications', style: TextStyle(
                fontFamily: 'Georgia', fontSize: 20, color: Colors.white,
                fontWeight: FontWeight.w600, letterSpacing: -0.3)),
            const Spacer(),
            Text('Mark all read', style: TextStyle(fontFamily: 'Georgia',
                fontSize: 12, color: Colors.white.withOpacity(0.4))),
          ]),
        ),
        // List
        Expanded(child: ListView.separated(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: _notifs.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (_, i) => _NotifTile(notif: _notifs[i]),
        )),
      ])),
    ),
  );
}

class _Notif {
  final String title, body, time; final IconData icon; final bool isRead;
  const _Notif(this.title, this.body, this.time, this.icon, this.isRead);
}

class _NotifTile extends StatelessWidget {
  final _Notif notif;
  const _NotifTile({required this.notif});
  @override Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
        color: notif.isRead
            ? const Color(0xFF0E0E0E)
            : const Color(0xFF141414),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: notif.isRead
                ? const Color(0xFF1E1E1E)
                : const Color(0xFF2A2A2A), width: 1)),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
        width: 40, height: 40,
        decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E), borderRadius: BorderRadius.circular(10)),
        child: Icon(notif.icon,
            color: notif.isRead
                ? Colors.white.withOpacity(0.3)
                : Colors.white.withOpacity(0.8), size: 18)),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Text(notif.title, style: TextStyle(
              fontFamily: 'Georgia', fontSize: 13,
              color: notif.isRead
                  ? Colors.white.withOpacity(0.5)
                  : Colors.white,
              fontWeight: notif.isRead
                  ? FontWeight.w400 : FontWeight.w600))),
          const SizedBox(width: 8),
          if (!notif.isRead) Container(width: 7, height: 7,
              decoration: const BoxDecoration(
                  color: Colors.white, shape: BoxShape.circle)),
        ]),
        const SizedBox(height: 4),
        Text(notif.body, style: TextStyle(fontFamily: 'Georgia', fontSize: 12,
            color: Colors.white.withOpacity(notif.isRead ? 0.3 : 0.5),
            height: 1.5)),
        const SizedBox(height: 6),
        Text(notif.time, style: TextStyle(fontFamily: 'Georgia', fontSize: 10,
            color: Colors.white.withOpacity(0.25))),
      ])),
    ]),
  );
}