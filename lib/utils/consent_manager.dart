import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Google User Messaging Platform (UMP) を使った広告同意管理。
///
/// EEA・英国・スイス等では、Google 認定 CMP による同意取得前に
/// パーソナライズ広告をリクエストしてはならない（AdMob / Google EU ユーザー同意ポリシー）。
/// 米国の州プライバシー法向けメッセージも UMP で配信される。
class ConsentManager {
  ConsentManager._();
  static final ConsentManager instance = ConsentManager._();

  bool _mobileAdsInitialized = false;

  /// Mobile Ads SDK の初期化が完了し、広告をリクエストできる状態か
  final ValueNotifier<bool> adsReady = ValueNotifier<bool>(false);

  /// 起動時に同意情報を更新し、必要なら同意フォームを表示する。
  /// 完了後、広告リクエスト可能なら Mobile Ads SDK を初期化する。
  Future<void> gatherConsent() async {
    final completer = Completer<void>();

    ConsentInformation.instance.requestConsentInfoUpdate(
      ConsentRequestParameters(),
      () async {
        await ConsentForm.loadAndShowConsentFormIfRequired((FormError? error) {
          if (error != null) {
            debugPrint('Consent form error: ${error.errorCode} ${error.message}');
          }
          if (!completer.isCompleted) completer.complete();
        });
      },
      (FormError error) {
        debugPrint('Consent info update failed: ${error.errorCode} ${error.message}');
        if (!completer.isCompleted) completer.complete();
      },
    );

    // ネットワーク不調などでコールバックが返らない場合でも起動を止めない
    await completer.future.timeout(
      const Duration(seconds: 10),
      onTimeout: () {},
    );

    await initializeMobileAdsIfAllowed();
  }

  Future<bool> canRequestAds() => ConsentInformation.instance.canRequestAds();

  Future<void> initializeMobileAdsIfAllowed() async {
    if (_mobileAdsInitialized) return;
    if (!await canRequestAds()) return;
    _mobileAdsInitialized = true;
    await MobileAds.instance.initialize();
    adsReady.value = true;
  }

  bool get isMobileAdsInitialized => _mobileAdsInitialized;

  /// プライバシーオプション（同意の変更）の入口を表示する必要があるか
  Future<bool> isPrivacyOptionsRequired() async {
    final status =
        await ConsentInformation.instance.getPrivacyOptionsRequirementStatus();
    return status == PrivacyOptionsRequirementStatus.required;
  }

  /// 同意内容を変更するためのフォームを表示する
  Future<void> showPrivacyOptionsForm() async {
    final completer = Completer<void>();
    ConsentForm.showPrivacyOptionsForm((FormError? error) {
      if (error != null) {
        debugPrint('Privacy options form error: ${error.message}');
      }
      completer.complete();
    });
    await completer.future;
    await initializeMobileAdsIfAllowed();
  }
}
