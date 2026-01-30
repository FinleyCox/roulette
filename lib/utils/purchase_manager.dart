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

  Future<void> init() async {
    _isAvailable = await _iap.isAvailable();
    if (_isAvailable) {
      final Stream<List<PurchaseDetails>> purchaseUpdated = _iap.purchaseStream;
      purchaseUpdated.listen(
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
    }
  }

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
            _savePurchaseLocally(purchaseDetails.productID);
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

  Future<void> buyProduct(String productId) async {
    final ProductDetailsResponse response = await _iap.queryProductDetails({
      productId,
    });
    if (response.notFoundIDs.isNotEmpty) {
      // Product not found
      return;
    }
    final List<ProductDetails> products = response.productDetails;
    final ProductDetails productDetails = products.first;

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

  bool isAdFree() {
    // Ad free if any purchase made (Tier 1 count > 0 OR Tier 2 purchased)
    return _tier1Count > 0 || _purchasedProductIds.contains(productTier2);
  }

  // Tier 2 visibility check
  bool isTier2Purchased() {
    return _purchasedProductIds.contains(productTier2);
  }

  // Local persistence mainly for offline start before IAP sync
  Future<void> _savePurchaseLocally(String productId) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> purchases =
        prefs.getStringList('purchased_products') ?? [];
    if (!purchases.contains(productId)) {
      purchases.add(productId);
      await prefs.setStringList('purchased_products', purchases);
    }
  }

  Future<void> _incrementTier1Count() async {
    _tier1Count++;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('tier1_count', _tier1Count);
  }

  Future<void> loadPurchases() async {
    final prefs = await SharedPreferences.getInstance();

    // Load Non-Consumables
    final List<String> purchases =
        prefs.getStringList('purchased_products') ?? [];
    _purchasedProductIds.addAll(purchases);

    // Load Consumable Counts
    _tier1Count = prefs.getInt('tier1_count') ?? 0;
  }
}
