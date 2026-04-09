import 'dart:async';
import 'package:flutter/foundation.dart';

// purchases_flutter não suporta web — importado condicionalmente via guard kIsWeb em main.dart
import 'package:purchases_flutter/purchases_flutter.dart';

/// Gerencia assinaturas e compras avulsas via RevenueCat.
///
/// IDs de entitlement e produto devem ser configurados no dashboard RevenueCat
/// e espelhados nas constantes abaixo.
class RevenueCatManager {
  RevenueCatManager._();
  static final RevenueCatManager instance = RevenueCatManager._();

  // ─── Constantes ──────────────────────────────────────────────────────────

  static const String _entitlementPro = 'pro';

  static const String _monthlyProductId = 'word_duel_pro_monthly';
  static const String _yearlyProductId = 'word_duel_pro_yearly';
  static const String _langPackProductId = 'word_duel_lang_pack';
  static const String _themePackProductId = 'word_duel_theme_pack';

  // ─── Estado ───────────────────────────────────────────────────────────────

  final StreamController<bool> _isProController =
      StreamController<bool>.broadcast();

  Stream<bool> get isProStream => _isProController.stream;
  bool _isPro = false;
  bool get isPro => _isPro;

  // ─── Inicialização ────────────────────────────────────────────────────────

  Future<void> initialize({
    required String androidApiKey,
    required String iosApiKey,
  }) async {
    await Purchases.setLogLevel(kDebugMode ? LogLevel.debug : LogLevel.error);

    final config = PurchasesConfiguration(
      defaultTargetPlatform == TargetPlatform.android
          ? androidApiKey
          : iosApiKey,
    );

    await Purchases.configure(config);

    Purchases.addCustomerInfoUpdateListener(_onCustomerInfoUpdate);
    await _refreshStatus();
  }

  Future<void> identifyUser(String userId) async {
    await Purchases.logIn(userId);
    await _refreshStatus();
  }

  Future<void> logout() async {
    await Purchases.logOut();
    _updateProStatus(false);
  }

  // ─── Status ───────────────────────────────────────────────────────────────

  Future<void> _refreshStatus() async {
    try {
      final info = await Purchases.getCustomerInfo();
      _onCustomerInfoUpdate(info);
    } catch (_) {}
  }

  void _onCustomerInfoUpdate(CustomerInfo info) {
    final active = info.entitlements.active[_entitlementPro] != null;
    _updateProStatus(active);
  }

  void _updateProStatus(bool isPro) {
    _isPro = isPro;
    _isProController.add(isPro);
  }

  // ─── Compras ──────────────────────────────────────────────────────────────

  Future<bool> purchaseMonthly() => _purchaseProduct(_monthlyProductId);
  Future<bool> purchaseYearly() => _purchaseProduct(_yearlyProductId);
  Future<bool> purchaseLanguagePack() => _purchaseProduct(_langPackProductId);
  Future<bool> purchaseThemePack() => _purchaseProduct(_themePackProductId);

  Future<bool> _purchaseProduct(String productId) async {
    try {
      final offerings = await Purchases.getOfferings();
      final offering = offerings.current;
      if (offering == null) return false;

      final package = offering.availablePackages.firstWhere(
        (p) => p.storeProduct.identifier == productId,
        orElse: () => offering.availablePackages.first,
      );

      final info = await Purchases.purchasePackage(package);
      _onCustomerInfoUpdate(info);
      return true;
    } on PurchasesErrorCode catch (e) {
      if (e == PurchasesErrorCode.purchaseCancelledError) return false;
      rethrow;
    }
  }

  Future<void> restorePurchases() async {
    final info = await Purchases.restorePurchases();
    _onCustomerInfoUpdate(info);
  }

  // ─── Limpeza ──────────────────────────────────────────────────────────────

  void dispose() {
    _isProController.close();
  }
}
