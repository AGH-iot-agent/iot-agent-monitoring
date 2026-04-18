FROM grafana/grafana:11.5.0

# Bake in dashboard provisioning config and dashboard JSONs.
# Datasources are provisioned by kube-prometheus-stack via additionalDataSources.
COPY grafana/provisioning/dashboards /etc/grafana/provisioning/dashboards
COPY grafana/dashboards              /var/lib/grafana/dashboards
