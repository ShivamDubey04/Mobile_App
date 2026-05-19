import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class VideoPlayerScreen extends StatefulWidget {
  final String title;
  final String lessonTitle;
  const VideoPlayerScreen({required this.title, required this.lessonTitle});
  @override _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen>
    with TickerProviderStateMixin {

  bool _isPlaying   = false;
  bool _showControls = true;
  bool _isFullscreen = false;
  bool _isLandscape  = false;
  double _progress   = 0.28;   // 28% through
  double _volume     = 0.8;
  double _playbackSpeed = 1.0;
  int _currentLesson = 1;
  Timer? _hideTimer;
  Timer? _progressTimer;

  late AnimationController _controlsCtrl;
  late Animation<double>   _controlsFade;
  late AnimationController _playPauseCtrl;

  final _speeds = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0];

  final _chapters = [
    _Chapter('Introduction & Overview',           '00:00', 0.0,  true),
    _Chapter('Setting up the environment',        '05:30', 0.18, true),
    _Chapter('Your first Flutter widget',         '12:45', 0.28, false),
    _Chapter('Understanding the widget tree',     '22:10', 0.45, false),
    _Chapter('State management basics',           '34:00', 0.62, false),
    _Chapter('Building the complete UI',          '45:20', 0.78, false),
    _Chapter('Testing & Debugging',               '54:10', 0.90, false),
  ];

  int _tab = 0; // 0=chapters, 1=notes

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    _controlsCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 250));
    _controlsFade = CurvedAnimation(parent: _controlsCtrl, curve: Curves.easeOut);
    _controlsCtrl.value = 1;

    _playPauseCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 200));

    _resetHideTimer();
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    _progressTimer?.cancel();
    _controlsCtrl.dispose();
    _playPauseCtrl.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    if (_isLandscape) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    }
    super.dispose();
  }

  void _togglePlay() {
    setState(() => _isPlaying = !_isPlaying);
    if (_isPlaying) {
      _playPauseCtrl.forward();
      _startProgress();
    } else {
      _playPauseCtrl.reverse();
      _progressTimer?.cancel();
    }
    _resetHideTimer();
  }

  void _startProgress() {
    _progressTimer?.cancel();
    _progressTimer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      if (!mounted || !_isPlaying) return;
      setState(() { _progress = (_progress + 0.001).clamp(0.0, 1.0); });
    });
  }

  void _resetHideTimer() {
    _hideTimer?.cancel();
    if (!_showControls) {
      setState(() => _showControls = true);
      _controlsCtrl.forward();
    }
    _hideTimer = Timer(const Duration(seconds: 3), () {
      if (_isPlaying && mounted) {
        setState(() => _showControls = false);
        _controlsCtrl.reverse();
      }
    });
  }

  void _toggleFullscreen() {
    setState(() => _isLandscape = !_isLandscape);
    if (_isLandscape) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
    } else {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    }
  }

  String _fmtTime(double progress) {
    final totalSec = (progress * 3660).round(); // ~61 min video
    final m = totalSec ~/ 60;
    final s = totalSec % 60;
    return '${m.toString().padLeft(2,'0')}:${s.toString().padLeft(2,'0')}';
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Column(children: [
          // ── Video player area ──
          _buildVideoArea(),
          // ── Bottom panel ──
          Expanded(child: _buildBottomPanel()),
        ]),
      ),
    );
  }

  // ── Video area ────────────────────────────
  Widget _buildVideoArea() => GestureDetector(
    onTap: _resetHideTimer,
    child: Container(
      color: Colors.black,
      height: MediaQuery.of(context).size.width * 9 / 16,
      child: Stack(children: [
        // "Video" placeholder
        Container(
          color: const Color(0xFF0D0D0D),
          child: Center(child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.play_circle_fill,
                  color: Colors.white.withOpacity(0.05), size: 80),
              const SizedBox(height: 8),
              Text('Video playing…',
                  style: TextStyle(fontFamily: 'Georgia', fontSize: 12,
                      color: Colors.white.withOpacity(0.15))),
            ],
          )),
        ),

        // Controls overlay
        FadeTransition(
          opacity: _controlsFade,
          child: Container(
            decoration: const BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0x99000000), Colors.transparent,
                      Colors.transparent, Color(0xCC000000)])),
            child: Column(children: [
              // Top bar
              _buildTopBar(),
              // Centre controls
              Expanded(child: _buildCentreControls()),
              // Progress + bottom
              _buildProgressBar(),
            ]),
          ),
        ),
      ]),
    ),
  );

  Widget _buildTopBar() => SafeArea(
    bottom: false,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(children: [
        _CtrlBtn(Icons.arrow_back_ios_new_rounded,
            onTap: () => Navigator.pop(context)),
        const SizedBox(width: 12),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.title, style: const TextStyle(
                fontFamily: 'Georgia', fontSize: 11,
                color: Colors.white, fontWeight: FontWeight.w700,
                letterSpacing: 0.3)),
            Text(widget.lessonTitle, style: TextStyle(
                fontFamily: 'Georgia', fontSize: 10,
                color: Colors.white.withOpacity(0.55)),
                maxLines: 1, overflow: TextOverflow.ellipsis),
          ],
        )),
        _CtrlBtn(Icons.settings_outlined, onTap: _showSettings),
        const SizedBox(width: 6),
        _CtrlBtn(_isLandscape
            ? Icons.fullscreen_exit_rounded
            : Icons.fullscreen_rounded,
            onTap: _toggleFullscreen),
      ]),
    ),
  );

  Widget _buildCentreControls() => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      _CtrlBtn(Icons.replay_10_rounded, size: 28,
          onTap: () => setState(() =>
              _progress = (_progress - 0.045).clamp(0, 1))),
      const SizedBox(width: 24),
      GestureDetector(
        onTap: _togglePlay,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 64, height: 64,
          decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5)),
          child: Center(child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Icon(_isPlaying
                ? Icons.pause_rounded
                : Icons.play_arrow_rounded,
                key: ValueKey(_isPlaying),
                color: Colors.white, size: 34))),
        ),
      ),
      const SizedBox(width: 24),
      _CtrlBtn(Icons.forward_10_rounded, size: 28,
          onTap: () => setState(() =>
              _progress = (_progress + 0.045).clamp(0, 1))),
    ],
  );

  Widget _buildProgressBar() => Padding(
    padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
    child: Column(children: [
      // Seekbar
      SliderTheme(
        data: SliderTheme.of(context).copyWith(
          trackHeight: 2.5,
          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
          overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
          activeTrackColor: Colors.white,
          inactiveTrackColor: Colors.white24,
          thumbColor: Colors.white,
          overlayColor: Colors.white24,
        ),
        child: Slider(
          value: _progress,
          onChanged: (v) { setState(() => _progress = v); _resetHideTimer(); },
        ),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Row(children: [
          Text(_fmtTime(_progress), style: const TextStyle(
              fontFamily: 'Georgia', fontSize: 10, color: Colors.white70)),
          const Spacer(),
          // Speed chip
          GestureDetector(
            onTap: _cycleSpeed,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.white30, width: 1),
                  borderRadius: BorderRadius.circular(4)),
              child: Text('${_playbackSpeed}x', style: const TextStyle(
                  fontFamily: 'Georgia', fontSize: 10, color: Colors.white)),
            ),
          ),
          const SizedBox(width: 8),
          Text(_fmtTime(1.0), style: TextStyle(
              fontFamily: 'Georgia', fontSize: 10,
              color: Colors.white.withOpacity(0.5))),
        ]),
      ),
    ]),
  );

  // ── Bottom panel ─────────────────────────
  Widget _buildBottomPanel() => Container(
    color: const Color(0xFF0A0A0A),
    child: Column(children: [
      // Tab bar
      Container(
        decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(
                color: Color(0xFF2A2A2A), width: 1))),
        child: Row(children: [
          _TabBtn('Chapters', 0),
          _TabBtn('Notes', 1),
        ]),
      ),
      // Content
      Expanded(child: _tab == 0 ? _buildChapters() : _buildNotes()),
    ]),
  );

  Widget _TabBtn(String label, int index) {
    final active = _tab == index;
    return Expanded(child: GestureDetector(
      onTap: () => setState(() => _tab = index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
            border: Border(bottom: BorderSide(
                color: active ? Colors.white : Colors.transparent,
                width: 2))),
        child: Text(label, textAlign: TextAlign.center,
            style: TextStyle(fontFamily: 'Georgia', fontSize: 12,
                color: active ? Colors.white : Colors.white38,
                fontWeight: active ? FontWeight.w700 : FontWeight.w400)),
      ),
    ));
  }

  Widget _buildChapters() => ListView.builder(
    physics: const BouncingScrollPhysics(),
    itemCount: _chapters.length,
    itemBuilder: (_, i) {
      final ch = _chapters[i];
      final isCurrent = i == 2;
      return GestureDetector(
        onTap: () => setState(() => _progress = ch.progress),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
          decoration: BoxDecoration(
              color: isCurrent
                  ? Colors.white.withOpacity(0.05)
                  : Colors.transparent,
              border: Border(bottom: BorderSide(
                  color: const Color(0xFF1E1E1E), width: 1))),
          child: Row(children: [
            // Number / check
            Container(
              width: 28, height: 28,
              decoration: BoxDecoration(
                  color: ch.isWatched
                      ? Colors.white
                      : isCurrent
                          ? Colors.white.withOpacity(0.15)
                          : const Color(0xFF2A2A2A),
                  shape: BoxShape.circle),
              child: Center(child: ch.isWatched
                  ? const Icon(Icons.check_rounded, color: Colors.black, size: 14)
                  : Text('${i + 1}', style: TextStyle(
                      fontFamily: 'Georgia', fontSize: 10,
                      color: isCurrent ? Colors.white : Colors.white38,
                      fontWeight: FontWeight.w600)))),
            const SizedBox(width: 12),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(ch.title, style: TextStyle(
                    fontFamily: 'Georgia', fontSize: 13,
                    color: isCurrent
                        ? Colors.white
                        : ch.isWatched
                            ? Colors.white.withOpacity(0.5)
                            : Colors.white.withOpacity(0.7),
                    fontWeight: isCurrent ? FontWeight.w600 : FontWeight.w400)),
                const SizedBox(height: 2),
                Text(ch.timestamp, style: TextStyle(
                    fontFamily: 'Georgia', fontSize: 10,
                    color: Colors.white.withOpacity(0.3))),
              ],
            )),
            if (isCurrent)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(5)),
                child: const Text('NOW', style: TextStyle(
                    fontFamily: 'Georgia', fontSize: 8,
                    color: Colors.black, fontWeight: FontWeight.w700,
                    letterSpacing: 1))),
          ]),
        ),
      );
    },
  );

  Widget _buildNotes() => Padding(
    padding: const EdgeInsets.all(20),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Lesson Notes', style: const TextStyle(
          fontFamily: 'Georgia', fontSize: 14, color: Colors.white,
          fontWeight: FontWeight.w600)),
      const SizedBox(height: 4),
      Text('Notes are saved automatically with timestamps.',
          style: TextStyle(fontFamily: 'Georgia', fontSize: 11,
              color: Colors.white.withOpacity(0.4))),
      const SizedBox(height: 16),
      Expanded(
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
              color: const Color(0xFF141414),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFF2A2A2A), width: 1)),
          child: TextField(
            maxLines: null, expands: true,
            style: TextStyle(fontFamily: 'Georgia', fontSize: 13,
                color: Colors.white.withOpacity(0.8), height: 1.6),
            cursorColor: Colors.white,
            decoration: InputDecoration(
                border: InputBorder.none, isDense: true,
                contentPadding: EdgeInsets.zero,
                hintText: 'Type your notes here…',
                hintStyle: TextStyle(fontFamily: 'Georgia', fontSize: 13,
                    color: Colors.white.withOpacity(0.2))),
          ),
        ),
      ),
      const SizedBox(height: 12),
      Row(children: [
        Text(_fmtTime(_progress), style: TextStyle(
            fontFamily: 'Georgia', fontSize: 11,
            color: Colors.white.withOpacity(0.35))),
        const Spacer(),
        GestureDetector(
          onTap: () {},
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(8)),
            child: const Text('Save Note', style: TextStyle(
                fontFamily: 'Georgia', fontSize: 12,
                color: Colors.black, fontWeight: FontWeight.w700))),
        ),
      ]),
    ]),
  );

  void _cycleSpeed() {
    final idx = _speeds.indexOf(_playbackSpeed);
    setState(() => _playbackSpeed = _speeds[(idx + 1) % _speeds.length]);
  }

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
        const Text('Playback Speed', style: TextStyle(
            fontFamily: 'Georgia', fontSize: 15, color: Colors.white,
            fontWeight: FontWeight.w600)),
        const SizedBox(height: 16),
        Wrap(spacing: 10, children: _speeds.map((s) {
          final sel = s == _playbackSpeed;
          return GestureDetector(
            onTap: () { setState(() => _playbackSpeed = s); Navigator.pop(context); },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              decoration: BoxDecoration(
                  color: sel ? Colors.white : const Color(0xFF2A2A2A),
                  borderRadius: BorderRadius.circular(8)),
              child: Text('${s}x', style: TextStyle(
                  fontFamily: 'Georgia', fontSize: 13,
                  color: sel ? Colors.black : Colors.white,
                  fontWeight: FontWeight.w600))));
        }).toList()),
        const SizedBox(height: 24),
      ]),
    ),
  );
}

class _Chapter {
  final String title, timestamp; final double progress; final bool isWatched;
  const _Chapter(this.title, this.timestamp, this.progress, this.isWatched);
}

class _CtrlBtn extends StatelessWidget {
  final IconData icon; final VoidCallback onTap; final double size;
  const _CtrlBtn(this.icon, {required this.onTap, this.size = 20});
  @override Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Padding(padding: const EdgeInsets.all(8),
        child: Icon(icon, color: Colors.white, size: size)));
}