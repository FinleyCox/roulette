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
          return 'Preset +3 Sets + Banner Ads Removed';
        case 'tier2Title':
          return 'Preset +10 Sets + All Ads Removed';
        case 'close':
          return 'Close';
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
          return 'Preset +3 सेट + बैनर विज्ञापन हटा दिए गए';
        case 'tier2Title':
          return 'Preset +10 सेट + सभी विज्ञापन हटा दिए गए';
        case 'close':
          return 'बंद करें';
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
          return 'プリセット上限3セット + バナー広告非表示';
        case 'tier2Title':
          return 'プリセット上限10セット + 広告非表示';
        case 'close':
          return '閉じる';
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

  // プライバシーポリシー画面のテキストを取得
  static String getPrivacyPolicyText(String key, String languageCode) {
    if (languageCode == 'en') {
      switch (key) {
        case 'privacyPolicy':
          return 'Privacy Policy';
        case 'privacyPolicyTitle':
          return 'Privacy Policy (simple scratch)';
        case 'privacyPolicyDescription':
          return 'simple scratch (hereinafter "this app") respects user privacy.\nThis app does not collect, store, or transmit any personal information.';
        case 'informationCollected':
          return '1. Information Collected';
        case 'informationCollectedDescription':
          return 'This app does not collect the following information:\n\n• Personal identification information such as name and email address\n• Location information such as GPS\n• Usage status of other apps';
        case 'dataTransmission':
          return '2. Data Transmission and Storage';
        case 'dataTransmissionDescription':
          return 'This app does not transmit data over the internet or store information on external servers.\nAll user data is stored on the device.';
        case 'advertising':
          return '3. Advertising';
        case 'advertisingDescription':
          return 'This app does not display advertisements.';
        case 'contact':
          return '4. Contact';
        case 'contactDescription':
          return 'For questions regarding this privacy policy, please contact us at the email address below.';
        case 'revision':
          return '5. Revision';
        case 'revisionDescription':
          return 'This policy may be revised without notice. Updated policies will be published on this app or the distribution page.';
        default:
          return key;
      }
    } else if (languageCode == 'hi') {
      switch (key) {
        case 'privacyPolicy':
          return 'गोपनीयता नीति';
        case 'privacyPolicyTitle':
          return 'गोपनीयता नीति (simple scratch)';
        case 'privacyPolicyDescription':
          return 'simple scratch (इसके बाद "यह ऐप") उपयोगकर्ता की गोपनीयता का सम्मान करता है।\nयह ऐप कोई भी व्यक्तिगत जानकारी एकत्र, संग्रहीत या प्रसारित नहीं करता है।';
        case 'informationCollected':
          return '1. एकत्र की गई जानकारी';
        case 'informationCollectedDescription':
          return 'यह ऐप निम्नलिखित जानकारी एकत्र नहीं करता है:\n\n• नाम और ईमेल पते जैसी व्यक्तिगत पहचान जानकारी\n• जीपीएस जैसी स्थान जानकारी\n• अन्य ऐप्स की उपयोग स्थिति';
        case 'dataTransmission':
          return '2. डेटा प्रसारण और भंडारण';
        case 'dataTransmissionDescription':
          return 'यह ऐप इंटरनेट पर डेटा प्रसारित नहीं करता है या बाहरी सर्वर पर जानकारी संग्रहीत नहीं करता है।\nसभी उपयोगकर्ता डेटा डिवाइस पर संग्रहीत किया जाता है।';
        case 'advertising':
          return '3. विज्ञापन';
        case 'advertisingDescription':
          return 'यह ऐप विज्ञापन प्रदर्शित नहीं करता है।';
        case 'contact':
          return '4. संपर्क';
        case 'contactDescription':
          return 'इस गोपनीयता नीति के बारे में प्रश्नों के लिए, कृपया नीचे दिए गए ईमेल पते पर हमसे संपर्क करें।';
        case 'revision':
          return '5. संशोधन';
        case 'revisionDescription':
          return 'इस नीति को बिना किसी सूचना के संशोधित किया जा सकता है। अद्यतन नीतियां इस ऐप या वितरण पृष्ठ पर प्रकाशित की जाएंगी।';
        default:
          return key;
      }
    } else {
      switch (key) {
        case 'privacyPolicy':
          return 'プライバシーポリシー';
        case 'privacyPolicyTitle':
          return 'プライバシーポリシー（simple scratch）';
        case 'privacyPolicyDescription':
          return 'simple scratch（以下「本アプリ」）は、ユーザーのプライバシーを尊重します。\n本アプリは、個人情報の収集・保存・送信を一切行いません。';
        case 'informationCollected':
          return '1. 収集する情報';
        case 'informationCollectedDescription':
          return '本アプリは、以下の情報を収集しません：\n\n• 氏名・メールアドレス等の個人識別情報\n• GPS等の位置情報\n• 他のアプリの使用状況';
        case 'dataTransmission':
          return '2. データの送信・保存';
        case 'dataTransmissionDescription':
          return '本アプリは、インターネットを通じたデータ送信や外部サーバーへの情報保存を行いません。\nユーザーデータはすべて端末内に保存されます。';
        case 'advertising':
          return '3. 広告について';
        case 'advertisingDescription':
          return '本アプリには広告が表示されます。';
        case 'contact':
          return '4. お問い合わせ';
        case 'contactDescription':
          return 'プライバシーポリシーに関するご質問は、下記のメールアドレスまでご連絡ください。';
        case 'revision':
          return '5. 改定';
        case 'revisionDescription':
          return '本ポリシーは予告なく改定されることがあります。変更後のポリシーは本アプリ上または配布ページにて公開されます。';
        default:
          return key;
      }
    }
  }
}
