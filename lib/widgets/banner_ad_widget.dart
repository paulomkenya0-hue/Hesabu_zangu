import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../services/admob_service.dart';
import '../services/hive_service.dart';
import '../utils/colors.dart';

class BannerAdWidget extends StatefulWidget {
  const BannerAdWidget({super.key});

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  final AdMobService _adMob = AdMobService();
  final HiveService _hive = HiveService();
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  Future<void> _loadAd() async {
    if (_hive.isPremium()) return;
    await _adMob.loadBannerAd(
      onLoaded: () {
        if (mounted) setState(() => _isLoaded = true);
      },
    );
  }

  @override
  void dispose() {
    _adMob.disposeBanner();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Premium users — onyesha kitu kidogo tu
    if (_hive.isPremium()) {
      return const SizedBox.shrink();
    }

    // Ad imepakia
    if (_isLoaded && _adMob.bannerAd != null) {
      return Container(
        color: Colors.white,
        alignment: Alignment.center,
        width: _adMob.bannerAd!.size.width.toDouble(),
        height: _adMob.bannerAd!.size.height.toDouble(),
        child: AdWidget(ad: _adMob.bannerAd!),
      );
    }

    // Ad bado inapakia — onyesha premium promo ndogo
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      color: const Color(0xFFFFF8E1),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('👑', style: TextStyle(fontSize: 14)),
          const SizedBox(width: 6),
          const Text(
            'Ondoa matangazo — ',
            style: TextStyle(fontSize: 12, color: AppColors.textMedium),
          ),
          GestureDetector(
            onTap: () {
              // Navigate to premium
            },
            child: const Text(
              'Pata Premium',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
