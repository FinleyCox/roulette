import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

// 設定画面の状態を管理するクラス
class _SettingsScreenState extends State<SettingsScreen> {
  final List<TextEditingController> titleControllers = [];
  final List<TextEditingController> multiChoiceControllers = [];
  int cardCount = 4; // カードの数を管理

  @override
  void initState() {
    super.initState();
    // 初期コントローラーを追加
    _ensureControllers(4);
    _loadSettings();
  }

  // コントローラーの数を確保するメソッド
  void _ensureControllers(int count) {
    while (titleControllers.length < count) {
      titleControllers.add(TextEditingController());
      multiChoiceControllers.add(TextEditingController());
    }
  }

  @override
  // コントローラーを破棄
  void dispose() {
    for (var controller in titleControllers) {
      controller.dispose();
    }
    for (var controller in multiChoiceControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  // 設定を読み込む
  Future<void> _loadSettings() async {
    // 設定を取得
    final prefs = await SharedPreferences.getInstance();

    // 保存されたカード数を読み込み
    final savedCardCount = prefs.getInt('card_count') ?? 4;

    // カード数が変更された場合のみ更新
    if (savedCardCount != cardCount) {
      setState(() {
        cardCount = savedCardCount;
        // コントローラーの数を調整
        _ensureControllers(cardCount);
      });
    } else {
      // コントローラーの数を調整
      _ensureControllers(cardCount);
    }

    // カード用のコントローラーを初期化
    for (int i = 0; i < cardCount; i++) {
      final title = prefs.getString('card_title_$i') ?? '';
      final multiChoice = prefs.getString('card_multichoice_$i') ?? '';

      titleControllers[i].text = title;
      multiChoiceControllers[i].text = multiChoice;
    }
  }

  // 設定を保存
  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();

    // カード数を保存
    await prefs.setInt('card_count', cardCount);

    for (int i = 0; i < cardCount; i++) {
      await prefs.setString('card_title_$i', titleControllers[i].text);
      await prefs.setString(
        'card_multichoice_$i',
        multiChoiceControllers[i].text,
      );
    }

    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('設定を保存しました')));
    }
  }

  // デフォルトの設定に戻す(右上のボタン)
  void _resetToDefaults() {
    for (int i = 0; i < cardCount; i++) {
      titleControllers[i].text = '';
      multiChoiceControllers[i].text = '';
    }
    _saveSettings();
  }

  // カードを追加するメソッド
  void _addCard() async {
    setState(() {
      cardCount++;
      _ensureControllers(cardCount);
      // 新しいカードのデフォルト値を設定
      titleControllers[cardCount - 1].text = '';
      multiChoiceControllers[cardCount - 1].text = '';
    });
    // 追加後に即座に保存
    await _saveSettings();
  }

  // カードを削除するメソッド
  void _removeCard(int index) async {
    if (cardCount > 1) {
      setState(() {
        cardCount--;
        // 削除されたカード以降のデータをシフト
        for (int i = index; i < cardCount; i++) {
          titleControllers[i].text = titleControllers[i + 1].text;
          multiChoiceControllers[i].text = multiChoiceControllers[i + 1].text;
        }
      });
      // 削除後に即座に保存
      await _saveSettings();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('設定'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            onPressed: _resetToDefaults,
            icon: const Icon(Icons.restore),
            tooltip: 'デフォルトに戻す',
          ),
          IconButton(
            onPressed: _addCard,
            icon: const Icon(Icons.add),
            tooltip: 'カードを追加',
          ),
        ],
      ),
      // 設定画面の本体(タイトルと内容を入力)
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: cardCount,
                itemBuilder: (context, index) {
                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'カード ${index + 1}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (cardCount > 1)
                                IconButton(
                                  onPressed: () => _removeCard(index),
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  tooltip: 'カードを削除',
                                ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: titleControllers[index],
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: 'タイトル（例: 明日の予定）',
                              hintStyle: TextStyle(
                                color: Color.fromARGB(255, 193, 191, 191),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: multiChoiceControllers[index],
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: '例: 犬、猫、鳥',
                              hintStyle: TextStyle(
                                color: Color.fromARGB(255, 193, 191, 191),
                              ),
                              helperText: '複数の選択肢を「、」で区切って入力してください',
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveSettings,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('保存'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
