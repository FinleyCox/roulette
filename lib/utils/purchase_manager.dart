import 'dart:async';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PurchaseManager {
  static const String productTier1 = 'tier_1_limit_3'; // 100 yen
  static const String productTier2 = 'tier_2_limit_10'; // 200 yen

  final InAppPurchase _iap = InAppPurchase.instance;
  bool _isAvailable = false;

  // Cache purchases locally for synchronous access
  final Set<String> _purchasedProductIds = {};
  int _tier1Count = 0; // Tracks how many times Tier 1 was purchased

  // Singleton
  static final PurchaseManager _instance = PurchaseManager._internal();
  factory PurchaseManager() => _instance;
  PurchaseManager._internal();

  final StreamController<void> _purchaseUpdateController =
      StreamController.broadcast();
  Stream<void> get purchaseUpdates => _purchaseUpdateController.stream;

  bool _initialized = false;
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  /// ストアから取得した商品情報（価格表示用）
  final Map<String, ProductDetails> _products = {};

  bool get isStoreAvailable => _isAvailable;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    // ローカルに保存済みの消費型購入回数を先に読み込む（広告表示判定に使うため）
    await loadPurchases();

    _isAvailable = await _iap.isAvailable();
    if (_isAvailable) {
      final Stream<List<PurchaseDetails>> purchaseUpdated = _iap.purchaseStream;
      _subscription = purchaseUpdated.listen(
        (purchaseDetailsList) {
          _listenToPurchaseUpdated(purchaseDetailsList);
        },
        onDone: () {
          // Updated
        },
        onError: (error) {
          // Error
        },
      );

      await restorePurchases();
      // 価格表示用に商品情報を取得（失敗しても起動は継続）
      unawaited(queryProducts());
    }
  }

  /// 商品情報を取得してキャッシュする
  Future<Map<String, ProductDetails>> queryProducts() async {
    if (!_isAvailable) return _products;
    try {
      final response = await _iap.queryProductDetails({
        productTier1,
        productTier2,
      });
      for (final p in response.productDetails) {
        _products[p.id] = p;
      }
      _purchaseUpdateController.add(null);
    } catch (_) {
      // ネットワークエラー等
    }
    return _products;
  }

  /// ストアのローカライズ済み価格（未取得なら null）
  String? priceOf(String productId) => _products[productId]?.price;

  Future<void> _listenToPurchaseUpdated(
    List<PurchaseDetails> purchaseDetailsList,
  ) async {
    for (final purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        // Pending
      } else {
        if (purchaseDetails.status == PurchaseStatus.error) {
          // Error
        } else if (purchaseDetails.status == PurchaseStatus.purchased ||
            purchaseDetails.status == PurchaseStatus.restored) {
          if (purchaseDetails.productID == productTier1) {
            // Tier 1 is consumable, we add to count and don't persist in non-consumable list
            // NOTE: Store-side consumables are not restored by restorePurchases() by design.
            // We must manage the "Effect" persistence ourselves.
            // If it's a fresh purchase (not restored), we increment.
            if (purchaseDetails.status == PurchaseStatus.purchased) {
              await _incrementTier1Count();
            }
          } else {
            _purchasedProductIds.add(purchaseDetails.productID);
            // _savePurchaseLocally(purchaseDetails.productID); // Non-consumables are not cached locally anymore to support revocations
          }
        }

        if (purchaseDetails.pendingCompletePurchase) {
          await _iap.completePurchase(purchaseDetails);
        }
      }
    }
    _purchaseUpdateController.add(null);
  }

  Future<void> restorePurchases() async {
    await _iap.restorePurchases();
  }

  /// 購入フローを開始する。開始できなかった場合は false を返す。
  Future<bool> buyProduct(String productId) async {
    if (!_isAvailable) return false;
    ProductDetails? productDetails = _products[productId];
    if (productDetails == null) {
      await queryProducts();
      productDetails = _products[productId];
    }
    if (productDetails == null) return false;

    final PurchaseParam purchaseParam = PurchaseParam(
      productDetails: productDetails,
    );

    if (productId == productTier1) {
      // Tier 1 is Consumable
      await _iap.buyConsumable(purchaseParam: purchaseParam);
    } else {
      // Tier 2 is Non-Consumable
      await _iap.buyNonConsumable(purchaseParam: purchaseParam);
    }
    return true;
  }

  void dispose() {
    _subscription?.cancel();
  }

  // Check limits with additive logic
  // Limit = 1 (Base) + (Tier1_Count * 3) + (Tier2_Status ? 10 : 0)
  int getPresetLimit() {
    int limit = 1;
    limit += _tier1Count * 3;
    if (_purchasedProductIds.contains(productTier2)) {
      limit += 10;
    }
    return limit;
  }

  // Ad Removal Logic
  // Tier 1 (100 yen): 1 purchase -> Banner removed. 2 purchases -> All ads removed.
  // Tier 2 (200 yen): Purchase -> All ads removed (and Banner removed).

  bool isBannerAdFree() {
    return _tier1Count >= 1 || _purchasedProductIds.contains(productTier2);
  }

  bool isFullAdFree() {
    return _tier1Count >= 2 || _purchasedProductIds.contains(productTier2);
  }

  // Deprecated: Use isBannerAdFree or isFullAdFree
  bool isAdFree() {
    return isFullAdFree();
  }

  // Tier 2 visibility check
  bool isTier2Purchased() {
    return _purchasedProductIds.contains(productTier2);
  }

  // Local persistence mainly for offline start before IAP sync

  Future<void> _incrementTier1Count() async {
    _tier1Count++;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('tier1_count', _tier1Count);
  }

  Future<void> loadPurchases() async {
    final prefs = await SharedPreferences.getInstance();

    // Load Non-Consumables
    // We intentionally do NOT load cached non-consumables (Tier 2) to avoid stale state.
    // They are restored via restorePurchases() on every init.
    // final List<String> purchases = prefs.getStringList('purchased_products') ?? [];
    // _purchasedProductIds.addAll(purchases);

    // Load Consumable Counts
    _tier1Count = prefs.getInt('tier1_count') ?? 0;
  }
}
