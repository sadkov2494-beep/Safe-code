# Release builds — Safe Code / Код Сейфа

## Версия

- **1.2.5** (versionCode **9**)
- Package: `com.safecode.safe_code`

## Подпись: RuStore vs GitHub

| Канал | Ключ |
|-------|------|
| **RuStore** | Ваш release keystore (`android/key.properties`) — **тот же**, что для первой версии |
| **GitHub APK** | CI-keystore (`android/ci-key.properties`) |

Обновления RuStore **нельзя** подписывать CI-ключом, если первая версия уже в магазине.
Подробнее: `Safe-code/docs/ANDROID_SIGNING.md`

## Иконка

В 1.2.5 исправлена иконка: исходник был 1536×1024 (не квадрат), из-за этого на Android она выглядела сплющенной.
Теперь используется квадрат 1024×1024 + adaptive foreground.

## Скачать (GitHub, CI-подпись)

- APK: https://github.com/sadkov2494-beep/Safe-code/raw/cursor/consistent-android-signing-b62e/releases/safe-code-release.apk
- SHA256: `ae7b8e65ff96b016412691d0dbeecac9949ef62f3e2a7ca25d2bb0f768c127aa`

## RuStore

Соберите локально с **вашим** keystore:

```bash
bash scripts/build-rustore-release.sh
```
