#!/usr/bin/env bash
set -euo pipefail

if command -v k0s >/dev/null 2>&1; then
  exit 0
fi

curl --proto '=https' --tlsv1.2 -sSf https://get.k0s.sh | sudo sh

k0s config create > /etc/k0s/k0s.yaml

tmpfile="$(mktemp /etc/k0s/k0s.yaml.XXXXXX)"

podman run --rm \
            --security-opt label=disable \
            -v /etc/k0s:/workdir \
            docker.io/mikefarah/yq:4 \
            '
              .spec.network.provider = "custom" |
              .spec.network.kubeProxy.disabled = true
            ' /workdir/k0s.yaml > "${tmpfile}"

          mv "${tmpfile}" /etc/k0s/k0s.yaml

k0s install controller --enable-worker --no-taints --token-file /var/lib/k0s/tokens/controller-token -c /etc/k0s/k0s.yaml --start
