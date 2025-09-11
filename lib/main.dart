import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'utils/language_utils.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'utils/app_open_ad_manager.dart';
import 'widgets/app_lifecycle_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // AdMobを初期化
  await MobileAds.instance.initialize();

  // App Open Adを読み込む
  AppOpenAdManager.loadAd();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _currentLanguage = 'ja';

  @override
  void initState() {
    super.initState();
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    final language = await LanguageUtils.getCurrentLanguage();
    setState(() {
      _currentLanguage = language;
    });
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

      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale("ja", "JP"), Locale("en", "US")],

      home: AppLifecycleManager(
        child: HomeScreen(
          title: 'simple scratch',
          onLanguageChanged: _changeLanguage,
          currentLanguage: _currentLanguage,
        ),
      ),
    );
  }
}
