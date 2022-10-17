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

# Update Helm dependencies
# helm dependency update "../charts/prometheus"

# Install / upgrade Helm deployment
helm upgrade prometheus \
  --install \
  --wait \
  --debug \
  --create-namespace \
  --namespace $namespacePrometheus \
  --set kubeStateMetrics.enabled=true \
  --set nodeExporter.enabled=true \
  --set nodeExporter.tolerations[0].effect="NoSchedule" \
  --set nodeExporter.tolerations[0].operator="Exists" \
  --set newrelic.scrape_case="nodes_and_namespaces" \
  --set server.remoteWrite[0].url=$newrelicPrometheusEndpointEu \
  --set server.remoteWrite[0].bearer_token=$NEWRELIC_LICENSE_KEY \
  "../charts/prometheus"
