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
  DateTime? _pausedAt;

  /// 共有シート・購入画面・カメラ許可などアプリ内操作から戻った直後に
  /// App Open 広告を出さない（誤タップ防止）。一定時間以上離れていた場合のみ表示。
  static const Duration _minBackgroundDuration = Duration(seconds: 30);

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
          final pausedAt = _pausedAt;
          _pausedAt = null;
          // 一定時間以上バックグラウンドにいた場合のみ App Open 広告を表示
          if (pausedAt != null &&
              DateTime.now().difference(pausedAt) >= _minBackgroundDuration) {
            _showAppOpenAd();
          }
        }
        break;
      case AppLifecycleState.paused:
        if (_isAppInForeground) _pausedAt = DateTime.now();
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
