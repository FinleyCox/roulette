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
  final List<TextEditingController> messageControllers = [];
  final List<TextEditingController> multiChoiceControllers = [];

  @override
  void initState() {
    super.initState();
    // 4つのカード用のコントローラーを初期化
    for (int i = 0; i < 4; i++) {
      titleControllers.add(TextEditingController());
      messageControllers.add(TextEditingController());
      multiChoiceControllers.add(TextEditingController());
    }
    _loadSettings();
  }

  @override
  // コントローラーを破棄
  void dispose() {
    for (var controller in titleControllers) {
      controller.dispose();
    }
    for (var controller in messageControllers) {
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

    // 4つのカード用のコントローラーを初期化
    for (int i = 0; i < 4; i++) {
      final title = prefs.getString('card_title_$i') ?? _getDefaultTitle(i);
      final message =
          prefs.getString('card_message_$i') ?? _getDefaultMessage(i);
      final multiChoice = prefs.getString('card_multichoice_$i') ?? '';

      titleControllers[i].text = title;
      messageControllers[i].text = message;
      multiChoiceControllers[i].text = multiChoice;
    }
  }

  // デフォルトのタイトルを返す
  String _getDefaultTitle(int index) {
    final titles = ['🎯 ターゲット1', '⚡ ターゲット2', '🔥 ターゲット3', '🏆 最終ターゲット'];
    return titles[index];
  }

  // デフォルトの内容を返す
  String _getDefaultMessage(int index) {
    final messages = [
      '🎉 1つ目クリア！',
      '🌟 2つ目クリア！',
      '💎 3つ目クリア！',
      '🎊 全ターゲットクリア！',
    ];
    return messages[index];
  }

  // 設定を保存
  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();

    for (int i = 0; i < 4; i++) {
      await prefs.setString('card_title_$i', titleControllers[i].text);
      await prefs.setString('card_message_$i', messageControllers[i].text);
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
    for (int i = 0; i < 4; i++) {
      titleControllers[i].text = _getDefaultTitle(i);
      messageControllers[i].text = _getDefaultMessage(i);
      multiChoiceControllers[i].text = '';
    }
    _saveSettings();
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
        ],
      ),
      // 設定画面の本体(タイトルと内容を入力)
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: 4,
                itemBuilder: (context, index) {
                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'カード ${index + 1}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: titleControllers[index],
                            decoration: const InputDecoration(
                              labelText: 'タイトル',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 12),
                          if (index >= 2) ...[
                            const SizedBox(height: 12),
                            TextField(
                              controller: multiChoiceControllers[index],
                              decoration: const InputDecoration(
                                labelText: '複数選択可',
                                border: OutlineInputBorder(),
                                hintText: '例: 警察官、花屋、パン屋',
                                helperText: '複数の選択肢を「、」で区切って入力してください',
                              ),
                            ),
                          ] else ...[
                            TextField(
                              controller: messageControllers[index],
                              decoration: const InputDecoration(
                                labelText: '内容',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ],
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
