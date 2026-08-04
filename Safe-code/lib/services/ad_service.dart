import 'package:flutter/foundation.dart';
import 'package:yandex_mobileads/mobile_ads.dart';

enum RewardedAdPlacement { extraHint, extraAttempt, skipLevel }

enum InterstitialAdPlacement { betweenLevels }

class AdService {
  const AdService();

  static const _rewardedTestId = 'demo-rewarded-yandex';
  static const _interstitialTestId = 'demo-interstitial-yandex';

  static const _rewardedHintId = String.fromEnvironment(
    'SAFE_CODE_YANDEX_REWARDED_HINT_ID',
    defaultValue: _rewardedTestId,
  );
  static const _rewardedAttemptId = String.fromEnvironment(
    'SAFE_CODE_YANDEX_REWARDED_ATTEMPT_ID',
    defaultValue: _rewardedTestId,
  );
  static const _rewardedSkipId = String.fromEnvironment(
    'SAFE_CODE_YANDEX_REWARDED_SKIP_ID',
    defaultValue: _rewardedTestId,
  );
  static const _interstitialId = String.fromEnvironment(
    'SAFE_CODE_YANDEX_INTERSTITIAL_ID',
    defaultValue: _interstitialTestId,
  );

  static Future<void> initialize() async {
    if (!_supportsMobileAds) {
      return;
    }
    await YandexAds.initialize();
  }

  Future<bool> showRewardedAd(RewardedAdPlacement placement) async {
    if (!_adsSupported) {
      return true;
    }

    RewardedAd? ad;
    try {
      ad = await RewardedAdLoader().loadAd(
        adRequest: AdRequest(adUnitId: _rewardedAdUnitId(placement)),
      );
      await ad.setAdEventListener(eventListener: RewardedAdEventListener());
      await ad.show();
      final reward = await ad.waitForDismiss().timeout(
        const Duration(seconds: 12),
        onTimeout: () => null,
      );
      return reward != null;
    } on AdRequestError {
      return false;
    } catch (_) {
      return false;
    } finally {
      ad?.destroy();
    }
  }

  Future<void> showInterstitialAd(InterstitialAdPlacement placement) async {
    if (!_adsSupported) {
      return;
    }

    InterstitialAd? ad;
    try {
      ad = await InterstitialAdLoader().loadAd(
        adRequest: AdRequest(adUnitId: _interstitialAdUnitId(placement)),
      );
      await ad.setAdEventListener(eventListener: InterstitialAdEventListener());
      await ad.show();
      await ad.waitForDismiss().timeout(
        const Duration(seconds: 8),
        onTimeout: () {},
      );
    } on AdRequestError {
      return;
    } catch (_) {
      return;
    } finally {
      ad?.destroy();
    }
  }

  bool get _adsSupported {
    return _supportsMobileAds;
  }

  static bool get _supportsMobileAds {
    return !kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.android ||
            defaultTargetPlatform == TargetPlatform.iOS);
  }

  String _rewardedAdUnitId(RewardedAdPlacement placement) {
    return switch (placement) {
      RewardedAdPlacement.extraHint => _rewardedHintId,
      RewardedAdPlacement.extraAttempt => _rewardedAttemptId,
      RewardedAdPlacement.skipLevel => _rewardedSkipId,
    };
  }

  String _interstitialAdUnitId(InterstitialAdPlacement placement) {
    return _interstitialId;
  }
}
