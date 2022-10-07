#!/bin/bash

#################
### App Setup ###
#################

### Set variables

# Cluster name
clusterName="mydopecluster"

# Namespace where to install Prometheus
namespacePrometheus="monitoring"

# New Relic Prometheus endpoint
newrelicPrometheusEndpointUs="https://metric-api.newrelic.com/prometheus/v1/write?prometheus_server=${clusterName}"
newrelicPrometheusEndpointEu="https://metric-api.eu.newrelic.com/prometheus/v1/write?prometheus_server=${clusterName}"

### Prometheus ###
helm dependency update "../charts/prometheus"

## Example
# - Create ClusterRole and ClusterRoleBinding
# - Install kube-state-metrics and node-exporter additionally
# - Scrape everything
# - Send data to 1 New Relic account
helm upgrade prometheus \
  --install \
  --wait \
  --debug \
  --create-namespace \
  --namespace $namespacePrometheus \
  --set server.remoteWrite[0].url=$newrelicPrometheusEndpointEu \
  --set server.remoteWrite[0].bearer_token=$NEWRELIC_LICENSE_KEY \
  "../charts/prometheus"

## Example
# - Create Role and RoleBinding
# - Scrape only services, endpoints and pods
# - Filter scraped data by 2 specific namespaces
# - Send filtered data from 2 namespaces to 2 New Relic accounts
# helm upgrade prometheus \
#   --install \
#   --wait \
#   --debug \
#   --create-namespace \
#   --namespace $namespacePrometheus \
#   --set server.remoteWrite[0].url="${newrelicPrometheusEndpointEu}namespace1" \
#   --set server.remoteWrite[0].bearer_token=$NEWRELIC_LICENSE_KEY_1 \
#   --set server.remoteWrite[0].write_relabel_configs[0].source_labels[0]="namespace" \
#   --set server.remoteWrite[0].write_relabel_configs[0].regex=$namespaceBravo \
#   --set server.remoteWrite[0].write_relabel_configs[0].action="keep" \
#   --set server.remoteWrite[1].url="${newrelicPrometheusEndpointEu}namespace2" \
#   --set server.remoteWrite[1].bearer_token=$NEWRELIC_LICENSE_KEY_2 \
#   --set server.remoteWrite[1].write_relabel_configs[0].source_labels[0]="namespace" \
#   --set server.remoteWrite[1].write_relabel_configs[0].regex=$namespaceCharlie \
#   --set server.remoteWrite[1].write_relabel_configs[0].action="keep" \
#   "../charts/prometheus"
