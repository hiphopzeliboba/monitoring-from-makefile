# Define versions
PROMTAIL_VERSION := 2.9.4
LOKI_VERSION := 2.9.4
GRAFANA_VERSION := 11.0.0
NODE_EXPORTER_VERSION := 1.8.1
PROMETHEUS_VERSION := 2.45.5

# Define URLs
PROMTAIL_URL := https://github.com/grafana/loki/releases/download/v$(PROMTAIL_VERSION)/promtail-linux-amd64.zip
LOKI_URL := https://github.com/grafana/loki/releases/download/v$(LOKI_VERSION)/loki-linux-amd64.zip
GRAFANA_URL := https://dl.grafana.com/oss/release/grafana-$(GRAFANA_VERSION).linux-amd64.tar.gz
NODE_EXPORTER_URL := https://github.com/prometheus/node_exporter/releases/download/v$(NODE_EXPORTER_VERSION)/node_exporter-$(NODE_EXPORTER_VERSION).linux-amd64.tar.gz
PROMETHEUS_URL := https://github.com/prometheus/prometheus/releases/download/v$(PROMETHEUS_VERSION)/prometheus-$(PROMETHEUS_VERSION).linux-amd64.tar.gz

# Define install directories
PROMTAIL_DIR := /usr/local/promtail
LOKI_DIR := /usr/local/loki
GRAFANA_DIR := /usr/local/grafana
NODE_EXPORTER_DIR := /usr/local/node_exporter
PROMETHEUS_DIR := /usr/local/prometheus

all: install_promtail install_loki install_grafana install_node_exporter install_prometheus clean

install_promtail:

	@echo "Installing Promtail..."
	wget $(PROMTAIL_URL)
	unzip promtail-linux-amd64.zip
	sudo mkdir $(PROMTAIL_DIR)
	sudo mv promtail-linux-amd64 $(PROMTAIL_DIR)
	sudo chmod a+x $(PROMTAIL_DIR)/promtail-linux-amd64
	sudo wget https://raw.githubusercontent.com/grafana/loki/v$(PROMTAIL_VERSION)/clients/cmd/promtail/promtail-local-config.yaml
	sudo mv promtail-local-config.yaml $(PROMTAIL_DIR)
	sudo touch /etc/systemd/system/promtail.service

	echo "[Unit]\n\
	Description=Promtail Service\n\
	After=network.target\n\
	[Service]\n\
	User=nobody\n\
	ExecStart=$(PROMTAIL_DIR)/promtail-linux-amd64 -config.file=$(PROMTAIL_DIR)/promtail-local-config.yaml\n\
	Restart=on-failure\n\
	[Install]\n\
	WantedBy=multi-user.target" | sudo tee /etc/systemd/system/promtail.service > /dev/null
	
	sudo systemctl daemon-reload
	sudo systemctl start promtail
	sudo systemctl enable promtail

install_loki:

	@echo "Installing Loki..."
	wget $(LOKI_URL)
	unzip loki-linux-amd64.zip
	sudo mkdir $(LOKI_DIR)
	sudo mv loki-linux-amd64 $(LOKI_DIR)
	sudo chmod a+x $(LOKI_DIR)/loki-linux-amd64
	sudo wget https://raw.githubusercontent.com/grafana/loki/v$(LOKI_VERSION)/cmd/loki/loki-local-config.yaml
	sudo mv loki-local-config.yaml $(LOKI_DIR)
	sudo touch /etc/systemd/system/loki.service

	echo "[Unit]\n\
	Description=Loki Service\n\
	After=network.target\n\
	[Service]\n\
	User=nobody\n\
	ExecStart=$(LOKI_DIR)/loki-linux-amd64 -config.file=$(LOKI_DIR)/loki-local-config.yaml\n\
	Restart=on-failure\n\
	[Install]\n\
	WantedBy=multi-user.target" | sudo tee /etc/systemd/system/loki.service > /dev/null

	sudo systemctl daemon-reload
	sudo systemctl start loki
	sudo systemctl enable loki

install_grafana:

	@echo "Installing Grafana..."
	wget $(GRAFANA_URL)
	tar -zxvf grafana-$(GRAFANA_VERSION).linux-amd64.tar.gz
	sudo mv grafana-v$(GRAFANA_VERSION) $(GRAFANA_DIR)
	
	sudo touch /etc/systemd/system/grafana.service

	echo "[Unit]\n\
	Description=Grafana Service\n\
	Wants=network-online.target\n\
	After=network.target\n\
	\n\
	[Service]\n\
	ExecStart=$(GRAFANA_DIR)/bin/grafana-server --config=$(GRAFANA_DIR)/conf/defaults.ini --homepath=$(GRAFANA_DIR)\n\
	\n\
	[Install]\n\
	WantedBy=multi-user.target" | sudo tee /etc/systemd/system/grafana.service > /dev/null

	sudo systemctl daemon-reload
	sudo systemctl enable grafana
	sudo systemctl start grafana

install_node_exporter:

	@echo "Installing Node_exporter..."
	wget $(NODE_EXPORTER_URL)
	tar -zxvf node_exporter-$(NODE_EXPORTER_VERSION).linux-amd64.tar.gz
	sudo mv node_exporter-$(NODE_EXPORTER_VERSION).linux-amd64 $(NODE_EXPORTER_DIR)
	sudo touch /etc/systemd/system/node_exporter.service

	echo "[Unit]\n\
	Description=Node Exporter\n\
	Wants=network-online.target\n\
	After=network-online.target\n\
	[Service]\n\
	User=nobody\n\
	Type=simple\n\
	ExecStart=$(NODE_EXPORTER_DIR)/node_exporter\n\
	[Install]\n\
	WantedBy=multi-user.target" | sudo tee /etc/systemd/system/node_exporter.service > /dev/null

	sudo systemctl daemon-reload
	sudo systemctl start node_exporter
	sudo systemctl enable node_exporter

install_prometheus:

	@echo "Installing Prometheus..."
	wget $(PROMETHEUS_URL)
	tar -zxvf prometheus-$(PROMETHEUS_VERSION).linux-amd64.tar.gz
	sudo mv prometheus-$(PROMETHEUS_VERSION).linux-amd64 $(PROMETHEUS_DIR)
	sudo touch /etc/systemd/system/prometheus.service

	echo "[Unit]\n\
	Description=Prometheus\n\
	Wants=network-online.target\n\
	After=network.target\n\
	[Service]\n\
	Type=simple\n\
	ExecStart=$(PROMETHEUS_DIR)/prometheus --config.file=$(PROMETHEUS_DIR)/prometheus.yml\n\
	[Install]\n\
	WantedBy=multi-user.target" | sudo tee /etc/systemd/system/prometheus.service > /dev/null

	sudo systemctl daemon-reload
	sudo systemctl start prometheus
	sudo systemctl enable prometheus

clean:

	rm -f grafana-$(GRAFANA_VERSION).linux-amd64.tar.gz
	rm -f promtail-linux-amd64.zip
	rm -f loki-linux-amd64.zip
	rm -f node_exporter-$(NODE_EXPORTER_VERSION).linux-amd64.tar.gz
	rm -f prometheus-$(PROMETHEUS_VERSION).linux-amd64.tar.gz
