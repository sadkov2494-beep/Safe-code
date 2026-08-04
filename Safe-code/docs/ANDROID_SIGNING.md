# Android signing for Safe Code

## Проблема «нужно удалить старое приложение»

Android не позволяет обновить APK, если **подпись** нового файла не совпадает с установленным приложением.
Раньше облачные сборки подписывались **разными debug-ключами** на каждой машине — поэтому
установка поверх старой версии не работала.

## Решение (с версии 1.2.4+8)

В репозитории лежит общий CI-keystore:

- `android/keystores/safe-code-ci-upload.jks`
- `android/ci-key.properties`

Все release-сборки из этого репозитория подписываются **одним и тем же ключом**.
Новые APK можно ставить поверх предыдущих без удаления.

### Однократная переустановка

Если у вас уже стоит сборка **1.2.3 или ниже** с облачной debug-подписью,
последний раз придётся удалить её вручную и поставить **1.2.4+**.
Дальше обновления будут накатываться поверх.

## Локальный release keystore (RuStore)

Для публикации в RuStore со **своим** ключом:

1. `bash scripts/generate-rustore-keystore.sh`
2. Создайте `android/key.properties` (см. скрипт)
3. `bash scripts/build-rustore-release.sh`

Файл `key.properties` имеет приоритет над `ci-key.properties`.
**Не меняйте** release keystore после первой публикации в магазине.

## Пароли CI-keystore (только для sideload-сборок)

| Поле | Значение |
|------|----------|
| storeFile | `keystores/safe-code-ci-upload.jks` |
| keyAlias | `safe-code-ci` |
| storePassword | `safecode-ci-upload` |
| keyPassword | `safecode-ci-upload` |

Этот ключ предназначен для тестовых APK из GitHub, а не для защиты коммерческого релиза.
