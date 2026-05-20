#!/usr/bin/env bash
set -euo pipefail

PROJECT_DIR="${PROJECT_DIR:-Safe-code}"

cd "$PROJECT_DIR"

flutter pub get

flutter build apk --release \
  --dart-define=SAFE_CODE_YANDEX_REWARDED_HINT_ID="${SAFE_CODE_YANDEX_REWARDED_HINT_ID:-demo-rewarded-yandex}" \
  --dart-define=SAFE_CODE_YANDEX_REWARDED_ATTEMPT_ID="${SAFE_CODE_YANDEX_REWARDED_ATTEMPT_ID:-demo-rewarded-yandex}" \
  --dart-define=SAFE_CODE_YANDEX_REWARDED_SKIP_ID="${SAFE_CODE_YANDEX_REWARDED_SKIP_ID:-demo-rewarded-yandex}" \
  --dart-define=SAFE_CODE_YANDEX_INTERSTITIAL_ID="${SAFE_CODE_YANDEX_INTERSTITIAL_ID:-demo-interstitial-yandex}"

flutter build appbundle --release \
  --dart-define=SAFE_CODE_YANDEX_REWARDED_HINT_ID="${SAFE_CODE_YANDEX_REWARDED_HINT_ID:-demo-rewarded-yandex}" \
  --dart-define=SAFE_CODE_YANDEX_REWARDED_ATTEMPT_ID="${SAFE_CODE_YANDEX_REWARDED_ATTEMPT_ID:-demo-rewarded-yandex}" \
  --dart-define=SAFE_CODE_YANDEX_REWARDED_SKIP_ID="${SAFE_CODE_YANDEX_REWARDED_SKIP_ID:-demo-rewarded-yandex}" \
  --dart-define=SAFE_CODE_YANDEX_INTERSTITIAL_ID="${SAFE_CODE_YANDEX_INTERSTITIAL_ID:-demo-interstitial-yandex}"
