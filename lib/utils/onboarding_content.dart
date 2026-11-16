import 'package:shared_preferences/shared_preferences.dart';

/// オンボーディングで選べるスターターテンプレート（カード3枚分）
class StarterTemplate {
  const StarterTemplate({
    required this.id,
    required this.label,
    required this.description,
    required this.cards,
  });

  final String id;
  final String label;
  final String description;

  /// (タイトル, 選択肢を「、」または「,」で区切った文字列)
  final List<(String, String)> cards;
}

class OnboardingContent {
  static const String _doneKey = 'onboarding_done';

  /// オンボーディングが必要か。既存ユーザー（カード設定が保存済み）には表示しない。
  static Future<bool> isNeeded() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(_doneKey) ?? false) return false;
    if (prefs.containsKey('card_count')) {
      await prefs.setBool(_doneKey, true);
      return false;
    }
    return true;
  }

  static Future<void> markDone() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_doneKey, true);
  }

  /// テンプレートをカード設定として保存する（ホーム・設定画面と同じキー）
  static Future<void> applyTemplate(StarterTemplate template) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('card_count', template.cards.length);
    for (var i = 0; i < template.cards.length; i++) {
      await prefs.setString('card_title_$i', template.cards[i].$1);
      await prefs.setString('card_multichoice_$i', template.cards[i].$2);
    }
  }

  // ---- 画面テキスト ----

  static String text(String key, String lang) {
    final table = switch (lang) {
      'en' => _en,
      'hi' => _hi,
      _ => _ja,
    };
    return table[key] ?? _en[key] ?? key;
  }

  static const Map<String, String> _ja = {
    'skip': 'スキップ',
    'next': '次へ',
    'start': 'はじめる',
    'p1Title': '指で削って、発想を引こう',
    'p1Body': '下のカードを指でこすってみてください。',
    'p1Hint': 'ここを削る',
    'p1Result': '喋る猫',
    'p1Done': 'いい感じ！削るたびに、登録した中からランダムで1つ出てきます。',
    'p2Title': '選択肢は「、」で区切って登録',
    'p2Body': '右上の設定から、カードごとにタイトルと選択肢を登録できます。',
    'p2Example': '例：雨の日の図書館、深夜のコンビニ、無人駅',
    'p3Title': '引っ張ってリセット',
    'p3Body': '画面を下に引っ張ると全カードが元に戻り、もう一度引けます。組み合わせはプリセットに保存したり、QRコードで友達と共有したりできます。',
    'p4Title': 'どんな使い方をしますか？',
    'p4Body': 'あとから設定でいつでも変えられます。',
    'custom': '自分で作る',
    'customDesc': '空のカードから始める',
  };

  static const Map<String, String> _en = {
    'skip': 'Skip',
    'next': 'Next',
    'start': 'Get started',
    'p1Title': 'Scratch to reveal an idea',
    'p1Body': 'Try rubbing the card below with your finger.',
    'p1Hint': 'Scratch here',
    'p1Result': 'A talking cat',
    'p1Done': 'Nice! Each time you scratch, one of your choices appears at random.',
    'p2Title': 'Add choices separated by commas',
    'p2Body': 'Open Settings (top right) to set a title and choices for each card.',
    'p2Example': 'e.g. a rainy library, a late-night store, an empty station',
    'p3Title': 'Pull down to reset',
    'p3Body': 'Pull the screen down to reset all cards and draw again. Save combinations as presets or share them with friends via QR code.',
    'p4Title': 'How will you use it?',
    'p4Body': 'You can change this anytime in Settings.',
    'custom': 'Start from scratch',
    'customDesc': 'Begin with empty cards',
  };

  static const Map<String, String> _hi = {
    'skip': 'छोड़ें',
    'next': 'आगे',
    'start': 'शुरू करें',
    'p1Title': 'स्क्रैच करें और आइडिया पाएं',
    'p1Body': 'नीचे दिए कार्ड को अपनी उंगली से रगड़ कर देखें।',
    'p1Hint': 'यहां स्क्रैच करें',
    'p1Result': 'बोलने वाली बिल्ली',
    'p1Done': 'बढ़िया! हर बार स्क्रैच करने पर आपके विकल्पों में से एक रैंडम रूप से दिखेगा।',
    'p2Title': 'विकल्पों को कॉमा से अलग करें',
    'p2Body': 'ऊपर दाईं ओर सेटिंग्स में हर कार्ड का शीर्षक और विकल्प जोड़ें।',
    'p2Example': 'उदाहरण: बारिश में लाइब्रेरी, देर रात की दुकान, खाली स्टेशन',
    'p3Title': 'रीसेट करने के लिए नीचे खींचें',
    'p3Body': 'स्क्रीन को नीचे खींचें, सभी कार्ड रीसेट हो जाएंगे। संयोजनों को प्रीसेट के रूप में सहेजें या QR कोड से दोस्तों के साथ साझा करें।',
    'p4Title': 'आप इसे कैसे इस्तेमाल करेंगे?',
    'p4Body': 'आप इसे कभी भी सेटिंग्स में बदल सकते हैं।',
    'custom': 'खुद बनाएं',
    'customDesc': 'खाली कार्ड से शुरू करें',
  };

  // ---- テンプレート ----

  static List<StarterTemplate> templates(String lang) => switch (lang) {
    'en' => _templatesEn,
    'hi' => _templatesHi,
    _ => _templatesJa,
  };

  static const _templatesJa = [
    StarterTemplate(
      id: 'story',
      label: '創作のお題',
      description: '場所・登場人物・出来事を組み合わせてネタ出し',
      cards: [
        ('場所', '雨の日の図書館、深夜のコンビニ、無人駅、屋上の温室、海辺の古本屋'),
        ('登場人物', '記憶をなくした探偵、喋る猫、引退した魔法使い、新米の郵便配達員、未来から来た学生'),
        ('出来事', '落とし物を拾う、秘密の手紙が届く、停電が起きる、昔の友人に再会する、道に迷う'),
      ],
    ),
    StarterTemplate(
      id: 'daily',
      label: '今日のひとこと',
      description: '1日のテーマと自分への声かけを引く',
      cards: [
        ('今日のテーマ', '感謝、挑戦、休息、整理整頓、新しい出会い'),
        ('ひとこと', 'まずは5分だけやってみよう、完璧じゃなくていい、昨日の自分を超えよう、深呼吸してから始めよう、小さな一歩で十分'),
        ('ごほうび', '好きな飲み物、少し長めの散歩、好きな音楽を1曲、早めに寝る、甘いもの'),
      ],
    ),
    StarterTemplate(
      id: 'food',
      label: 'ごはん決め',
      description: '迷ったときの献立をランダムに',
      cards: [
        ('主食', 'ご飯、パン、うどん、パスタ、そば'),
        ('ジャンル', '和食、中華、イタリアン、エスニック、カレー'),
        ('もう一品', 'サラダ、スープ、からあげ、卵焼き、デザート'),
      ],
    ),
  ];

  static const _templatesEn = [
    StarterTemplate(
      id: 'story',
      label: 'Story prompts',
      description: 'Mix a place, a character and an event',
      cards: [
        ('Place', 'a library on a rainy day, a late-night store, an empty train station, a rooftop greenhouse, a seaside bookshop'),
        ('Character', 'a detective who lost their memory, a talking cat, a retired wizard, a new mail carrier, a student from the future'),
        ('Event', 'finds a lost item, receives a secret letter, a blackout happens, meets an old friend, gets lost'),
      ],
    ),
    StarterTemplate(
      id: 'daily',
      label: 'Daily words',
      description: 'A theme for today and a word for yourself',
      cards: [
        ('Today\'s theme', 'gratitude, challenge, rest, tidying up, new encounters'),
        ('A word for you', 'Just try for 5 minutes, It does not have to be perfect, Beat yesterday\'s you, Take a deep breath first, A small step is enough'),
        ('Reward', 'your favorite drink, a longer walk, one favorite song, an early night, something sweet'),
      ],
    ),
    StarterTemplate(
      id: 'food',
      label: 'What to eat',
      description: 'Pick a meal when you cannot decide',
      cards: [
        ('Base', 'rice, bread, noodles, pasta, chapati'),
        ('Style', 'home-style, Chinese, Italian, Indian, street food'),
        ('Side', 'salad, soup, fried chicken, eggs, fruit'),
      ],
    ),
  ];

  static const _templatesHi = [
    StarterTemplate(
      id: 'story',
      label: 'कहानी के विषय',
      description: 'जगह, पात्र और घटना को मिलाकर आइडिया पाएं',
      cards: [
        ('जगह', 'बारिश के दिन लाइब्रेरी, देर रात की दुकान, खाली रेलवे स्टेशन, छत पर ग्रीनहाउस, समुद्र किनारे किताबों की दुकान'),
        ('पात्र', 'याददाश्त खो चुका जासूस, बोलने वाली बिल्ली, रिटायर्ड जादूगर, नया डाकिया, भविष्य से आया छात्र'),
        ('घटना', 'खोई हुई चीज़ मिलती है, गुप्त पत्र आता है, बिजली चली जाती है, पुराने दोस्त से मुलाकात, रास्ता भटक जाना'),
      ],
    ),
    StarterTemplate(
      id: 'daily',
      label: 'आज का विचार',
      description: 'आज की थीम और खुद के लिए एक संदेश',
      cards: [
        ('आज की थीम', 'आभार, चुनौती, आराम, साफ़-सफ़ाई, नई मुलाकात'),
        ('आपके लिए संदेश', 'बस 5 मिनट कोशिश करें, सब कुछ परफेक्ट होना ज़रूरी नहीं, कल से बेहतर बनें, पहले गहरी सांस लें, छोटा कदम भी काफी है'),
        ('इनाम', 'पसंदीदा ड्रिंक, थोड़ी लंबी सैर, एक पसंदीदा गाना, जल्दी सोना, कुछ मीठा'),
      ],
    ),
    StarterTemplate(
      id: 'food',
      label: 'क्या खाएं',
      description: 'जब तय न कर पाएं तो खाना चुनें',
      cards: [
        ('मुख्य', 'चावल, रोटी, नूडल्स, पास्ता, पराठा'),
        ('शैली', 'घर का खाना, चाइनीज़, इटैलियन, दक्षिण भारतीय, स्ट्रीट फूड'),
        ('साथ में', 'सलाद, सूप, दाल, अंडा, मिठाई'),
      ],
    ),
  ];
}
