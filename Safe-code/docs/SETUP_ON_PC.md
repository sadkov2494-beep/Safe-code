# Как скачать проект на свой компьютер

Облачный агент **не может** напрямую скопировать папку на ваш ПК. Проект лежит на GitHub — скачайте его одним из способов ниже.

## Способ 1: Git (удобно для обновлений)

Нужен [Git](https://git-scm.com/downloads) и [Flutter](https://docs.flutter.dev/get-started/install).

```bash
git clone https://github.com/sadkov2494-beep/Safe-code.git
cd Safe-code
git checkout cursor/safe-code-flutter-mvp-3784
cd Safe-code
flutter pub get
flutter run
```

Обновление позже:

```bash
git pull origin cursor/safe-code-flutter-mvp-3784
flutter pub get
```

## Способ 2: ZIP без Git

1. Откройте: https://github.com/sadkov2494-beep/Safe-code/tree/cursor/safe-code-flutter-mvp-3784  
2. Кнопка **Code** → **Download ZIP**.  
3. Распакуйте архив.  
4. В терминале зайдите в папку `Safe-code/Safe-code` (внутри репозитория) и выполните `flutter pub get`.

## Только поиграть без Flutter

Скачайте готовый APK (Android):

https://github.com/sadkov2494-beep/Safe-code/raw/cursor/safe-code-flutter-mvp-3784/releases/safe-code-release.apk

Установите на телефон (разрешите установку из неизвестных источников).

## Windows: что установить

1. **Flutter SDK** — https://docs.flutter.dev/get-started/install/windows  
2. **Android Studio** (Android SDK + эмулятор) — https://developer.android.com/studio  
3. Проверка: `flutter doctor`

Запуск на подключённом телефоне или эмуляторе:

```bash
cd Safe-code
flutter devices
flutter run
```

## Вставить свои R-M ID от Яндекса

1. Скопируйте шаблон:

   ```bash
   cd Safe-code
   cp local.env.example local.env
   ```

2. Откройте `local.env` в блокноте и замените `demo-...` на ваши `R-M-...` из РСЯ.

3. Сборка с вашими ID:

   ```bash
   bash ../scripts/build-rustore-release.sh
   ```

   Или запуск на телефоне:

   ```bash
   bash scripts/run-with-yandex-ids.sh run
   ```

Можно также прислать R-M ID агенту в чат — он подготовит содержимое `local.env`, а вы вставите его у себя после клонирования.

## Структура папок

```
Safe-code/                 ← корень git-репозитория
├── Safe-code/             ← Flutter-проект игры (сюда заходить для flutter run)
├── scripts/
├── releases/              ← готовые APK/AAB
└── ...
```
