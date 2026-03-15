#!/usr/bin/env bash
set -euo pipefail

if command -v k0s >/dev/null 2>&1; then
  exit 0
fi

curl --proto '=https' --tlsv1.2 -sSf https://get.k0s.sh | sudo sh

k0s config create > /etc/k0s/k0s.yaml
k0s install controller --enable-worker --no-taints --token-file /var/lib/k0s/tokens/controller-token -c /etc/k0s/k0s.yaml --start
