# Release builds — Safe Code / Код Сейфа

Сборки для RuStore и прямой установки на Android.

## Файлы

| Файл | Размер | Назначение |
|------|--------|------------|
| `safe-code-release.apk` | ~60 MB | Установка вручную или загрузка в RuStore |
| `safe-code-release.aab` | ~61 MB | App Bundle для RuStore (если требуется) |

## Версия

- **1.2.0** (versionCode **4**)
- Package: `com.safecode.safe_code`

## SHA256

- APK: `e82e5923fc2814befb0d7e3735de2599e0a5872871a4520f1feae1f4c50498fe`
- AAB: `425ce697a1be6e14daa6faa424346796f561082f0cef95b0a38049e58ff90318`

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

По умолчанию — Yandex demo ID. Для продакшена задайте R-M ID через `Safe-code/local.env` (см. `docs/YANDEX_ADS_SETUP.md`).
