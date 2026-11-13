import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'ad_manager.dart';
import 'consent_manager.dart';
import 'purchase_manager.dart';

/// App Open 広告の管理（アプリ全体で 1 インスタンスのみ使用する）
class AppOpenAdManager {
  static AppOpenAd? _appOpenAd;
  static DateTime? _loadTime;
  static bool _isShowingAd = false;
  static bool _isLoading = false;

  /// App Open 広告は読み込みから 4 時間で失効する（AdMob ガイドライン）
  static const Duration _maxCacheDuration = Duration(hours: 4);

  static bool get _isAdAvailable =>
      _appOpenAd != null &&
      _loadTime != null &&
      DateTime.now().difference(_loadTime!) < _maxCacheDuration;

  static Future<bool> _canUseAds() async {
    if (PurchaseManager().isFullAdFree()) return false;
    if (!ConsentManager.instance.isMobileAdsInitialized) return false;
    return ConsentManager.instance.canRequestAds();
  }

  /// App Open 広告を読み込む。[showWhenLoaded] が true なら読み込み完了後に表示する。
  static Future<void> loadAd({bool showWhenLoaded = false}) async {
    if (_isLoading || _isAdAvailable) return;
    if (!await _canUseAds()) return;

    _isLoading = true;
    await AppOpenAd.load(
      adUnitId: AdManager.appOpenAdUnitId,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          _isLoading = false;
          _appOpenAd = ad;
          _loadTime = DateTime.now();
          if (showWhenLoaded) showAdIfAvailable();
        },
        onAdFailedToLoad: (error) {
          _isLoading = false;
          debugPrint('App Open Ad failed to load: $error');
        },
      ),
    );
  }

  /// App Open 広告を表示する（利用可能でなければ読み込みのみ行う）
  static Future<void> showAdIfAvailable() async {
    if (_isShowingAd) return;
    if (!await _canUseAds()) {
      dispose();
      return;
    }
    if (!_isAdAvailable) {
      _appOpenAd?.dispose();
      _appOpenAd = null;
      await loadAd();
      return;
    }

    _isShowingAd = true;
    _appOpenAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _appOpenAd = null;
        _isShowingAd = false;
        loadAd();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('App Open Ad failed to show: $error');
        ad.dispose();
        _appOpenAd = null;
        _isShowingAd = false;
        loadAd();
      },
    );
    await _appOpenAd!.show();
  }

  static void dispose() {
    _appOpenAd?.dispose();
    _appOpenAd = null;
    _loadTime = null;
    _isShowingAd = false;
  }
}
