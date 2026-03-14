#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

docker run --rm \
  -v "${REPO_ROOT}:/work" \
  -w /work \
  quay.io/coreos/butane:release \
  --pretty --strict \
  --files-dir . \
  infra/butane/node0.bu \
  > "${REPO_ROOT}/infra/ignition/node0.ign"

echo "Ignition generated: infra/ignition/node0.ign"
