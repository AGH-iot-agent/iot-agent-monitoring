FROM grafana/grafana:11.5.0

COPY grafana/provisioning/dashboards /etc/grafana/provisioning/dashboards
COPY grafana/provisioning/datasources /etc/grafana/provisioning/datasources

