# Safe Code Yandex Ads setup

Safe Code is prepared for RuStore-friendly monetization through the
`yandex_mobileads` Flutter SDK.

The current build uses official Yandex demo placements:

- Rewarded: `demo-rewarded-yandex`
- Interstitial: `demo-interstitial-yandex`

## Current placements

- Rewarded ad: extra hint.
- Rewarded ad: extra attempt.
- Rewarded ad: skip level.
- Interstitial ad: between completed levels.

All gameplay calls are centralized in `lib/services/ad_service.dart`.

## What to create in Yandex Advertising Network

1. Open Yandex Advertising Network: https://partner.yandex.com/
2. Register the Android app with package id:

   `com.safecode.safe_code`

3. Create ad units:
   - rewarded video for hints;
   - rewarded video for extra attempts;
   - rewarded video for level skip;
   - interstitial for between-level pauses.

## Build with production ad unit ids

Pass real Yandex ad unit ids at build time:

```bash
flutter build apk --release \
  --dart-define=SAFE_CODE_YANDEX_REWARDED_HINT_ID=R-M-XXXXXX-Y \
  --dart-define=SAFE_CODE_YANDEX_REWARDED_ATTEMPT_ID=R-M-XXXXXX-Y \
  --dart-define=SAFE_CODE_YANDEX_REWARDED_SKIP_ID=R-M-XXXXXX-Y \
  --dart-define=SAFE_CODE_YANDEX_INTERSTITIAL_ID=R-M-XXXXXX-Y
```

For RuStore production upload, prefer AAB if accepted by the current RuStore flow:

```bash
flutter build appbundle --release \
  --dart-define=SAFE_CODE_YANDEX_REWARDED_HINT_ID=R-M-XXXXXX-Y \
  --dart-define=SAFE_CODE_YANDEX_REWARDED_ATTEMPT_ID=R-M-XXXXXX-Y \
  --dart-define=SAFE_CODE_YANDEX_REWARDED_SKIP_ID=R-M-XXXXXX-Y \
  --dart-define=SAFE_CODE_YANDEX_INTERSTITIAL_ID=R-M-XXXXXX-Y
```

## Testing

Before release, keep the demo ids and check logs:

```bash
adb logcat | grep -i "Yandex Ads"
```

You should see messages that the SDK is integrated and initialized successfully.

## Privacy and policy

Before using real ads:

1. Publish a privacy policy URL.
2. In RuStore, mark the app as containing ads.
3. Disclose advertising identifiers and diagnostics if the store form asks.
4. Do not use interstitial ads during active puzzle solving; keep them between levels.
5. Keep rewarded ads user-initiated only.
