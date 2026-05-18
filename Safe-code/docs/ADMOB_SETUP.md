# Safe Code AdMob setup

The app already contains a real Google Mobile Ads integration. Development builds use
official Google test ad unit ids so the game can be tested safely before store release.

## Current in-game placements

- Rewarded ad: extra hint.
- Rewarded ad: extra attempt.
- Rewarded ad: skip level.
- Interstitial ad: between completed levels.

The gameplay calls are centralized in `lib/services/ad_service.dart`.

## Replace test ids before production

### Android app id

Replace the test app id in:

`android/app/src/main/AndroidManifest.xml`

```xml
<meta-data
    android:name="com.google.android.gms.ads.APPLICATION_ID"
    android:value="ca-app-pub-xxxxxxxxxxxxxxxx~yyyyyyyyyy" />
```

### iOS app id

Replace the test app id in:

`ios/Runner/Info.plist`

```xml
<key>GADApplicationIdentifier</key>
<string>ca-app-pub-xxxxxxxxxxxxxxxx~yyyyyyyyyy</string>
```

### Ad unit ids

Pass real ad unit ids with `--dart-define` at build time:

```bash
flutter build appbundle --release \
  --dart-define=SAFE_CODE_ANDROID_REWARDED_HINT_ID=ca-app-pub-xxx/yyy \
  --dart-define=SAFE_CODE_ANDROID_REWARDED_ATTEMPT_ID=ca-app-pub-xxx/yyy \
  --dart-define=SAFE_CODE_ANDROID_REWARDED_SKIP_ID=ca-app-pub-xxx/yyy \
  --dart-define=SAFE_CODE_ANDROID_INTERSTITIAL_ID=ca-app-pub-xxx/yyy
```

For iOS:

```bash
flutter build ipa --release \
  --dart-define=SAFE_CODE_IOS_REWARDED_HINT_ID=ca-app-pub-xxx/yyy \
  --dart-define=SAFE_CODE_IOS_REWARDED_ATTEMPT_ID=ca-app-pub-xxx/yyy \
  --dart-define=SAFE_CODE_IOS_REWARDED_SKIP_ID=ca-app-pub-xxx/yyy \
  --dart-define=SAFE_CODE_IOS_INTERSTITIAL_ID=ca-app-pub-xxx/yyy
```

## Privacy requirements

Before enabling real ads in stores:

1. Publish a privacy policy URL.
2. Complete Google Play Data Safety.
3. Mark the app as containing ads.
4. Add GDPR/EEA consent flow if you serve ads in regulated regions.
5. Keep test ads in debug and internal testing builds.
6. On iOS, review App Tracking Transparency wording and Apple privacy answers.

## Recommended ad pacing

- Rewarded ads are user initiated and safe to keep.
- Interstitial ads should stay between levels only.
- Do not show interstitial ads after failed attempts or while the player is reading clues.
