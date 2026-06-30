import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class BannerAdWidget extends StatefulWidget {
  const BannerAdWidget({super.key});

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  BannerAd? bannerAd;
  bool isLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  void _loadAd() {
    if (kIsWeb) return; // Ads are not supported on web via this plugin

    bannerAd = BannerAd(
      size: AdSize.banner,
      adUnitId: kDebugMode
          ? 'ca-app-pub-3940256099942544/6300978111' // Google Test Ad Unit ID
          : 'ca-app-pub-9486838639385521/8686193277',
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (!mounted) {
            ad.dispose();
            return;
          }
          setState(() {
            isLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('BannerAd failed to load: $error');
          ad.dispose();
        },
      ),
      request: const AdRequest(),
    );

    bannerAd!.load();
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb || bannerAd == null || !isLoaded) {
      return const SizedBox.shrink();
    }

    return Container(
      alignment: Alignment.center,
      width: bannerAd!.size.width.toDouble(),
      height: bannerAd!.size.height.toDouble(),
      child: AdWidget(ad: bannerAd!),
    );
  }

  @override
  void dispose() {
    bannerAd?.dispose();
    super.dispose();
  }
}
