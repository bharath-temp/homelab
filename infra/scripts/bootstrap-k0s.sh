#!/usr/bin/env bash
# This script is added into the butane file as inline
set -euo 
if command -v k0s >/dev/null 2>&1; then
  exit 0

curl -sSLf https://get.k0s
k0s install controller --single
k0s start
