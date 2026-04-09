import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Gerencia anúncios intersticiais AdMob.
///
/// Regras de exibição (App Store compliance):
/// - A cada 5 **partidas** encerradas (completas ou por desistência)
/// - Apenas na ResultScreen ou na tela de desistência — nunca durante a partida
/// - Nunca na primeira sessão do usuário
/// - Nunca para usuários Pro
class AdManager {
  AdManager._();
  static final AdManager instance = AdManager._();

  static const String _gameCountKey = 'ad_game_count';
  static const String _firstSessionKey = 'is_first_session';

  // App ID: ca-app-pub-7119651995356791~4296617666
  // (configurado em AndroidManifest.xml e Info.plist)
  //
  // Ad Unit IDs abaixo são os IDs de TESTE do Google.
  // Substitua pelos IDs de produção criados no AdMob Console
  // (Aplicativo → Unidades de anúncio → Intersticial) antes de publicar.
  static const String _androidInterstitialId =
      'ca-app-pub-3940256099942544/1033173712'; // TODO: substituir pelo ID de produção Android
  static const String _iosInterstitialId =
      'ca-app-pub-7119651995356791/3320449477'; // TODO: substituir pelo ID de produção iOS

  InterstitialAd? _interstitialAd;
  bool _isLoaded = false;
  bool _isFirstSession = true;
  int _gameCount = 0;

  // ─── Inicialização ────────────────────────────────────────────────────────

  Future<void> initialize() async {
    if (kIsWeb) return;
    await MobileAds.instance.initialize();
    await _loadPersistedState();
    if (!_isFirstSession) {
      _loadInterstitial();
    }
  }

  Future<void> _loadPersistedState() async {
    final prefs = await SharedPreferences.getInstance();
    _isFirstSession = !(prefs.getBool(_firstSessionKey) ?? false);
    _gameCount = prefs.getInt(_gameCountKey) ?? 0;
    if (_isFirstSession) {
      await prefs.setBool(_firstSessionKey, true);
    }
  }

  // ─── Carregamento ─────────────────────────────────────────────────────────

  void _loadInterstitial() {
    final adUnitId = defaultTargetPlatform == TargetPlatform.android
        ? _androidInterstitialId
        : _iosInterstitialId;

    InterstitialAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isLoaded = true;
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (_) {
              _isLoaded = false;
              _interstitialAd = null;
              _loadInterstitial();
            },
            onAdFailedToShowFullScreenContent: (_, __) {
              _isLoaded = false;
              _interstitialAd = null;
              _loadInterstitial();
            },
          );
        },
        onAdFailedToLoad: (_) {
          _isLoaded = false;
        },
      ),
    );
  }

  // ─── API pública ──────────────────────────────────────────────────────────

  /// Deve ser chamado ao **encerrar qualquer partida** (completa ou desistência).
  ///
  /// Incrementa o contador persistente e exibe o anúncio se:
  ///   - usuário não é Pro
  ///   - não é a primeira sessão
  ///   - contador chegou a múltiplo de 5
  ///
  /// Retorna `true` se o anúncio foi exibido.
  Future<bool> recordGameEnd({required bool isPro}) async {
    if (kIsWeb) return false;
    _gameCount++;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_gameCountKey, _gameCount);

    if (isPro) return false;
    if (_isFirstSession) return false;
    if (_gameCount % 5 != 0) return false;
    if (!_isLoaded || _interstitialAd == null) return false;

    _interstitialAd!.show();
    return true;
  }

  /// Conta de partidas encerradas (para debug/testes).
  int get gameCount => _gameCount;

  void dispose() {
    _interstitialAd?.dispose();
  }
}
