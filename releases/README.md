# Release builds — Safe Code / Код Сейфа

Сборки для RuStore и прямой установки на Android.

## Файлы

| Файл | Размер | Назначение |
|------|--------|------------|
| `safe-code-release.apk` | ~60 MB | Установка вручную или загрузка в RuStore |
| `safe-code-release.aab` | ~61 MB | App Bundle для RuStore (если требуется) |

## Версия

- **1.2.1** (versionCode **5**)
- Package: `com.safecode.safe_code`
- Yandex Ads: production blocks `R-M-19316679-*` (вшиты в сборку)

## SHA256

- APK: `f8ee94f4335c118cdcbcffebd8e7e6efb58ae1d1e09d33cc6a0f1fac304de819`
- AAB: `67e7b5457549de27e3de9c65a0b713088ca2bb942c6330be7efe692eee31d1ea`

## Скачать

- APK: https://github.com/sadkov2494-beep/Safe-code/raw/cursor/safe-code-flutter-mvp-3784/releases/safe-code-release.apk
- AAB: https://github.com/sadkov2494-beep/Safe-code/raw/cursor/safe-code-flutter-mvp-3784/releases/safe-code-release.aab

## Установка APK вручную

1. Скачайте APK на телефон.
2. Разрешите установку из браузера или файлового менеджера.
3. Откройте файл и установите.

## RuStore

Пошаговая публикация: `Safe-code/docs/RUSTORE_PUBLISH.md`

**Важно:** эта сборка подписана debug-ключом (облачная CI-сборка). Перед публичным релизом в RuStore создайте release keystore и пересоберите:

```bash
bash scripts/generate-rustore-keystore.sh
bash scripts/build-rustore-release.sh
```

## Реклама

Сборка **1.2.1+5** собрана с боевыми блоками Яндекс РСЯ (rewarded + interstitial).
