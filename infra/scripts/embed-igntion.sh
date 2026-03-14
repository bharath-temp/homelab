#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
ISO_SRC="${HOME}/Downloads/fedora-coreos-43.20260217.3.1-live-iso.x86_64.iso"
ISO_DST="${REPO_ROOT}/infra/isos/fcos-node0.iso"

cp "${ISO_SRC}" "${ISO_DST}"

docker run --rm \
  -v "${REPO_ROOT}:/work" \
  -w /work \
  quay.io/coreos/coreos-installer:release \
  iso ignition embed \
  -i infra/ignition/node0.ign \
  infra/isos/fcos-node0.iso

echo "FCOS ISO generated with embedded ignition: infra/ignition/fcos-node0.iso"