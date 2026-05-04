#!/usr/bin/env bash
# ---------------------------------------------------------------
# load-images.sh
#
# Run this on the TARGET machine (weak PC with k3s).
# Loads all .tar files from monitoring-images/ into k3s containerd.
#
# Usage:
#   cd iot-agent-monitoring
#   ./scripts/load-images.sh              # default: ./monitoring-images/
#   ./scripts/load-images.sh /path/to/dir # custom path
# ---------------------------------------------------------------
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
IMG_DIR="${1:-$REPO_DIR/monitoring-images}"

if [[ ! -d "$IMG_DIR" ]]; then
  echo "ERROR: Directory not found: $IMG_DIR"
  echo "Run save-images.sh first on a machine with internet access."
  exit 1
fi

SUDO=""
command -v sudo >/dev/null && SUDO="sudo"

K3S_SOCK="/run/k3s/containerd/containerd.sock"

import_image() {
  local archive="$1"
  if command -v k3s >/dev/null 2>&1; then
    $SUDO k3s ctr images import "$archive"
  elif command -v ctr >/dev/null 2>&1 && [[ -S "$K3S_SOCK" ]]; then
    $SUDO ctr --address "$K3S_SOCK" -n k8s.io images import "$archive"
  elif [[ -x /usr/local/bin/k3s ]]; then
    $SUDO /usr/local/bin/k3s ctr images import "$archive"
  else
    echo "ERROR: Neither k3s nor ctr found. Cannot import."
    exit 1
  fi
}

echo "=== Loading images from $IMG_DIR into k3s ==="
FAILED=0
for tar_file in "$IMG_DIR"/*.tar; do
  [[ -f "$tar_file" ]] || continue
  echo "Importing $(basename "$tar_file") ..."
  if import_image "$tar_file"; then
    echo "  OK"
  else
    echo "  FAILED"
    FAILED=$((FAILED + 1))
  fi
done

if [[ "$FAILED" -gt 0 ]]; then
  echo ""
  echo "WARNING: $FAILED image(s) failed to import."
  exit 1
fi

echo ""
echo "=== All images imported into k3s ==="
echo "You can now deploy monitoring:"
echo "  ./scripts/install-monitoring.sh dev"
