#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT_DIR"

if [ -f local.env ]; then
  set -a
  # shellcheck disable=SC1091
  source local.env
  set +a
fi

FLUTTER_CMD="${1:-run}"
shift || true

flutter "$FLUTTER_CMD" "$@" \
  --dart-define=SAFE_CODE_YANDEX_REWARDED_HINT_ID="${SAFE_CODE_YANDEX_REWARDED_HINT_ID:-demo-rewarded-yandex}" \
  --dart-define=SAFE_CODE_YANDEX_REWARDED_ATTEMPT_ID="${SAFE_CODE_YANDEX_REWARDED_ATTEMPT_ID:-demo-rewarded-yandex}" \
  --dart-define=SAFE_CODE_YANDEX_REWARDED_SKIP_ID="${SAFE_CODE_YANDEX_REWARDED_SKIP_ID:-demo-rewarded-yandex}" \
  --dart-define=SAFE_CODE_YANDEX_INTERSTITIAL_ID="${SAFE_CODE_YANDEX_INTERSTITIAL_ID:-demo-interstitial-yandex}"
