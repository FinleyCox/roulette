import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'utils/language_utils.dart';
import 'widgets/app_lifecycle_manager.dart';
import 'screens/onboarding_screen.dart';
import 'utils/onboarding_content.dart';
import 'utils/purchase_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 購入状態（ローカル保存分＋ストアからの復元）を先に読み込む。
  // 広告の初期化・表示は同意取得（UMP）後に AppLifecycleManager で行う。
  await PurchaseManager().init();
  final needsOnboarding = await OnboardingContent.isNeeded();

  runApp(MyApp(showOnboarding: needsOnboarding));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key, this.showOnboarding = false});

  /// 初回起動時はオンボーディングを先に表示し、広告・同意フォームはその後に出す
  final bool showOnboarding;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _currentLanguage = 'ja';
  late bool _showOnboarding = widget.showOnboarding;

  @override
  void initState() {
    super.initState();
    // 保存済み設定の読み込みまでの間も端末の言語で表示する
    _currentLanguage = _deviceDefaultLanguage();
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    final language =
        await LanguageUtils.getCurrentLanguage() ?? _deviceDefaultLanguage();
    if (!mounted) return;
    setState(() {
      _currentLanguage = language;
    });
  }

  /// 言語未設定時は端末の言語に合わせる（ja / hi 以外は英語）
  String _deviceDefaultLanguage() {
    final code =
        WidgetsBinding.instance.platformDispatcher.locale.languageCode;
    return const ['ja', 'hi'].contains(code) ? code : 'en';
  }

  void _changeLanguage(String languageCode) async {
    await LanguageUtils.setLanguage(languageCode);
    setState(() {
      _currentLanguage = languageCode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        textTheme: const TextTheme(
          bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
          bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
          titleLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          titleMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          titleSmall: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
        scaffoldBackgroundColor: Colors.white,
      ),
      themeMode: ThemeMode.light,
      darkTheme: ThemeData.dark(),
      debugShowCheckedModeBanner: false,

      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale("ja", "JP"),
        Locale("en", "US"),
        Locale("hi", "IN"),
      ],

      locale: Locale(_currentLanguage),
      home: _showOnboarding
          ? OnboardingScreen(
              currentLanguage: _currentLanguage,
              onLanguageChanged: _changeLanguage,
              onFinished: () => setState(() => _showOnboarding = false),
            )
          : AppLifecycleManager(
              // オンボーディング直後のセッションでは起動時の App Open 広告を出さない
              showAppOpenAdOnStart: !widget.showOnboarding,
              child: HomeScreen(
                title: 'simple scratch',
                onLanguageChanged: _changeLanguage,
                currentLanguage: _currentLanguage,
              ),
            ),
    );
  }
}
