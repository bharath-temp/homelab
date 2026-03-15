#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 <butane-file>"
  echo "Example: $0 bootstrap/butane/node0.bu"
  exit 1
fi

BUTANE_FILE="$1"

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

FILE_NAME="$(basename "$BUTANE_FILE" .bu)"
OUTPUT_FILE="${REPO_ROOT}/bootstrap/ignition/${FILE_NAME}.ign"

docker run --rm \
  -v "${REPO_ROOT}:/work" \
  -w /work \
  quay.io/coreos/butane:release \
  --pretty --strict \
  --files-dir . \
  "$BUTANE_FILE" \
  > "$OUTPUT_FILE"

echo "Ignition generated: $OUTPUT_FILE"
