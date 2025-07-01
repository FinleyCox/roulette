import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'dart:math';
import '../widgets/scratch_card.dart';
import '../models/scratch_state.dart';
import 'settings_screen.dart';

/// TODO: 3, 4が個別リセットの時に連動して変更されるので別々にする

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.title});
  final String title;

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
    {'title': '🎯 ターゲット1', 'completedMessage': '🎉 1つ目クリア！'},
    {'title': '⚡ ターゲット2', 'completedMessage': '🌟 2つ目クリア！'},
    {'title': '🔥 ターゲット3', 'completedMessage': '💎 3つ目クリア！'},
    {'title': '🏆 最終ターゲット', 'completedMessage': '🎊 全ターゲットクリア！'},
  ];

  final RefreshController _refreshController = RefreshController(
    initialRefresh: false,
  );

  @override
  void initState() {
    super.initState();
    // 4つのスクラッチ状態を初期化
    scratchStates = List.generate(4, (index) => ScratchState(maxCount: 4));
    cardKeys = List.generate(4, (index) => UniqueKey());

    cardConfigs = List.from(defaultConfigs);
    _loadSettings();
  }

  // ランダム選択を更新するメソッド（全体）
  Future<void> _updateRandomChoices() async {
    final prefs = await SharedPreferences.getInstance();
    final random = Random();

    for (int i = 0; i < 4; i++) {
      final multiChoice = prefs.getString('card_multichoice_$i') ?? '';

      // 複数選択肢がある場合はランダムに選択
      if (multiChoice.isNotEmpty && i >= 2) {
        final choices = multiChoice
            .split('、')
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

  // 個別カードのランダム選択を更新するメソッド
  Future<void> _updateSingleRandomChoice(int index) async {
    final prefs = await SharedPreferences.getInstance();
    final multiChoice = prefs.getString('card_multichoice_$index') ?? '';

    // 複数選択肢がある場合はランダムに選択
    if (multiChoice.isNotEmpty && index >= 2) {
      final choices = multiChoice
          .split('、')
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
  }

  // 設定を読み込む
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    // ４つ表示
    for (int i = 0; i < 4; i++) {
      final title =
          prefs.getString('card_title_$i') ?? defaultConfigs[i]['title']!;
      final message =
          prefs.getString('card_message_$i') ??
          defaultConfigs[i]['completedMessage']!;
      final multiChoice = prefs.getString('card_multichoice_$i') ?? '';

      // 複数選択肢がある場合はランダムに選択
      String finalMessage = message;
      if (multiChoice.isNotEmpty && i >= 2) {
        final choices = multiChoice
            .split('、')
            .where((s) => s.trim().isNotEmpty)
            .toList();
        if (choices.isNotEmpty) {
          final random = Random();
          final randomIndex = random.nextInt(choices.length);
          finalMessage = choices[randomIndex].trim();
        }
      }

      cardConfigs[i] = {'title': title, 'completedMessage': finalMessage};
    }
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

  void _resetAll() async {
    setState(() {
      // すべてのスクラッチ状態をリセット
      for (var state in scratchStates) {
        state.reset();
      }
      // 新しいキーを生成してカードを完全にリセット
      cardKeys = List.generate(4, (index) => UniqueKey());
    });
    // リセット時にランダム選択を更新
    await _updateRandomChoices();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 上部
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: [
          IconButton(
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
              _loadSettings();
            },
            icon: const Icon(Icons.settings),
            tooltip: '設定',
          ),
        ],
      ),

      // メインの部分
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
          header: const WaterDropHeader(),
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
        //     ],
        //   ),
        // ),
      ),
    );
  }
}
