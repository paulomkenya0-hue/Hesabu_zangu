import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../utils/constants.dart';
import '../services/hive_service.dart';

class AdMobService {
  // ━━━ SINGLETON ━━━
  static final AdMobService _instance = AdMobService._internal();
  factory AdMobService() => _instance;
  AdMobService._internal();

  final HiveService _hive = HiveService();

  // Ad instances
  BannerAd? _bannerAd;
  InterstitialAd? _interstitialAd;
  bool _isBannerLoaded = false;
  bool _isInterstitialLoaded = false;
  int _transactionCount = 0; // Kuhesabu interstitial timing

  // ━━━━━━━━━━━━━━━━
  // INITIALIZE ADMOB
  // ━━━━━━━━━━━━━━━━
  static Future<void> init() async {
    await MobileAds.instance.initialize();

    // Tanzania specific configuration
    await MobileAds.instance.updateRequestConfiguration(
      RequestConfiguration(
        testDeviceIds: [
          // Ongeza device ID yako hapa kwa testing
          // Pata ID kutoka logcat: "Test Device ID:"
        ],
      ),
    );
  }

  // ━━━━━━━━━━━━━━━━
  // BANNER AD
  // ━━━━━━━━━━━━━━━━
  BannerAd? get bannerAd => _isBannerLoaded ? _bannerAd : null;
  bool get isBannerLoaded => _isBannerLoaded;

  Future<void> loadBannerAd({VoidCallback? onLoaded}) async {
    // Premium users — hawoni ads
    if (_hive.isPremium()) return;

    _bannerAd = BannerAd(
      adUnitId: AppConstants.admobBannerAndroid,
      size: AdSize.banner,
      request: _buildAdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          debugPrint('✅ Banner Ad loaded');
          _isBannerLoaded = true;
          onLoaded?.call();
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('❌ Banner Ad failed: ${error.message}');
          _isBannerLoaded = false;
          ad.dispose();
        },
        onAdOpened: (ad) => debugPrint('Banner Ad opened'),
        onAdClosed: (ad) => debugPrint('Banner Ad closed'),
      ),
    );

    await _bannerAd!.load();
  }

  void disposeBanner() {
    _bannerAd?.dispose();
    _bannerAd = null;
    _isBannerLoaded = false;
  }

  // ━━━━━━━━━━━━━━━━━━━
  // INTERSTITIAL AD
  // Inaonyeshwa kila rekodi 5
  // ━━━━━━━━━━━━━━━━━━━
  Future<void> loadInterstitialAd() async {
    if (_hive.isPremium()) return;

    await InterstitialAd.load(
      adUnitId: AppConstants.admobInterstitialAndroid,
      request: _buildAdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          debugPrint('✅ Interstitial Ad loaded');
          _interstitialAd = ad;
          _isInterstitialLoaded = true;

          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _isInterstitialLoaded = false;
              // Load mwingine tayari
              loadInterstitialAd();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              _isInterstitialLoaded = false;
            },
          );
        },
        onAdFailedToLoad: (error) {
          debugPrint('❌ Interstitial failed: ${error.message}');
          _isInterstitialLoaded = false;
        },
      ),
    );
  }

  // Onyesha interstitial — kila rekodi 5
  Future<void> showInterstitialIfReady() async {
    if (_hive.isPremium()) return;

    _transactionCount++;

    // Onyesha kila rekodi 5
    if (_transactionCount % 5 == 0 && _isInterstitialLoaded) {
      await _interstitialAd?.show();
      debugPrint('🎯 Interstitial shown after $_transactionCount transactions');
    }
  }

  // ━━━━━━━━━━━━━━━━
  // AD REQUEST
  // ━━━━━━━━━━━━━━━━
  AdRequest _buildAdRequest() {
    return const AdRequest(
      keywords: [
        'finance',
        'money',
        'business',
        'banking',
        'tanzania',
        'pesa',
        'biashara',
      ],
      nonPersonalizedAds: false,
    );
  }
}
