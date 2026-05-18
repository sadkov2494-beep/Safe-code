import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

enum RewardedAdPlacement { extraHint, extraAttempt, skipLevel }

enum InterstitialAdPlacement { betweenLevels }

class AdService {
  const AdService();

  static const _androidRewardedTestId =
      'ca-app-pub-3940256099942544/5224354917';
  static const _iosRewardedTestId = 'ca-app-pub-3940256099942544/1712485313';
  static const _androidInterstitialTestId =
      'ca-app-pub-3940256099942544/1033173712';
  static const _iosInterstitialTestId =
      'ca-app-pub-3940256099942544/4411468910';

  static const _androidRewardedHintId = String.fromEnvironment(
    'SAFE_CODE_ANDROID_REWARDED_HINT_ID',
    defaultValue: _androidRewardedTestId,
  );
  static const _androidRewardedAttemptId = String.fromEnvironment(
    'SAFE_CODE_ANDROID_REWARDED_ATTEMPT_ID',
    defaultValue: _androidRewardedTestId,
  );
  static const _androidRewardedSkipId = String.fromEnvironment(
    'SAFE_CODE_ANDROID_REWARDED_SKIP_ID',
    defaultValue: _androidRewardedTestId,
  );
  static const _androidInterstitialId = String.fromEnvironment(
    'SAFE_CODE_ANDROID_INTERSTITIAL_ID',
    defaultValue: _androidInterstitialTestId,
  );

  static const _iosRewardedHintId = String.fromEnvironment(
    'SAFE_CODE_IOS_REWARDED_HINT_ID',
    defaultValue: _iosRewardedTestId,
  );
  static const _iosRewardedAttemptId = String.fromEnvironment(
    'SAFE_CODE_IOS_REWARDED_ATTEMPT_ID',
    defaultValue: _iosRewardedTestId,
  );
  static const _iosRewardedSkipId = String.fromEnvironment(
    'SAFE_CODE_IOS_REWARDED_SKIP_ID',
    defaultValue: _iosRewardedTestId,
  );
  static const _iosInterstitialId = String.fromEnvironment(
    'SAFE_CODE_IOS_INTERSTITIAL_ID',
    defaultValue: _iosInterstitialTestId,
  );

  static Future<void> initialize() async {
    if (!_supportsMobileAds) {
      return;
    }
    await MobileAds.instance.initialize();
  }

  Future<bool> showRewardedAd(RewardedAdPlacement placement) async {
    if (!_adsSupported) {
      return true;
    }

    final completer = Completer<bool>();
    await RewardedAd.load(
      adUnitId: _rewardedAdUnitId(placement),
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              if (!completer.isCompleted) {
                completer.complete(false);
              }
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              if (!completer.isCompleted) {
                completer.complete(false);
              }
            },
          );
          ad.show(
            onUserEarnedReward: (_, _) {
              if (!completer.isCompleted) {
                completer.complete(true);
              }
            },
          );
        },
        onAdFailedToLoad: (_) {
          if (!completer.isCompleted) {
            completer.complete(false);
          }
        },
      ),
    );
    return completer.future.timeout(
      const Duration(seconds: 12),
      onTimeout: () => false,
    );
  }

  Future<void> showInterstitialAd(InterstitialAdPlacement placement) async {
    if (!_adsSupported) {
      return;
    }

    final completer = Completer<void>();
    await InterstitialAd.load(
      adUnitId: _interstitialAdUnitId(placement),
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              if (!completer.isCompleted) {
                completer.complete();
              }
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              if (!completer.isCompleted) {
                completer.complete();
              }
            },
          );
          ad.show();
        },
        onAdFailedToLoad: (_) {
          if (!completer.isCompleted) {
            completer.complete();
          }
        },
      ),
    );
    await completer.future.timeout(
      const Duration(seconds: 8),
      onTimeout: () {},
    );
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
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return switch (placement) {
        RewardedAdPlacement.extraHint => _iosRewardedHintId,
        RewardedAdPlacement.extraAttempt => _iosRewardedAttemptId,
        RewardedAdPlacement.skipLevel => _iosRewardedSkipId,
      };
    }

    return switch (placement) {
      RewardedAdPlacement.extraHint => _androidRewardedHintId,
      RewardedAdPlacement.extraAttempt => _androidRewardedAttemptId,
      RewardedAdPlacement.skipLevel => _androidRewardedSkipId,
    };
  }

  String _interstitialAdUnitId(InterstitialAdPlacement placement) {
    return defaultTargetPlatform == TargetPlatform.iOS
        ? _iosInterstitialId
        : _androidInterstitialId;
  }
}
