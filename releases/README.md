# Release builds — Safe Code / Код Сейфа

Сборки для RuStore и прямой установки на Android.

## Файлы

| Файл | Размер | Назначение |
|------|--------|------------|
| `safe-code-release.apk` | ~60 MB | Установка вручную или загрузка в RuStore |
| `safe-code-release.aab` | ~61 MB | App Bundle для RuStore (если требуется) |

## Версия

- **1.2.3** (versionCode **7**)
- Package: `com.safecode.safe_code`
- Yandex Ads: demo blocks (облачная сборка)

## SHA256

- APK: `01c4bfd5ecdf3430efffde3ecb7fe72243cf0ac0e27380163be379330b273e75`

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
