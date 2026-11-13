import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../utils/ad_manager.dart';
import '../utils/consent_manager.dart';

class BannerAdWidget extends StatefulWidget {
  const BannerAdWidget({super.key});

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;
  bool _isLoading = false;
  bool _hasRequestedAd = false;
  int _retryCount = 0;
  static const int _maxRetryCount = 3;

  final ValueNotifier<bool> _adsReady = ConsentManager.instance.adsReady;

  @override
  void initState() {
    super.initState();
    _adsReady.addListener(_onAdsReadyChanged);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _requestAdIfReady();
  }

  void _onAdsReadyChanged() => _requestAdIfReady();

  // 同意取得（UMP）と Mobile Ads SDK 初期化が終わるまで広告をリクエストしない
  void _requestAdIfReady() {
    if (!_hasRequestedAd && _adsReady.value && mounted) {
      _hasRequestedAd = true;
      _loadAd();
    }
  }

  Future<void> _loadAd() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    final mediaQuery = MediaQuery.of(context);
    final adSize =
        await AdSize.getLargeAnchoredAdaptiveBannerAdSizeWithOrientation(
          mediaQuery.orientation,
          mediaQuery.size.width.truncate(),
        );

    if (!mounted) return;

    if (adSize == null) {
      setState(() {
        _isLoading = false;
        _isLoaded = false;
      });
      return;
    }

    _bannerAd?.dispose();
    _bannerAd = BannerAd(
      adUnitId: AdManager.bannerAdUnitId,
      request: const AdRequest(),
      size: adSize,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (!mounted) return;
          setState(() {
            _isLoaded = true;
            _isLoading = false;
            _retryCount = 0;
          });
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          if (!mounted) return;
          if (_retryCount < _maxRetryCount) {
            _retryCount++;
            Future.delayed(Duration(seconds: 2 * _retryCount), _loadAd);
          } else {
            setState(() {
              _isLoading = false;
              _isLoaded = false;
            });
          }
        },
      ),
    );

    _bannerAd!.load();
  }

  @override
  void dispose() {
    _adsReady.removeListener(_onAdsReadyChanged);
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SizedBox(
        height: 60,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (!_isLoaded || _bannerAd == null) {
      return const SizedBox.shrink();
    }

    return Center(
      child: Container(
        width: _bannerAd!.size.width.toDouble(),
        height: _bannerAd!.size.height.toDouble(),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(4),
        ),
        child: AdWidget(ad: _bannerAd!),
      ),
    );
  }
}
