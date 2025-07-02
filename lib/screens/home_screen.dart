import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'dart:math';
import '../widgets/scratch_card.dart';
import '../models/scratch_state.dart';
import 'settings_screen.dart';
import '../utils/language_utils.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.title,
    required this.onLanguageChanged,
    required this.currentLanguage,
  });
  final String title;
  final Function(String) onLanguageChanged;
  final String currentLanguage;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late ScratchState scratchState;
  late List<ScratchState> scratchStates;
  List<Key> cardKeys = [];

  List<Map<String, String>> cardConfigs = [];

  // デフォルト設定
  final List<Map<String, String>> defaultConfigs = [
    {'title': 'カード1', 'completedMessage': 'カード1の結果'},
    {'title': 'カード2', 'completedMessage': 'カード2の結果'},
    {'title': 'カード3', 'completedMessage': 'カード3の結果'},
    {'title': 'カード4', 'completedMessage': 'カード4の結果'},
  ];

  // デフォルトのタイトルを返す
  String _getDefaultTitle(int index) {
    return LanguageUtils.getCardTitle(index, widget.currentLanguage);
  }

  // デフォルトのメッセージを返す
  String _getDefaultMessage(int index) {
    return LanguageUtils.getCardResult(index, widget.currentLanguage);
  }

  final RefreshController _refreshController = RefreshController(
    initialRefresh: false,
  );

  @override
  void initState() {
    super.initState();
    // 初期値を設定
    scratchStates = List.generate(4, (index) => ScratchState(maxCount: 4));
    cardKeys = List.generate(4, (index) => UniqueKey());
    // デフォルト設定で初期化
    cardConfigs = List.generate(
      4,
      (index) => {
        'title': _getDefaultTitle(index),
        'completedMessage': _getDefaultMessage(index),
      },
    );
    _loadSettings();
  }

  // ランダム選択を更新するメソッド（全体）
  Future<void> _updateRandomChoices() async {
    final prefs = await SharedPreferences.getInstance();
    final random = Random();

    for (int i = 0; i < cardConfigs.length; i++) {
      final multiChoice = prefs.getString('card_multichoice_$i') ?? '';

      // 複数選択肢がある場合はランダムに選択(、または,)
      if (multiChoice.isNotEmpty) {
        final choices = multiChoice
            .split(RegExp(r'[、,]\s*'))
            .where((s) => s.trim().isNotEmpty)
            .toList();
        if (choices.isNotEmpty) {
          final randomIndex = random.nextInt(choices.length);
          final randomChoice = choices[randomIndex].trim();

          if (mounted) {
            setState(() {
              cardConfigs[i]['completedMessage'] = randomChoice;
            });
          }
        }
      }
    }
  }

  // 個別カードのランダム選択を更新するメソッド（リセットボタンを押した時）
  Future<void> _updateSingleRandomChoice(int index) async {
    final prefs = await SharedPreferences.getInstance();
    final multiChoice = prefs.getString('card_multichoice_$index') ?? '';

    // 複数選択肢がある場合はランダムに選択(、または,)
    final choices = multiChoice
        .split(RegExp(r'[、,]\s*'))
        .where((s) => s.trim().isNotEmpty)
        .toList();
    if (choices.isNotEmpty) {
      final random = Random();
      final randomIndex = random.nextInt(choices.length);
      final randomChoice = choices[randomIndex].trim();

      if (mounted) {
        setState(() {
          cardConfigs[index]['completedMessage'] = randomChoice;
        });
      }
    }
  }

  // 設定を読み込む
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    // カード数を読み込み
    final cardCount = prefs.getInt('card_count') ?? 4;

    // スクラッチ状態とキーを初期化
    scratchStates = List.generate(
      cardCount,
      (index) => ScratchState(maxCount: cardCount),
    );
    cardKeys = List.generate(cardCount, (index) => UniqueKey());

    // カード設定を初期化
    cardConfigs = List.generate(cardCount, (index) {
      final savedTitle = prefs.getString('card_title_$index');
      final multiChoice = prefs.getString('card_multichoice_$index') ?? '';

      // タイトルが空またはnullの場合はデフォルト値を使用
      final title = (savedTitle == null || savedTitle.isEmpty)
          ? _getDefaultTitle(index)
          : savedTitle;

      // 複数選択肢がある場合はランダムに選択(、または,)
      String finalMessage = _getDefaultMessage(index);
      if (multiChoice.isNotEmpty) {
        final choices = multiChoice
            .split(RegExp(r'[、,]\s*'))
            .where((s) => s.trim().isNotEmpty)
            .toList();
        if (choices.isNotEmpty) {
          final random = Random();
          final randomIndex = random.nextInt(choices.length);
          finalMessage = choices[randomIndex].trim();
        }
      }

      return {'title': title, 'completedMessage': finalMessage};
    });

    // 設定を反映
    if (mounted) {
      setState(() {});
    }
  }

  void _onScratch(int index) {
    setState(() {
      scratchStates[index].increment();
    });
  }

  void _resetScratcher(int index) async {
    setState(() {
      scratchStates[index].reset();
    });
    // 個別リセット時はそのカードのみランダム選択を更新
    await _updateSingleRandomChoice(index);
  }

  // すべてリセットを押した時
  void _resetAll() async {
    setState(() {
      // すべてのスクラッチ状態をリセット
      for (var state in scratchStates) {
        state.reset();
      }
      // 新しいキーを生成してカードを完全にリセット
      cardKeys = List.generate(scratchStates.length, (index) => UniqueKey());
    });
    // リセット時にランダム選択を更新
    await _updateRandomChoices();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 上部
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          widget.title,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SettingsScreen(
                    onLanguageChanged: widget.onLanguageChanged,
                    currentLanguage: widget.currentLanguage,
                  ),
                ),
              );
              _loadSettings();
            },
            icon: const Icon(Icons.settings, color: Colors.black87, size: 28),
            tooltip: LanguageUtils.getSettingsText(
              'settings',
              widget.currentLanguage,
            ),
          ),
        ],
      ),

      // メインの部分
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: SmartRefresher(
          controller: _refreshController,
          enablePullDown: true,
          onRefresh: () async {
            _resetAll();
            await Future.delayed(const Duration(milliseconds: 500));
            _refreshController.refreshCompleted();
          },
          header: const ClassicHeader(),
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 1,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 2.3,
            ),
            itemCount: scratchStates.length,
            itemBuilder: (context, index) {
              final config = cardConfigs[index];
              return ScratchCard(
                key: cardKeys[index],
                index: index + 1,
                cardTitle: config['title']!,
                completedMessage: config['completedMessage']!,
                onScratch: () => _onScratch(index),
                onReset: () => _resetScratcher(index),
              );
            },
          ),
        ),
      ),
    );
  }
}
