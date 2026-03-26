#!/usr/bin/env bash
set -euo pipefail

if command -v k0s >/dev/null 2>&1; then
  exit 0
fi

curl --proto '=https' --tlsv1.2 -sSf https://get.k0s.sh | sh

k0s install worker --token-file /var/lib/k0s/tokens/worker-token --start
