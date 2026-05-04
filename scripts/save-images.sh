#!/usr/bin/env bash
# ---------------------------------------------------------------
# save-images.sh
#
# Run this on a machine WITH internet access.
# It pulls all monitoring images, builds the custom Grafana image,
# and saves everything as .tar files in ./monitoring-images/
#
# Usage:
#   cd iot-agent-monitoring
#   ./scripts/save-images.sh
#
# Then copy the monitoring-images/ folder to the target machine.
# ---------------------------------------------------------------
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
OUT_DIR="${1:-$REPO_DIR/monitoring-images}"

mkdir -p "$OUT_DIR"

IMAGES=(
  "quay.io/prometheus/prometheus:v3.2.1"
  "quay.io/prometheus/alertmanager:v0.28.1"
  "quay.io/prometheus-operator/prometheus-operator:v0.82.0"
  "quay.io/prometheus-operator/prometheus-config-reloader:v0.82.0"
  "quay.io/kiwigrid/k8s-sidecar:1.30.3"
  "quay.io/prometheus/node-exporter:v1.9.0"
  "registry.k8s.io/kube-state-metrics/kube-state-metrics:v2.15.0"
  "docker.io/grafana/loki:3.4.2"
  "docker.io/grafana/promtail:3.4.2"
)

echo "=== Pulling upstream images ==="
for img in "${IMAGES[@]}"; do
  echo "Pulling $img ..."
  docker pull "$img"

  ARCHIVE="$OUT_DIR/$(echo "$img" | tr '/:' '__').tar"
  echo "Saving  -> $ARCHIVE"
  docker save -o "$ARCHIVE" "$img"
done

echo ""
echo "=== Building custom Grafana image ==="
docker build -f "$REPO_DIR/Dockerfile" -t iot-agent-grafana:latest "$REPO_DIR"
ARCHIVE="$OUT_DIR/iot-agent-grafana__latest.tar"
echo "Saving  -> $ARCHIVE"
docker save -o "$ARCHIVE" iot-agent-grafana:latest

echo ""
echo "=== Done ==="
echo "All images saved to: $OUT_DIR"
ls -lh "$OUT_DIR"
echo ""
echo "Copy this folder to the target machine, then run:"
echo "  ./scripts/load-images.sh $OUT_DIR"
