import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/language_utils.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({
    super.key,
    required this.onLanguageChanged,
    required this.currentLanguage,
  });
  final Function(String) onLanguageChanged;
  final String currentLanguage;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

// 設定画面の状態を管理するクラス
class _SettingsScreenState extends State<SettingsScreen> {
  final List<TextEditingController> titleControllers = [];
  final List<TextEditingController> multiChoiceControllers = [];
  int cardCount = 4; // カードの数を管理
  bool isSaved = false; // 保存状態を管理

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

  // デフォルトのタイトルを返す
  String _getDefaultTitle(int index) {
    return LanguageUtils.getCardTitle(index, widget.currentLanguage);
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
      final savedTitle = prefs.getString('card_title_$i');
      final multiChoice = prefs.getString('card_multichoice_$i') ?? '';

      // 保存されたタイトルが空またはデフォルト値と同じ場合は空にする
      if (savedTitle == null ||
          savedTitle.isEmpty ||
          savedTitle == _getDefaultTitle(i)) {
        titleControllers[i].text = '';
      } else {
        titleControllers[i].text = savedTitle;
      }
      multiChoiceControllers[i].text = multiChoice;
    }
  }

  // 設定を保存
  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();

    // カード数を保存
    await prefs.setInt('card_count', cardCount);

    for (int i = 0; i < cardCount; i++) {
      // 空の場合はデフォルト値を使用
      final title = titleControllers[i].text.trim().isEmpty
          ? _getDefaultTitle(i)
          : titleControllers[i].text;
      final multiChoice = multiChoiceControllers[i].text.trim();

      await prefs.setString('card_title_$i', title);
      await prefs.setString('card_multichoice_$i', multiChoice);
    }

    // 保存状態を更新
    setState(() {
      isSaved = true;
    });

    // 1秒後にボタンを元に戻す
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          isSaved = false;
        });
      }
    });
  }

  // デフォルトの設定に戻す(右上のボタン)
  void _resetToDefaults() {
    for (int i = 0; i < cardCount; i++) {
      titleControllers[i].text = _getDefaultTitle(i);
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
      titleControllers[cardCount - 1].text = _getDefaultTitle(cardCount - 1);
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
        title: Text(
          LanguageUtils.getSettingsText('settings', widget.currentLanguage),
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          // 言語切り替えボタン
          GestureDetector(
            onTap: () {
              final newLanguage = widget.currentLanguage == 'ja' ? 'en' : 'ja';
              widget.onLanguageChanged(newLanguage);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Text(
                LanguageUtils.getFlag(widget.currentLanguage),
                style: const TextStyle(fontSize: 20),
              ),
            ),
          ),
          IconButton(
            onPressed: _resetToDefaults,
            icon: const Icon(Icons.restore, color: Colors.black87, size: 28),
            tooltip: LanguageUtils.getSettingsText(
              'resetToDefaults',
              widget.currentLanguage,
            ),
          ),
          IconButton(
            onPressed: _addCard,
            icon: const Icon(Icons.add, color: Colors.black87, size: 28),
            tooltip: LanguageUtils.getSettingsText(
              'addCard',
              widget.currentLanguage,
            ),
          ),
        ],
      ),
      // 設定画面の本体(タイトルと内容を入力)
      backgroundColor: Colors.white,
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
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${LanguageUtils.getSettingsText('card', widget.currentLanguage)} ${index + 1}',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              if (cardCount > 1)
                                IconButton(
                                  onPressed: () => _removeCard(index),
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  tooltip: LanguageUtils.getSettingsText(
                                    'deleteCard',
                                    widget.currentLanguage,
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: titleControllers[index],
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Colors.grey,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Colors.grey,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Colors.blue,
                                  width: 2,
                                ),
                              ),
                              hintText: _getDefaultTitle(index),
                              hintStyle: const TextStyle(
                                color: Colors.grey,
                                fontSize: 16,
                              ),
                              filled: true,
                              fillColor: Colors.grey[50],
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: multiChoiceControllers[index],
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Colors.grey,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Colors.grey,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Colors.blue,
                                  width: 2,
                                ),
                              ),
                              hintText: LanguageUtils.getSettingsText(
                                'example',
                                widget.currentLanguage,
                              ),
                              hintStyle: const TextStyle(
                                color: Colors.grey,
                                fontSize: 16,
                              ),
                              helperText: LanguageUtils.getSettingsText(
                                'multipleChoices',
                                widget.currentLanguage,
                              ),
                              helperStyle: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                              filled: true,
                              fillColor: Colors.grey[50],
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
                  backgroundColor: isSaved
                      ? Colors.orange[400]
                      : Colors.blue[600],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: Text(
                  isSaved
                      ? LanguageUtils.getSettingsText(
                          'saved',
                          widget.currentLanguage,
                        )
                      : LanguageUtils.getSettingsText(
                          'save',
                          widget.currentLanguage,
                        ),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
