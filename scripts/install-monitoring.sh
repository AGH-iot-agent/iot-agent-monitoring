#!/usr/bin/env bash
set -euo pipefail

ENVIRONMENT="${1:-dev}"
MON_NS="iotag-monitoring"

case "$ENVIRONMENT" in
  dev)
    KPS_VALUES="Helm/kube-prometheus-stack-dev.yaml"
    LOKI_VALUES="Helm/loki-dev.yaml"
    PROMTAIL_VALUES="Helm/promtail-dev.yaml"
    ;;
  sbx)
    KPS_VALUES="Helm/kube-prometheus-stack-sbx.yaml"
    LOKI_VALUES="Helm/loki-sbx.yaml"
    PROMTAIL_VALUES="Helm/promtail-sbx.yaml"
    ;;
  *)
    echo "Unsupported environment: $ENVIRONMENT (allowed: dev|sbx)"
    exit 1
    ;;
esac

helm repo add prometheus-community https://prometheus-community.github.io/helm-charts >/dev/null 2>&1 || true
helm repo add grafana https://grafana.github.io/helm-charts >/dev/null 2>&1 || true
helm repo update >/dev/null

helm upgrade --install iot-agent-monitoring prometheus-community/kube-prometheus-stack \
  -n "$MON_NS" --create-namespace \
  -f "$KPS_VALUES" \
  --wait --timeout 20m

helm upgrade --install iot-agent-loki grafana/loki \
  -n "$MON_NS" \
  -f "$LOKI_VALUES" \
  --wait --timeout 20m

helm upgrade --install iot-agent-promtail grafana/promtail \
  -n "$MON_NS" \
  -f "$PROMTAIL_VALUES" \
  --wait --timeout 20m

SM_FILE="k8s/servicemonitors/iot-platform-${ENVIRONMENT}.yaml"
[[ -f "$SM_FILE" ]] && kubectl apply -f "$SM_FILE" || echo "WARN: $SM_FILE not found, skipping"

echo "Monitoring installed for environment profile: $ENVIRONMENT"
echo "Namespace: $MON_NS"
