import 'dart:io';

class AdManager {
  static String get bannerAdUnitId {
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
    if (Platform.isIOS) {
      return 'ca-app-pub-5173189590303230/8237456660';
    } else {
      return 'ca-app-pub-5173189590303230/5679058194';
    }
  }
}
