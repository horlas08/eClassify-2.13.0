
import 'package:google_mobile_ads/google_mobile_ads.dart';

class InterstitialAdHelper {
  static final InterstitialAdHelper _instance = InterstitialAdHelper._internal();
  InterstitialAdHelper._internal();
  static InterstitialAdHelper get instance => _instance;

  static InterstitialAd? _interstitialAd;

  static void loadInterstitialAd(String adUnitId) {
    InterstitialAd.load(
        adUnitId: adUnitId,
        request: AdRequest(
          nonPersonalizedAds: true,
        ),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (InterstitialAd ad) {
            _interstitialAd = ad;
            _interstitialAd!.setImmersiveMode(true);
          },
          onAdFailedToLoad: (LoadAdError error) {
            _interstitialAd = null;
          },
        ));
  }

  static void showInterstitialAd() {
    if (_interstitialAd == null) {
      return;
    }
    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (InterstitialAd ad) =>
          print('ad onAdShowedFullScreenContent.'),
      onAdDismissedFullScreenContent: (InterstitialAd ad) {
        ad.dispose();
      },
      onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
        ad.dispose();
      },
    );
    _interstitialAd!.show();
    _interstitialAd = null;
  }
}
