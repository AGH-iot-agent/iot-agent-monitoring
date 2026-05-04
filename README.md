# iot-agent-monitoring

Centralny stack observability dla platformy IoT Agent.

## Single source of truth

Konfiguracje monitoringu zostaly scalone w jednym module:
- Kubernetes/Helm: `Helm/` oraz `k8s/`
- Docker Compose local: `docker/`

Dzieki temu iot-agent-monitoring jest jedynym miejscem utrzymania konfiguracji monitoringu.

## Zakres

- kube-prometheus-stack (Prometheus + Alertmanager + Grafana)
- Loki + Promtail
- ServiceMonitor dla uslug aplikacyjnych
- Dashboardy Grafana dla iot-agent-logs i SLO uslug

## Szybki start

```bash
cd iot-agent-monitoring
chmod +x scripts/install-monitoring.sh
./scripts/install-monitoring.sh dev
```

## Docker Compose (local)

Lokalny docker-compose z glownego repo korzysta z konfiguracji:
- `docker/prometheus/prometheus.yml`
- `docker/loki/loki-config.yml`
- `docker/promtail/promtail-config.yml`
- `docker/grafana/provisioning/**`

Weryfikacja:

```bash
kubectl -n iotag-monitoring get pods
kubectl -n iotag-monitoring get servicemonitors
```

## Namespace

Stack jest instalowany w dedykowanym namespace: `iotag-monitoring`.
Scrape obejmuje namespace aplikacyjne:
- `iotag-dev`
- `iotag-sbx`

## Port metryk aplikacji

Dla uslug Spring metryki sa wystawiane na:
- `GET /actuator/prometheus`
- port service: `9090` (nazwa portu `metrics`)

## Kolejne kroki

- Dodać ServiceMonitor dla pozostalych uslug (gateway, device-api, alert-api, stream-worker).
- Dodać PrometheusRule dla error-rate i latency.
- Podpiac SSO do Grafany i rozdzielic role read/write.
