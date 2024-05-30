# monitoring-from-makefile
Данное решение позволяет установить инструменты для мониторинга:
- Grafana Loki - агрегация логов
- Loki Promtail - агент для сбора логов
- Grafana - средство визуализации логов и метрик
- Prometheus - агрегация метрик
- Prometheus_node_exporter - агент для сбора системных метрик

## Использование
### Установка всех компонентов
Запустите установку всех компонентов с помощью команды:
```sh
$ sudo make -f makefile
```
### Установка конкретных компонентов
Установка Grafana Promtail
```sh
$ sudo make -f makefile install_promtail
```
Установка Grafana Loki
```sh
$ sudo make -f makefile install_loki
```
Установка Grafana
```sh
$ sudo make -f makefile install_grafana
```
Установка Prometheus_node_exporter
```sh
$ sudo make -f makefile install_node_exporter
```
Установка Prometheus
```sh
$ sudo make -f makefile install_prometheus
```
Удаление загруженных архивов
```sh
$ sudo make -f makefile clean
```

