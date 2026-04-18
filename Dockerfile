FROM grafana/grafana:11.5.0

COPY grafana/provisioning/dashboards /etc/grafana/provisioning/dashboards
COPY grafana/dashboards              /var/lib/grafana/dashboards
