# Публикация Safe Code в RuStore

Пошаговая инструкция для первой выкладки игры.

## 1. Скачайте сборку

Файлы лежат в папке `releases/` репозитория:

| Файл | Назначение |
|------|------------|
| `safe-code-release.apk` | Прямая установка и загрузка в RuStore (APK) |
| `safe-code-release.aab` | Загрузка в RuStore, если консоль просит App Bundle |

Прямые ссылки (ветка `cursor/safe-code-flutter-mvp-3784`):

- APK: https://github.com/sadkov2494-beep/Safe-code/raw/cursor/safe-code-flutter-mvp-3784/releases/safe-code-release.apk
- AAB: https://github.com/sadkov2494-beep/Safe-code/raw/cursor/safe-code-flutter-mvp-3784/releases/safe-code-release.aab

**SHA256 APK (сборка 1.2.0+4):** `e82e5923fc2814befb0d7e3735de2599e0a5872871a4520f1feae1f4c50498fe`

## 2. Release-подпись (обязательно перед продакшеном)

Текущая облачная сборка подписана **debug-ключом** — подходит для проверки на телефоне и теста в RuStore, но для публичного релиза нужен **свой release keystore**.

На своём компьютере:

```bash
bash scripts/generate-rustore-keystore.sh
```

Создайте `Safe-code/android/key.properties` (см. скрипт) и пересоберите:

```bash
bash scripts/build-rustore-release.sh
```

**Сохраните `.jks` и пароли навсегда** — без них RuStore не примет обновления.

## 3. Yandex Ads (если уже есть R-M ID)

```bash
cd Safe-code
cp local.env.example local.env
# вставьте 4 R-M ID
cd ..
bash scripts/build-rustore-release.sh
```

Без своих ID используются демо-блоки Яндекса (`demo-rewarded-yandex`).

## 4. RuStore Console — регистрация

1. Откройте https://console.rustore.ru/
2. Войдите через VK ID / Сбер ID / др.
3. Пройдите **верификацию разработчика** (физлицо, ИП или юрлицо).
4. Примите оферту RuStore.

## 5. Создание карточки приложения

1. **Мои приложения** → **Добавить приложение**.
2. Заполните поля (готовые тексты — в `store_assets/RUSTORE_LISTING.ru.md`):

| Поле | Значение |
|------|----------|
| Название | Код Сейфа |
| Package name | `com.safecode.safe_code` |
| Категория | Игры → Головоломки |
| Возраст | 12+ (логика, без насилия) |
| Реклама | Да (Yandex Mobile Ads) |
| Email поддержки | ваш email |

3. **Иконка:** `Safe-code/assets/icon/safe-code-app-icon.png` (512×512).
4. **Скриншоты:** минимум 2–4 с телефона (меню, сейф, победа, коллекция).
5. **Промо-баннер** (если нужен): `Safe-code/store_assets/safe-code-feature-graphic.png`.
6. **Политика конфиденциальности:** опубликуйте текст из `docs/PRIVACY_POLICY_DRAFT.md` на GitHub Pages / сайте и укажите URL.

## 6. Загрузка сборки

1. В карточке приложения → **Версии** → **Загрузить версию**.
2. Выберите **APK** (`safe-code-release.apk`) или **AAB**, если консоль требует bundle.
3. Укажите:
   - версия: **1.2.0**
   - код версии (versionCode): **4**
4. Добавьте **release notes** (что нового) — см. `store_assets/RUSTORE_LISTING.ru.md`.
5. Отправьте на **модерацию**.

Модерация обычно занимает от нескольких часов до нескольких рабочих дней.

## 7. После одобрения

- Проверьте карточку в RuStore на телефоне с установленным магазином.
- Установите игру с RuStore и проверьте рекламу (если подключены боевые R-M).
- Для обновлений: увеличьте `version:` в `pubspec.yaml` (например `1.2.1+5`), пересоберите **тем же keystore**, загрузите новую версию.

## Частые отклонения модерации

| Причина | Решение |
|---------|---------|
| Нет политики конфиденциальности | Опубликовать URL |
| Debug-подпись | Пересобрать с release keystore |
| Несовпадение package name | Должен быть `com.safecode.safe_code` |
| Нет скриншотов | Добавить реальные скрины с устройства |
| Реклама не указана | Отметить «содержит рекламу» |

## Связанные файлы

- `docs/RUSTORE_RELEASE_CHECKLIST.md` — технический чеклист
- `docs/YANDEX_ADS_SETUP.md` — реклама Яндекс
- `store_assets/RUSTORE_LISTING.ru.md` — тексты для карточки
