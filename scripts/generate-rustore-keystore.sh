#!/usr/bin/env bash
set -euo pipefail

KEYSTORE_PATH="${1:-safe-code-upload-keystore.jks}"
ALIAS="${2:-safe-code-upload}"

echo "Создаём release keystore для RuStore: $KEYSTORE_PATH"
echo "Сохраните пароли — без них нельзя обновлять приложение в магазине."
echo

keytool -genkeypair \
  -v \
  -keystore "$KEYSTORE_PATH" \
  -alias "$ALIAS" \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10000

cat <<EOF

Готово. Создайте файл Safe-code/android/key.properties:

storePassword=ВАШ_STORE_PASSWORD
keyPassword=ВАШ_KEY_PASSWORD
keyAlias=$ALIAS
storeFile=$(cd "$(dirname "$KEYSTORE_PATH")" && pwd)/$(basename "$KEYSTORE_PATH")

Затем соберите релиз:
  bash scripts/build-rustore-release.sh

Не добавляйте .jks и key.properties в git.
EOF
