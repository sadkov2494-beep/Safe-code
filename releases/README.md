# Release builds — Safe Code / Код Сейфа

Сборки для RuStore и прямой установки на Android.

## Файлы

| Файл | Размер | Назначение |
|------|--------|------------|
| `safe-code-release.apk` | ~60 MB | Установка вручную или загрузка в RuStore |
| `safe-code-release.aab` | ~61 MB | App Bundle для RuStore (если требуется) |

## Версия

- **1.2.2** (versionCode **6**)
- Package: `com.safecode.safe_code`
- Yandex Ads: demo blocks (облачная сборка)

## SHA256

- APK: `be6eb751b859c98a78f774c9c39e8f79525a0b398e185b969af2991ab7a26538`

## Скачать

- APK: https://github.com/sadkov2494-beep/Safe-code/raw/cursor/diverse-level-logic-b62e/releases/safe-code-release.apk

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
