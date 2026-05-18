# Safe Code store release checklist

## Build artifacts

Android stores require an AAB for production:

```bash
flutter build appbundle --release
```

Direct installs can use:

```bash
flutter build apk --release
```

iOS release requires macOS and Xcode:

```bash
flutter build ipa --release
```

## Android signing

The repository currently uses the debug signing config for release builds so Cloud Agent
can produce a test APK. Before Google Play production release:

1. Create or register an upload key in Google Play Console.
2. Configure `android/key.properties`.
3. Replace `signingConfig = signingConfigs.getByName("debug")` with your release signing config.
4. Never commit the keystore or passwords.

## Store listing assets

Included:

- App icon: generated launcher icons for Android and iOS.
- Feature graphic: `store_assets/safe-code-feature-graphic.png`.

Still needed:

- Phone screenshots from a real device or emulator.
- Short and full store descriptions.
- Optional promo video.
- Support email.
- Privacy policy URL.

## Suggested Google Play listing

Short description:

> Открывайте сейфы по логике, уликам и ежедневным головоломкам.

Full description:

> Safe Code - мобильная логическая игра про вскрытие сейфов без случайного перебора.
> Изучайте сервисные журналы, физические следы на клавишах, главы дел и короткие
> логические ограничения. Ведите блокнот цифр, собирайте открытые сейфы и возвращайтесь
> за ежедневным уникальным сейфом.

Tags/categories:

- Puzzle
- Logic
- Brain training
- Single player

## Store forms

Google Play:

- Contains ads: yes, once real AdMob ids are used.
- Data Safety: ads SDK may collect device identifiers, diagnostics and approximate ad data.
- Content rating: puzzle/logic, no violence.
- Target audience: teens/adults unless you complete family-policy requirements.

App Store:

- App Privacy: declare advertising identifiers if real ads are enabled.
- ATT: keep `NSUserTrackingUsageDescription` updated for your final wording.
- Sign with Apple Developer account.
