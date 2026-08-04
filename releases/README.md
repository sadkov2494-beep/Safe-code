# Release builds — Safe Code / Код Сейфа

Сборки для RuStore и прямой установки на Android.

## Файлы

| Файл | Размер | Назначение |
|------|--------|------------|
| `safe-code-release.apk` | ~60 MB | Установка вручную или загрузка в RuStore |
| `safe-code-release.aab` | ~61 MB | App Bundle для RuStore (если требуется) |

## Версия

- **1.2.4** (versionCode **8**)
- Package: `com.safecode.safe_code`
- Yandex Ads: demo blocks (облачная сборка)

## Подпись и обновления

Начиная с **1.2.4+8** все APK из этого репозитория подписываются **одним CI-ключом**
(`android/keystores/safe-code-ci-upload.jks`). Новые версии можно ставить **поверх старой**
без удаления приложения.

Если у вас установлена сборка **1.2.3 или ниже** с облачной debug-подписью — удалите её
**один раз** и поставьте 1.2.4+. Дальше обновления будут накатываться автоматически.

Подробнее: `Safe-code/docs/ANDROID_SIGNING.md`

## SHA256

- APK: `fb98ef236dd628c28e366822fe90fcf4b548e6a807455f427cf8d01ca425df96`
- Cert SHA-256: `0af0b2555c5f821470c8f21f66fcd675b1e6bff05b7bfbb36d0df868bab5745c`

## Скачать

- APK: https://github.com/sadkov2494-beep/Safe-code/raw/cursor/consistent-android-signing-b62e/releases/safe-code-release.apk

## Установка APK вручную

1. Скачайте APK на телефон.
2. Разрешите установку из браузера или файлового менеджера.
3. Откройте файл и установите (поверх старой версии 1.2.4+, если она уже есть).

## RuStore

Пошаговая публикация: `Safe-code/docs/RUSTORE_PUBLISH.md`

Для RuStore с **собственным** release keystore:

```bash
bash scripts/generate-rustore-keystore.sh
bash scripts/build-rustore-release.sh
```

## Реклама

Сборка **1.2.1+5** собрана с боевыми блоками Яндекс РСЯ (rewarded + interstitial).
