import 'package:flutter/material.dart';
import '../utils/app_open_ad_manager.dart';
import '../utils/consent_manager.dart';
import '../utils/purchase_manager.dart';

class AppLifecycleManager extends StatefulWidget {
  final Widget child;

  const AppLifecycleManager({super.key, required this.child});

  @override
  State<AppLifecycleManager> createState() => _AppLifecycleManagerState();
}

class _AppLifecycleManagerState extends State<AppLifecycleManager>
    with WidgetsBindingObserver {
  bool _isAppInForeground = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _initAds());
  }

  /// 同意取得 → Mobile Ads SDK 初期化 → 起動時の App Open 広告
  Future<void> _initAds() async {
    await ConsentManager.instance.gatherConsent();
    if (!mounted) return;
    if (!PurchaseManager().isFullAdFree()) {
      AppOpenAdManager.loadAd(showWhenLoaded: true);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.resumed:
        if (!_isAppInForeground) {
          _isAppInForeground = true;
          // アプリがフォアグラウンドに戻った時にApp Open Adを表示
          _showAppOpenAd();
        }
        break;
      case AppLifecycleState.paused:
        _isAppInForeground = false;
        break;
      case AppLifecycleState.inactive:
        break;
      case AppLifecycleState.detached:
        break;
      case AppLifecycleState.hidden:
        break;
    }
  }

  void _showAppOpenAd() {
    // 広告削除済みの場合は表示しない
    if (PurchaseManager().isFullAdFree()) return;
    if (!ConsentManager.instance.isMobileAdsInitialized) return;

    // 少し遅延を入れてから広告を表示（UIが安定してから）
    Future.delayed(const Duration(milliseconds: 500), () {
      AppOpenAdManager.showAdIfAvailable();
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
