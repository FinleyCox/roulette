import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:scratcher/scratcher.dart';
import '../utils/onboarding_content.dart';
import '../widgets/particle_overlay.dart';

/// 初回起動時のオンボーディング。
/// 1. 実際に削れるデモ  2. 選択肢の登録  3. リセット・プリセット・共有  4. テンプレート選択
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({
    super.key,
    required this.currentLanguage,
    required this.onLanguageChanged,
    required this.onFinished,
  });

  final String currentLanguage;
  final ValueChanged<String> onLanguageChanged;
  final VoidCallback onFinished;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  static const Color _bg = Color(0xFFF4F4F1);
  static const int _pageCount = 4;

  final PageController _controller = PageController();
  int _page = 0;
  bool _demoScratched = false;
  bool _demoStarted = false;
  String? _selectedTemplateId;
  bool _finishing = false;

  // 削りカスと開封時のバースト演出
  final StreamController<Offset> _touchStream =
      StreamController<Offset>.broadcast();
  final StreamController<Offset> _burstStream =
      StreamController<Offset>.broadcast();
  final GlobalKey _demoKey = GlobalKey();
  final GlobalKey<ScratcherState> _scratcherKey = GlobalKey<ScratcherState>();

  static const List<Color> _foilChips = [
    Color(0xFFFFB27A),
    Color(0xFFF07AA6),
    Color(0xFF8AA3F5),
    Color(0xFFFFFFFF),
  ];

  String t(String key) => OnboardingContent.text(key, widget.currentLanguage);

  @override
  void dispose() {
    _controller.dispose();
    _touchStream.close();
    _burstStream.close();
    super.dispose();
  }

  void _onDemoRevealed() {
    if (_demoScratched) return;
    setState(() => _demoScratched = true);
    HapticFeedback.mediumImpact();
    // 報酬カードのように、一定以上削ったら残りのカバーを一気に消す
    _scratcherKey.currentState?.reveal(
      duration: const Duration(milliseconds: 400),
    );
    final box = _demoKey.currentContext?.findRenderObject() as RenderBox?;
    if (box != null) {
      _burstStream.add(box.size.center(Offset.zero));
    }
  }

  void _next() {
    if (_page < _pageCount - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    } else {
      _finish();
    }
  }

  void _skip() {
    _controller.animateToPage(
      _pageCount - 1,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  Future<void> _finish() async {
    if (_finishing) return;
    _finishing = true;
    final templates = OnboardingContent.templates(widget.currentLanguage);
    final selected = templates
        .where((tpl) => tpl.id == _selectedTemplateId)
        .firstOrNull;
    if (selected != null) {
      await OnboardingContent.applyTemplate(selected);
    }
    await OnboardingContent.markDone();
    widget.onFinished();
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _page == _pageCount - 1;
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(isLast),
            Expanded(
              child: PageView(
                controller: _controller,
                // 1ページ目のスクラッチ操作がページ送りに奪われないよう、
                // スワイプでのページ移動は無効にしてボタンで進める
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (i) => setState(() => _page = i),
                children: [
                  _buildDemoPage(),
                  _buildInfoPage(
                    icon: Icons.settings,
                    title: t('p2Title'),
                    body: t('p2Body'),
                    example: t('p2Example'),
                  ),
                  _buildInfoPage(
                    icon: Icons.swipe_down,
                    title: t('p3Title'),
                    body: t('p3Body'),
                    extraIcons: const [Icons.bookmark_border, Icons.qr_code_2],
                  ),
                  _buildTemplatePage(),
                ],
              ),
            ),
            _buildIndicator(),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: _next,
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.black87,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    isLast ? t('start') : t('next'),
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(bool isLast) {
    const languages = {'ja': 'JA', 'en': 'EN', 'hi': 'HI'};
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          for (final entry in languages.entries)
            Padding(
              padding: const EdgeInsets.only(right: 6),
              child: ChoiceChip(
                label: Text(entry.value),
                selected: widget.currentLanguage == entry.key,
                onSelected: (_) {
                  setState(() => _selectedTemplateId = null);
                  widget.onLanguageChanged(entry.key);
                },
                showCheckmark: false,
                visualDensity: VisualDensity.compact,
              ),
            ),
          const Spacer(),
          if (!isLast)
            TextButton(
              onPressed: _skip,
              child: Text(
                t('skip'),
                style: const TextStyle(color: Colors.black54),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDemoPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _title(t('p1Title')),
          const SizedBox(height: 8),
          _body(t('p1Body')),
          const SizedBox(height: 28),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.black12),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: SizedBox(
                key: _demoKey,
                height: 130,
                width: double.infinity,
                child: Stack(
                  children: [
                    Listener(
                      onPointerMove: (e) => _touchStream.add(e.localPosition),
                      child: Scratcher(
                        key: _scratcherKey,
                        brushSize: 44,
                        threshold: 30,
                        color: const Color(0xFFEC4880),
                        image: Image.asset(
                          'assets/onboarding/scratch_foil.png',
                          fit: BoxFit.cover,
                        ),
                        onScratchStart: () {
                          if (!_demoStarted) {
                            setState(() => _demoStarted = true);
                          }
                        },
                        onThreshold: _onDemoRevealed,
                        child: Container(
                          alignment: Alignment.center,
                          color: const Color(0xFFFFF8F2),
                          child: AnimatedScale(
                            scale: _demoScratched ? 1.0 : 0.85,
                            duration: const Duration(milliseconds: 350),
                            curve: Curves.easeOutBack,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  t('p1ResultLabel'),
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Colors.black45,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  t('p1Result'),
                                  style: const TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    // カバー上の「ここを削る」表示（削り始めたら消える）
                    IgnorePointer(
                      child: AnimatedOpacity(
                        opacity: _demoStarted ? 0 : 1,
                        duration: const Duration(milliseconds: 250),
                        child: Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.touch_app,
                                color: Colors.white,
                                size: 26,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                t('p1Hint'),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black26,
                                      blurRadius: 6,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: ScratchEffectOverlay(
                        touchStream: _touchStream.stream,
                        burstStream: _burstStream.stream,
                        particleColors: _foilChips,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          AnimatedOpacity(
            opacity: _demoScratched ? 1 : 0,
            duration: const Duration(milliseconds: 300),
            child: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: _body(t('p1Done')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoPage({
    required IconData icon,
    required String title,
    required String body,
    String? example,
    List<IconData> extraIcons = const [],
  }) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _iconBubble(icon),
                for (final extra in extraIcons) ...[
                  const SizedBox(width: 12),
                  _iconBubble(extra),
                ],
              ],
            ),
          ),
          const SizedBox(height: 32),
          _title(title),
          const SizedBox(height: 12),
          _body(body),
          if (example != null) ...[
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.black26),
              ),
              child: Text(
                example,
                style: const TextStyle(fontSize: 15, color: Colors.black87),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTemplatePage() {
    final templates = OnboardingContent.templates(widget.currentLanguage);
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _title(t('p4Title')),
          const SizedBox(height: 8),
          _body(t('p4Body')),
          const SizedBox(height: 20),
          for (final tpl in templates)
            _templateTile(
              id: tpl.id,
              label: tpl.label,
              description: tpl.description,
              preview: tpl.cards.map((c) => c.$1).join(' / '),
            ),
          _templateTile(
            id: 'custom',
            label: t('custom'),
            description: t('customDesc'),
          ),
        ],
      ),
    );
  }

  Widget _templateTile({
    required String id,
    required String label,
    required String description,
    String? preview,
  }) {
    final selected = _selectedTemplateId == id;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: selected ? const Color(0xFFE8F0FE) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => setState(() => _selectedTemplateId = id),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: selected ? Colors.blue : Colors.black12,
                width: selected ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        description,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black54,
                        ),
                      ),
                      if (preview != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          preview,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black45,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Icon(
                  selected ? Icons.check_circle : Icons.circle_outlined,
                  color: selected ? Colors.blue : Colors.black26,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < _pageCount; i++)
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: i == _page ? 20 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: i == _page ? Colors.black87 : Colors.black26,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
      ],
    );
  }

  Widget _iconBubble(IconData icon) => Container(
    width: 72,
    height: 72,
    decoration: BoxDecoration(
      color: Colors.white,
      shape: BoxShape.circle,
      border: Border.all(color: Colors.black12),
    ),
    child: Icon(icon, size: 34, color: Colors.black87),
  );

  Widget _title(String text) => Text(
    text,
    style: const TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.bold,
      color: Colors.black87,
      height: 1.3,
    ),
  );

  Widget _body(String text) => Text(
    text,
    style: const TextStyle(fontSize: 16, color: Colors.black54, height: 1.6),
  );
}
