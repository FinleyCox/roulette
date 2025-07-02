import 'package:shared_preferences/shared_preferences.dart';

class LanguageUtils {
  static const String _languageKey = 'selected_language';

  static Future<String> getCurrentLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_languageKey) ?? 'ja';
  }

  static Future<void> setLanguage(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, languageCode);
  }

  static String getFlag(String languageCode) {
    switch (languageCode) {
      case 'ja':
        return '🇯🇵';
      case 'en':
        return '🇬🇧';
      default:
        return '🇯🇵';
    }
  }

  // カードタイトルを取得
  static String getCardTitle(int index, String languageCode) {
    if (languageCode == 'en') {
      switch (index) {
        case 0:
          return 'Card 1';
        case 1:
          return 'Card 2';
        case 2:
          return 'Card 3';
        case 3:
          return 'Card 4';
        default:
          return 'Card ${index + 1}';
      }
    } else {
      switch (index) {
        case 0:
          return 'カード1';
        case 1:
          return 'カード2';
        case 2:
          return 'カード3';
        case 3:
          return 'カード4';
        default:
          return 'カード${index + 1}';
      }
    }
  }

  // カード結果を取得
  static String getCardResult(int index, String languageCode) {
    if (languageCode == 'en') {
      switch (index) {
        case 0:
          return 'Card 1 Result';
        case 1:
          return 'Card 2 Result';
        case 2:
          return 'Card 3 Result';
        case 3:
          return 'Card 4 Result';
        default:
          return '${index + 1}st Result';
      }
    } else {
      switch (index) {
        case 0:
          return 'カード1の結果';
        case 1:
          return 'カード2の結果';
        case 2:
          return 'カード3の結果';
        case 3:
          return 'カード4の結果';
        default:
          return '${index + 1}つ目';
      }
    }
  }

  // 設定画面のテキストを取得
  static String getSettingsText(String key, String languageCode) {
    if (languageCode == 'en') {
      switch (key) {
        case 'settings':
          return 'Settings';
        case 'save':
          return 'Save';
        case 'saved':
          return 'Saved';
        case 'multipleChoices':
          return 'Enter multiple choices separated by commas';
        case 'example':
          return 'Example: dog, cat, bird';
        case 'card':
          return 'Card';
        case 'resetToDefaults':
          return 'Reset to Defaults';
        case 'addCard':
          return 'Add Card';
        case 'deleteCard':
          return 'Delete Card';
        default:
          return key;
      }
    } else {
      switch (key) {
        case 'settings':
          return '設定';
        case 'save':
          return '保存';
        case 'saved':
          return '保存しました';
        case 'multipleChoices':
          return '複数の選択肢を「、」で区切って入力してください';
        case 'example':
          return '例: 犬、猫、鳥';
        case 'card':
          return 'カード';
        case 'resetToDefaults':
          return 'デフォルトに戻す';
        case 'addCard':
          return 'カードを追加';
        case 'deleteCard':
          return 'カードを削除';
        default:
          return key;
      }
    }
  }
}
