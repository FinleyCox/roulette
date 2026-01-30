import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'ad_manager.dart';

class AppOpenAdManager {
  static AppOpenAd? _appOpenAd;
  static bool _isShowingAd = false;
  static bool _isAdAvailable = false;

  /// App Open Adを読み込む
  static void loadAd() {
    AppOpenAd.load(
      adUnitId: AdManager.appOpenAdUnitId,
      request: const AdRequest(),
      orientation: AppOpenAd.orientationPortrait,
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          _appOpenAd = ad;
          _isAdAvailable = true;
          debugPrint('App Open Ad loaded successfully');
        },
        onAdFailedToLoad: (error) {
          debugPrint('App Open Ad failed to load: $error');
          _isAdAvailable = false;
        },
      ),
    );
  }

  /// App Open Adを表示する
  static void showAdIfAvailable() {
    if (!_isAdAvailable || _appOpenAd == null || _isShowingAd) {
      return;
    }

    _isShowingAd = true;
    _appOpenAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        debugPrint('App Open Ad showed full screen content');
      },
      onAdDismissedFullScreenContent: (ad) {
        debugPrint('App Open Ad dismissed');
        ad.dispose();
        _appOpenAd = null;
        _isAdAvailable = false;
        _isShowingAd = false;
        // 次の広告を読み込む
        loadAd();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('App Open Ad failed to show: $error');
        ad.dispose();
        _appOpenAd = null;
        _isAdAvailable = false;
        _isShowingAd = false;
        // 次の広告を読み込む
        loadAd();
      },
    );

    _appOpenAd!.show();
  }

  /// 広告が利用可能かどうかを確認
  static bool get isAdAvailable => _isAdAvailable;

  /// 広告を破棄
  static void dispose() {
    _appOpenAd?.dispose();
    _appOpenAd = null;
    _isAdAvailable = false;
    _isShowingAd = false;
  }
}
