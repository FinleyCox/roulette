import 'package:shared_preferences/shared_preferences.dart';

class LanguageUtils {
  static const String _languageKey = 'selected_language';

  static Future<String?> getCurrentLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_languageKey);
  }

  static Future<void> setLanguage(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, languageCode);
  }

  static String getFlag(String languageCode) {
    switch (languageCode) {
      case 'ja':
        return 'JA';
      case 'en':
        return 'EN';
      case 'hi':
        return 'HI';
      default:
        return 'JA';
    }
  }

  // カードタイトルを取得
  static String getCardTitle(int index, String languageCode) {
    if (languageCode == 'en') {
      return 'Card ${index + 1}';
    } else if (languageCode == 'hi') {
      return 'कार्ड ${index + 1}';
    } else {
      return 'カード${index + 1}';
    }
  }

  // カード結果を取得
  static String getCardResult(int index, String languageCode) {
    if (languageCode == 'en') {
      return '${index + 1}st Result';
    } else if (languageCode == 'hi') {
      return 'कार्ड ${index + 1} परिणाम';
    } else {
      return 'カード${index + 1}の結果';
    }
  }

  static String getScratchInstruction(String languageCode) {
    if (languageCode == 'en') {
      return 'Slide your finger to reveal the choice';
    } else if (languageCode == 'hi') {
      return 'परिणाम देखने के लिए अपनी उंगली से स्वाइप करें';
    }
    return '指でこすると結果が表示されます';
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
        case 'upgradePlan':
          return 'Upgrade Plan';
        case 'tier1Title':
          return 'Preset +3 Sets + Banner Ads Removed (can be bought again; 2nd purchase removes all ads)';
        case 'tier2Title':
          return 'Preset +10 Sets + All Ads Removed (one-time purchase)';
        case 'close':
          return 'Close';
        case 'storeUnavailable':
          return 'Could not connect to Google Play. Please try again later.';
        case 'cancel':
          return 'Cancel';
        case 'reset':
          return 'Reset';
        case 'shareSettings':
          return 'Share Settings';
        case 'scanQRCode':
          return 'Scan QR Code';
        case 'settingsImported':
          return 'Settings imported successfully!';
        case 'managePresets':
          return 'Manage Presets';
        case 'limitReached':
          return 'Limit Reached';
        case 'limitReachedDesc':
          return 'You have reached the limit of saved presets.\nUpgrade to save more.';
        case 'upgrade':
          return 'Upgrade';
        case 'shareViaQR':
          return 'Share via QR';
        case 'scanQR':
          return 'Scan QR';
        case 'delete':
          return 'Delete';
        case 'privacy':
          return 'Privacy';
        case 'savePresetTitle':
          return 'Save Current Input as Preset';
        case 'presetNameHint':
          return 'Preset Name';
        case 'presetSaved':
          return 'Preset saved';
        case 'confirmDeleteTitle':
          return 'Confirm Delete';
        case 'noPresets':
          return 'No presets saved';
        case 'resetConfirmMessage':
          return 'Are you sure you want to reset current settings?';
        default:
          return key;
      }
    } else if (languageCode == 'hi') {
      switch (key) {
        case 'settings':
          return 'सेटिंग्स';
        case 'save':
          return 'सहेजें';
        case 'saved':
          return 'सहेज लिया';
        case 'multipleChoices':
          return 'अनेक विकल्प (कॉमा से अलग करें)';
        case 'example':
          return 'उदा: कुत्ता, बिल्ली, पक्षी';
        case 'card':
          return 'कार्ड';
        case 'resetToDefaults':
          return 'डिफ़ॉल्ट पर रीसेट करें';
        case 'addCard':
          return 'कार्ड जोड़ें';
        case 'deleteCard':
          return 'कार्ड हटाएँ';
        case 'upgradePlan':
          return 'योजना अपग्रेड करें';
        case 'tier1Title':
          return 'Preset +3 सेट + बैनर विज्ञापन हटाएं (दोबारा खरीदा जा सकता है; दूसरी खरीद पर सभी विज्ञापन हट जाते हैं)';
        case 'tier2Title':
          return 'Preset +10 सेट + सभी विज्ञापन हटाएं (एक बार की खरीद)';
        case 'close':
          return 'बंद करें';
        case 'storeUnavailable':
          return 'Google Play से कनेक्ट नहीं हो सका। कृपया बाद में पुनः प्रयास करें।';
        case 'cancel':
          return 'रद्द करें';
        case 'reset':
          return 'रीसेट';
        case 'shareSettings':
          return 'सेटिंग्स साझा करें';
        case 'scanQRCode':
          return 'क्यूआर कोड स्कैन करें';
        case 'settingsImported':
          return 'सेटिंग्स सफलतापूर्वक आयात की गईं!';
        case 'managePresets':
          return 'प्रीसेट प्रबंधित करें';
        case 'limitReached':
          return 'सीमा समाप्त';
        case 'limitReachedDesc':
          return 'आप सहेजे गए प्रीसेट की सीमा तक पहुँच गए हैं।\nअधिक सहेजने के लिए अपग्रेड करें।';
        case 'upgrade':
          return 'अपग्रेड';
        case 'shareViaQR':
          return 'क्यूआर के माध्यम से साझा करें';
        case 'scanQR':
          return 'क्यूआर स्कैन करें';
        case 'delete':
          return 'हटाएं';
        case 'privacy':
          return 'गोपनीयता';
        case 'savePresetTitle':
          return 'वर्तमान इनपुट को प्रीसेट के रूप में सहेजें';
        case 'presetNameHint':
          return 'प्रीसेट नाम';
        case 'presetSaved':
          return 'प्रीसेट सहेजा गया';
        case 'confirmDeleteTitle':
          return 'हटाने की पुष्टि करें';
        case 'noPresets':
          return 'कोई प्रीसेट सहेजा नहीं गया';
        case 'resetConfirmMessage':
          return 'क्या आप वाकई वर्तमान सेटिंग्स को रीसेट करना चाहते हैं?';
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
          return '複数の選択肢を「、」「,」で区切って入力してください';
        case 'example':
          return '例: 雨の日、街角、犬が';
        case 'card':
          return 'カード';
        case 'resetToDefaults':
          return 'デフォルトに戻す';
        case 'addCard':
          return 'カードを追加';
        case 'deleteCard':
          return 'カードを削除';
        case 'upgradePlan':
          return 'プランのアップグレード';
        case 'tier1Title':
          return 'プリセット枠+3 + バナー広告非表示（複数回購入可・2回目の購入で全広告非表示）';
        case 'tier2Title':
          return 'プリセット枠+10 + 全広告非表示（買い切り）';
        case 'close':
          return '閉じる';
        case 'storeUnavailable':
          return 'Google Play に接続できませんでした。時間をおいて再度お試しください。';
        case 'cancel':
          return 'キャンセル';
        case 'reset':
          return 'リセット';
        case 'shareSettings':
          return '設定を共有';
        case 'scanQRCode':
          return 'QRコードをスキャン';
        case 'settingsImported':
          return '設定をインポートしました！';
        case 'managePresets':
          return 'プリセット管理';
        case 'limitReached':
          return '上限に達しました';
        case 'limitReachedDesc':
          return 'プリセットの保存上限に達しました。\nもっと保存するにはアップグレードしてください。';
        case 'upgrade':
          return 'アップグレード';
        case 'shareViaQR':
          return 'QRコードで共有';
        case 'scanQR':
          return 'QRコード読み取り';
        case 'delete':
          return '削除';
        case 'privacy':
          return 'プライバシー';
        case 'savePresetTitle':
          return '現在の入力内容でプリセットを保存';
        case 'presetNameHint':
          return 'プリセット名';
        case 'presetSaved':
          return '保存しました';
        case 'confirmDeleteTitle':
          return '削除の確認';
        case 'noPresets':
          return '保存されたプリセットはありません';
        case 'resetConfirmMessage':
          return '現在入力されているものをリセットしますか？';
        default:
          return key;
      }
    }
  }
}
