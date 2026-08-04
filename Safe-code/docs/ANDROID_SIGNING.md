# Android signing for Safe Code

## RuStore: важно, если первая версия уже выложена

**Да, будет конфликт**, если первая версия в RuStore подписана **другим ключом**, чем новая сборка.

| Канал | Какой ключ нужен |
|-------|------------------|
| **RuStore** (обновления в магазине) | **Тот же keystore**, которым подписана первая версия в RuStore |
| **GitHub APK** (установка вручную) | CI-keystore из репозитория (`ci-key.properties`) |

Это **два разных канала** с разными подписями:

- Пользователь, установивший игру **из RuStore**, получает обновления **только из RuStore**, подписанные **вашим RuStore-ключом**.
- APK с GitHub (CI-подпись) **не установится поверх** RuStore-версии без удаления — и наоборот.

### Что делать для обновления в RuStore

1. Найдите `.jks`, которым подписывали первую версию (из `generate-rustore-keystore.sh`).
2. Создайте `Safe-code/android/key.properties` (см. `scripts/generate-rustore-keystore.sh`).
3. Соберите релиз:
   ```bash
   bash scripts/build-rustore-release.sh
   ```
4. Загрузите **AAB или APK** в RuStore Console с увеличенным `versionCode` в `pubspec.yaml`.

`key.properties` имеет **приоритет** над `ci-key.properties` — сборка автоматически подпишется RuStore-ключом.

**Никогда не меняйте** RuStore keystore после первой публикации — магазин не примет обновление.

---

## Проблема «нужно удалить старое приложение» (GitHub APK)

Android не позволяет обновить APK, если подпись нового файла не совпадает с установленным приложением.
Раньше облачные сборки подписывались **разными debug-ключами** — установка поверх не работала.

### Решение для GitHub-сборок (с версии 1.2.4+8)

- `android/keystores/safe-code-ci-upload.jks`
- `android/ci-key.properties`

Все GitHub APK из этого репозитория подписаны **одним CI-ключом** — их можно ставить поверх друг друга без удаления.

Если сейчас стоит старая debug-сборка — удалите её **один раз** и поставьте 1.2.4+.

---

## Пароли CI-keystore (только GitHub / sideload)

| Поле | Значение |
|------|----------|
| storeFile | `keystores/safe-code-ci-upload.jks` |
| keyAlias | `safe-code-ci` |
| storePassword | `safecode-ci-upload` |
| keyPassword | `safecode-ci-upload` |

Не используйте CI-ключ для RuStore, если первая версия уже подписана своим release-ключом.
