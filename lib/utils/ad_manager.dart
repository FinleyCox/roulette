import 'dart:io';

import 'package:flutter/foundation.dart';

/// 広告ユニット ID。
/// デバッグビルドでは Google 公式のテスト用 ID を使い、開発中に本番広告を
/// 表示・クリックしてしまうこと（AdMob の無効なトラフィック扱い）を防ぐ。
class AdManager {
  static String get bannerAdUnitId {
    if (kDebugMode) {
      return Platform.isIOS
          ? 'ca-app-pub-3940256099942544/2435281174'
          : 'ca-app-pub-3940256099942544/9214589741';
    }
    if (Platform.isIOS) {
      return 'ca-app-pub-5173189590303230/9223235277';
    } else {
      return 'ca-app-pub-5173189590303230/8496793220';
    }
  }

  static String get interstitialAdUnitId {
    return 'ca-app-pub-5173189590303230/8959542248';
  }

  static String get appOpenAdUnitId {
    if (kDebugMode) {
      return Platform.isIOS
          ? 'ca-app-pub-3940256099942544/5575463023'
          : 'ca-app-pub-3940256099942544/9257395921';
    }
    if (Platform.isIOS) {
      return 'ca-app-pub-5173189590303230/8237456660';
    } else {
      return 'ca-app-pub-5173189590303230/5679058194';
    }
  }
}
