# Safe Code RuStore release checklist

## Build artifacts

Direct Android install:

```bash
flutter build apk --release
```

RuStore upload, if App Bundle is accepted in your console flow:

```bash
flutter build appbundle --release
```

Convenience script from repository root:

```bash
bash scripts/build-rustore-release.sh
```

Set real Yandex ad unit ids through environment variables before running the script:

```bash
export SAFE_CODE_YANDEX_REWARDED_HINT_ID=R-M-XXXXXX-Y
export SAFE_CODE_YANDEX_REWARDED_ATTEMPT_ID=R-M-XXXXXX-Y
export SAFE_CODE_YANDEX_REWARDED_SKIP_ID=R-M-XXXXXX-Y
export SAFE_CODE_YANDEX_INTERSTITIAL_ID=R-M-XXXXXX-Y
bash scripts/build-rustore-release.sh
```

Current generated files are kept in `/releases`:

- `safe-code-release.apk`
- `safe-code-release.aab`

## Package and version

- Package id: `com.safecode.safe_code`
- App name: `Safe Code`
- Version is controlled by `version:` in `pubspec.yaml`.

Do not change package id after publishing, otherwise stores treat it as a different app.

## Release signing

Cloud Agent test builds fall back to debug signing when `android/key.properties`
is absent. Before production upload:

1. Generate a release keystore.
2. Keep it outside git.
3. Configure Gradle release signing.
4. Upload the release-signed APK/AAB to RuStore.

Example keystore command:

```bash
keytool -genkeypair \
  -v \
  -keystore safe-code-upload-keystore.jks \
  -alias safe-code-upload \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10000
```

Create `Safe-code/android/key.properties`:

```properties
storePassword=YOUR_STORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=safe-code-upload
storeFile=/absolute/path/to/safe-code-upload-keystore.jks
```

Never commit `key.properties` or the `.jks` keystore.

## RuStore Console

1. Create or log in to RuStore Console: https://console.rustore.ru/
2. Complete developer verification.
3. Create the app card.
4. Fill in:
   - title;
   - short and full description;
   - category: Games / Puzzle;
   - support email;
   - privacy policy URL;
   - age rating;
   - screenshots;
   - feature graphic if requested.
5. Mark that the app contains ads if real Yandex Ads ids are used.
6. Upload the release-signed build.
7. Submit for moderation.

## Assets already prepared

- Launcher icons for Android/iOS.
- Feature graphic: `store_assets/safe-code-feature-graphic.png`.
- Privacy policy draft: `docs/PRIVACY_POLICY_DRAFT.md`.
- Yandex Ads setup: `docs/YANDEX_ADS_SETUP.md`.

## Still required from the owner

- RuStore developer account and verification.
- Release keystore and passwords.
- Real Yandex Advertising Network ad unit ids.
- Public privacy policy URL.
- Store screenshots from a real device or emulator.
