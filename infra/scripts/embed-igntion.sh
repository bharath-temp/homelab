#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 <ignition-file>"
  echo "Example: $0 infra/ignition/node0.ign"
  exit 1
fi

IGN_FILE="$1"

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

FILE_NAME="$(basename "$IGN_FILE" .ign)"

ISO_SRC="${HOME}/Downloads/fedora-coreos-43.20260217.3.1-live-iso.x86_64.iso"
ISO_DST="${REPO_ROOT}/infra/isos/fcos-${FILE_NAME}.iso"

cp "${ISO_SRC}" "${ISO_DST}"

docker run --rm \
  -v "${REPO_ROOT}:/work" \
  -w /work \
  quay.io/coreos/coreos-installer:release \
  iso ignition embed \
  -i "$IGN_FILE" \
  "infra/isos/fcos-${FILE_NAME}.iso"

echo "FCOS ISO generated with embedded ignition: infra/isos/fcos-${FILE_NAME}.iso"
