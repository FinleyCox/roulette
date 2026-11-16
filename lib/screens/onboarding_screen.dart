import 'package:flutter/material.dart';
import 'package:scratcher/scratcher.dart';
import '../utils/onboarding_content.dart';

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
  String? _selectedTemplateId;
  bool _finishing = false;

  String t(String key) => OnboardingContent.text(key, widget.currentLanguage);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
              child: Scratcher(
                key: ValueKey('demo-${widget.currentLanguage}'),
                brushSize: 44,
                threshold: 30,
                color: const Color(0xFFDBD8D8),
                onThreshold: () => setState(() => _demoScratched = true),
                child: Container(
                  height: 110,
                  width: double.infinity,
                  alignment: Alignment.center,
                  color: const Color(0xFFF9F8F6),
                  child: Text(
                    t('p1Result'),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(
              _demoScratched ? '' : t('p1Hint'),
              style: const TextStyle(color: Colors.black45),
            ),
          ),
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
