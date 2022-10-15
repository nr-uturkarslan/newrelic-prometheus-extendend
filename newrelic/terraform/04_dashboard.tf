##################
### Dashboards ###
##################

# Raw dashboard - Kubernetes Prometheus
resource "newrelic_one_dashboard_raw" "kubernetes_prometheus" {
  name = "Kubernetes Monitoring with Prometheus"

  # Cluster Overview
  page {
    name = "Cluster Overview"

    # Kubernetes Resources
    widget {
      title  = "Kubernetes Resources"
      row    = 1
      column = 1
      height = 4
      width  = 2
      visualization_id = "viz.billboard"
      configuration = jsonencode(
      {
        "nrqlQueries": [
          {
            "accountId": var.NEW_RELIC_ACCOUNT_ID,
            "query": "FROM Metric SELECT uniqueCount(pod), uniqueCount(deployment), uniqueCount(daemonset), uniqueCount(service), uniqueCount(statefulset) WHERE instrumentation.provider = 'prometheus' AND prometheus_server = '${var.prometheus_server_name}' LIMIT MAX"
          }
        ]
      })
    }

    # Node Capacities
    widget {
      title  = "Node Capacities"
      row    = 1
      column = 3
      height = 4
      width  = 4
      visualization_id = "viz.table"
      configuration = jsonencode(
      {
        "nrqlQueries": [
          {
            "accountId": var.NEW_RELIC_ACCOUNT_ID,
            "query": "FROM Metric SELECT max(machine_cpu_cores) AS 'CPU (cores)', max(machine_memory_bytes)/1024/1024/1024 AS 'MEM (GB)' WHERE instrumentation.provider = 'prometheus' AND prometheus_server = '${var.prometheus_server_name}' FACET instance"
          }
        ]
      })
    }

    # Available Deployments
    widget {
      title  = "Available"
      row    = 1
      column = 7
      height = 2
      width  = 2
      visualization_id = "viz.billboard"
      configuration = jsonencode(
      {
        "nrqlQueries": [
          {
            "accountId": var.NEW_RELIC_ACCOUNT_ID,
            "query": "FROM (FROM Metric SELECT latest(kube_deployment_status_replicas_available) AS `num_replicas` WHERE instrumentation.provider = 'prometheus' AND prometheus_server = '${var.prometheus_server_name}' FACET deployment) SELECT sum(`num_replicas`) AS 'Deployment Replicas'"
          }
        ]
      })
    }

    # Unavailable Deployments
    widget {
      title  = "Unavailable"
      row    = 2
      column = 7
      height = 2
      width  = 2
      visualization_id = "viz.billboard"
      configuration = jsonencode(
      {
        "nrqlQueries": [
          {
            "accountId": var.NEW_RELIC_ACCOUNT_ID,
            "query": "FROM (FROM Metric SELECT latest(kube_deployment_status_replicas_unavailable) AS `num_replicas` WHERE instrumentation.provider = 'prometheus' AND prometheus_server = '${var.prometheus_server_name}' FACET deployment) SELECT sum(`num_replicas`) AS 'Deployment Replicas'"
          }
        ]
      })
    }

    # Available DaemonSets
    widget {
      title  = "Available"
      row    = 1
      column = 9
      height = 2
      width  = 2
      visualization_id = "viz.billboard"
      configuration = jsonencode(
      {
        "nrqlQueries": [
          {
            "accountId": var.NEW_RELIC_ACCOUNT_ID,
            "query": "FROM (FROM Metric SELECT latest(kube_daemonset_status_number_available) AS `num_replicas` WHERE instrumentation.provider = 'prometheus' AND prometheus_server = '${var.prometheus_server_name}' FACET daemonset) SELECT sum(`num_replicas`) AS 'DaemonSet Replicas'"
          }
        ]
      })
    }

    # Unavailable DaemonSets
    widget {
      title  = "Unavailable"
      row    = 2
      column = 9
      height = 2
      width  = 2
      visualization_id = "viz.billboard"
      configuration = jsonencode(
      {
        "nrqlQueries": [
          {
            "accountId": var.NEW_RELIC_ACCOUNT_ID,
            "query": "FROM (FROM Metric SELECT latest(kube_daemonset_status_number_unavailable) AS `num_replicas` WHERE instrumentation.provider = 'prometheus' AND prometheus_server = '${var.prometheus_server_name}' FACET daemonset) SELECT sum(`num_replicas`) AS 'DaemonSets Replicas'"
          }
        ]
      })
    }

    # Available StatefulSets
    widget {
      title  = "Available"
      row    = 1
      column = 11
      height = 2
      width  = 2
      visualization_id = "viz.billboard"
      configuration = jsonencode(
      {
        "nrqlQueries": [
          {
            "accountId": var.NEW_RELIC_ACCOUNT_ID,
            "query": "FROM (FROM Metric SELECT latest(kube_statefulset_status_replicas_available) AS `num_replicas` WHERE instrumentation.provider = 'prometheus' AND prometheus_server = '${var.prometheus_server_name}' FACET daemonset) SELECT sum(`num_replicas`) AS 'StatefulSet Replicas'"
          }
        ]
      })
    }

    # Unavailable StatefulSets
    widget {
      title  = "Unavailable"
      row    = 2
      column = 11
      height = 2
      width  = 2
      visualization_id = "viz.billboard"
      configuration = jsonencode(
      {
        "nrqlQueries": [
          {
            "accountId": var.NEW_RELIC_ACCOUNT_ID,
            "query": "FROM (FROM Metric SELECT latest(kube_statefulset_status_replicas_unavailable) AS `num_replicas` WHERE instrumentation.provider = 'prometheus' AND prometheus_server = '${var.prometheus_server_name}' FACET daemonset) SELECT sum(`num_replicas`) AS 'StatefulSet Replicas'"
          }
        ]
      })
    }

    # Node CPU Usage
    widget {
      title  = "Node CPU Utilization (%)"
      row    = 3
      column = 1
      width  = 4
      visualization_id = "viz.line"
      configuration = jsonencode(
      {
        "nrqlQueries": [
          {
            "accountId": var.NEW_RELIC_ACCOUNT_ID,
            "query": "SELECT 100-average((`idle_usage` * 100)) AS 'CPU Utilization (%)' FROM (SELECT irate(node_cpu_seconds_total, 1 SECONDS) AS `idle_usage` FROM Metric WHERE instrumentation.provider = 'prometheus' AND prometheus_server = '${var.prometheus_server_name}' AND mode = 'idle' FACET dimensions() LIMIT MAX TIMESERIES 5 minutes SLIDE BY 10 seconds) FACET node LIMIT MAX TIMESERIES 5 minutes"
          }
        ]
      })
    }

    # Node MEM Usage
    widget {
      title  = "Node MEM Utilization (%)"
      row    = 3
      column = 5
      width  = 4
      visualization_id = "viz.line"
      configuration = jsonencode(
      {
        "nrqlQueries": [
          {
            "accountId": var.NEW_RELIC_ACCOUNT_ID,
            "query": "SELECT (100 * (1 - ((average(node_memory_MemFree_bytes) + average(node_memory_Cached_bytes) + average(node_memory_Buffers_bytes)) / average(node_memory_MemTotal_bytes)))) FROM Metric WHERE instrumentation.provider = 'prometheus' AND prometheus_server = '${var.prometheus_server_name}' FACET node LIMIT 100 TIMESERIES 5 minutes SLIDE BY 10 seconds"
          }
        ]
      })
    }

    # Node STO Usage
    widget {
      title  = "Node STO Utilization (%)"
      row    = 3
      column = 9
      width  = 4
      visualization_id = "viz.line"
      configuration = jsonencode(
      {
        "nrqlQueries": [
          {
            "accountId": var.NEW_RELIC_ACCOUNT_ID,
            "query": "SELECT (1 - (average(node_filesystem_avail_bytes) / average(node_filesystem_size_bytes))) * 100 FROM Metric WHERE instrumentation.provider = 'prometheus' AND prometheus_server = '${var.prometheus_server_name}' FACET node TIMESERIES"
          }
        ]
      })
    }
  }

  # Node Overview (nodes)
  page {
    name = "Node Overview (nodes)"

    # Nodes
    widget {
      title  = "Nodes"
      row    = 1
      column = 1
      height = 4
      width  = 3
      visualization_id = "viz.table"
      configuration = jsonencode(
      {
        "nrqlQueries": [
          {
            "accountId": var.NEW_RELIC_ACCOUNT_ID,
            "query": "FROM Metric SELECT uniques(instance) WHERE instrumentation.provider = 'prometheus' AND prometheus_server = '${var.prometheus_server_name}' AND job = 'kubernetes-nodes'"
          }
        ]
      })
    }

    # Node to Pod Map
    widget {
      title  = "Node to Pod Map"
      row    = 1
      column = 4
      height = 4
      width  = 4
      visualization_id = "viz.table"
      configuration = jsonencode(
      {
        "nrqlQueries": [
          {
            "accountId": var.NEW_RELIC_ACCOUNT_ID,
            "query": "FROM Metric SELECT uniques(concat(instance, ' -> ', pod)) AS `Node -> Pod` WHERE instrumentation.provider = 'prometheus' AND prometheus_server = '${var.prometheus_server_name}' AND job = 'kubernetes-nodes' AND pod IS NOT NULL"
          }
        ]
      })
    }

    # Num Pods by Nodes
    widget {
      title  = "Num Pods by Nodes"
      row    = 1
      column = 8
      height = 4
      width  = 5
      visualization_id = "viz.line"
      configuration = jsonencode(
      {
        "nrqlQueries": [
          {
            "accountId": var.NEW_RELIC_ACCOUNT_ID,
            "query": "FROM Metric SELECT uniqueCount(pod) WHERE instrumentation.provider = 'prometheus' AND prometheus_server = '${var.prometheus_server_name}' AND job = 'kubernetes-nodes' AND pod IS NOT NULL FACET instance TIMESERIES AUTO"
          }
        ]
      })
    }
  }

  # Node Overview (node exporter)
  page {
    name = "Node Overview (node exporter)"

    # Node CPU Usage (mCPU)
    widget {
      title  = "Node CPU Usage (mCPU)"
      row    = 1
      column = 1
      width  = 6
      visualization_id = "viz.area"
      configuration = jsonencode(
      {
        "nrqlQueries": [
          {
            "accountId": var.NEW_RELIC_ACCOUNT_ID,
            "query": "SELECT 1000*(average(`system`)+average(`user`)+average(`softirq`)+average(`iowait`)+average(`steal`)+average(`irq`)+average(`nice`)) AS 'CPU Usage (mCPU)' FROM (SELECT filter(irate(node_cpu_seconds_total, 1 SECONDS), WHERE mode = 'system') AS `system`, filter(irate(node_cpu_seconds_total, 1 SECONDS), WHERE mode = 'user') AS `user`, filter(irate(node_cpu_seconds_total, 1 SECONDS), WHERE mode = 'softirq') AS `softirq`, filter(irate(node_cpu_seconds_total, 1 SECONDS), WHERE mode = 'iowait') AS `iowait`, filter(irate(node_cpu_seconds_total, 1 SECONDS), WHERE mode = 'steal') AS `steal`, filter(irate(node_cpu_seconds_total, 1 SECONDS), WHERE mode = 'irq') AS `irq`, filter(irate(node_cpu_seconds_total, 1 SECONDS), WHERE mode = 'nice') AS `nice` FROM Metric WHERE instrumentation.provider = 'prometheus' AND prometheus_server = '${var.prometheus_server_name}' AND component = 'node-exporter' FACET dimensions() LIMIT MAX TIMESERIES 5 minutes SLIDE BY 10 seconds) FACET node LIMIT MAX TIMESERIES AUTO"
          }
        ]
      })
    }

    # Node CPU Utilization (%)
    widget {
      title  = "Node CPU Utilization (%)"
      row    = 1
      column = 7
      width  = 6
      visualization_id = "viz.line"
      configuration = jsonencode(
      {
        "nrqlQueries": [
          {
            "accountId": var.NEW_RELIC_ACCOUNT_ID,
            "query": "SELECT 1-average(`idle_usage`) AS 'CPU Usage (mCPU)' FROM (SELECT irate(node_cpu_seconds_total, 1 SECONDS) AS `idle_usage` FROM Metric WHERE instrumentation.provider = 'prometheus' AND prometheus_server = '${var.prometheus_server_name}' AND component = 'node-exporter' AND mode = 'idle' FACET dimensions() LIMIT MAX TIMESERIES 5 minutes SLIDE BY 10 seconds) FACET node LIMIT MAX TIMESERIES AUTO"
          }
        ]
      })
    }

    # Node MEM Usage (GB)
    widget {
      title  = "Node MEM Usage (GB)"
      row    = 2
      column = 1
      width  = 6
      visualization_id = "viz.area"
      configuration = jsonencode(
      {
        "nrqlQueries": [
          {
            "accountId": var.NEW_RELIC_ACCOUNT_ID,
            "query": "SELECT average(node_memory_MemTotal_bytes) - (average(node_memory_MemFree_bytes) + average(node_memory_Cached_bytes) + average(node_memory_Buffers_bytes)) FROM Metric WHERE instrumentation.provider = 'prometheus' AND prometheus_server = '${var.prometheus_server_name}' AND component = 'node-exporter' FACET node LIMIT 100 TIMESERIES AUTO"
          }
        ]
      })
    }

    # Node MEM Utilization (%)
    widget {
      title  = "Node MEM Utilization (%)"
      row    = 2
      column = 7
      width  = 6
      visualization_id = "viz.line"
      configuration = jsonencode(
      {
        "nrqlQueries": [
          {
            "accountId": var.NEW_RELIC_ACCOUNT_ID,
            "query": "SELECT (100 * (1 - ((average(node_memory_MemFree_bytes) + average(node_memory_Cached_bytes) + average(node_memory_Buffers_bytes)) / average(node_memory_MemTotal_bytes)))) FROM Metric WHERE instrumentation.provider = 'prometheus' AND prometheus_server = '${var.prometheus_server_name}' AND component = 'node-exporter' FACET node TIMESERIES AUTO"
          }
        ]
      })
    }

    # Node STO Usage (GB)
    widget {
      title  = "Node STO Usage (GB)"
      row    = 3
      column = 1
      width  = 6
      visualization_id = "viz.area"
      configuration = jsonencode(
      {
        "nrqlQueries": [
          {
            "accountId": var.NEW_RELIC_ACCOUNT_ID,
            "query": "SELECT average(node_filesystem_avail_bytes) FROM Metric WHERE instrumentation.provider = 'prometheus' AND prometheus_server = '${var.prometheus_server_name}' AND component = 'node-exporter' FACET node TIMESERIES AUTO"
          }
        ]
      })
    }

    # Node STO Utilization (%)
    widget {
      title  = "Node STO Utilization (%)"
      row    = 3
      column = 7
      width  = 6
      visualization_id = "viz.line"
      configuration = jsonencode(
      {
        "nrqlQueries": [
          {
            "accountId": var.NEW_RELIC_ACCOUNT_ID,
            "query": "SELECT (1 - (average(node_filesystem_avail_bytes) / average(node_filesystem_size_bytes))) * 100 FROM Metric WHERE instrumentation.provider = 'prometheus' AND prometheus_server = '${var.prometheus_server_name}' AND component = 'node-exporter' FACET node TIMESERIES"
          }
        ]
      })
    }
  }

  # Container Overview (cadvisor + ksm)
  page {
    name = "Container Overview (cadvisor + ksm)"

    # Container CPU Usage (mCPU)
    widget {
      title  = "Container CPU Usage (mCPU)"
      row    = 1
      column = 1
      width  = 6
      visualization_id = "viz.area"
      configuration = jsonencode(
      {
        "nrqlQueries": [
          {
            "accountId": var.NEW_RELIC_ACCOUNT_ID,
            "query": "FROM (FROM Metric SELECT rate(average(container_cpu_usage_seconds_total), 1 second)*1000 AS `usage` WHERE instrumentation.provider = 'prometheus' AND prometheus_server = '${var.prometheus_server_name}' AND job = 'kubernetes-nodes-cadvisor' FACET container TIMESERIES 5 minutes SLIDE BY 10 seconds) SELECT average(`usage`) FACET container TIMESERIES AUTO"
          }
        ]
      })
    }

    # Container CPU Utilization (%)
    widget {
      title  = "Container CPU Utilization (%)"
      row    = 1
      column = 7
      width  = 6
      visualization_id = "viz.line"
      configuration = jsonencode(
      {
        "nrqlQueries": [
          {
            "accountId": var.NEW_RELIC_ACCOUNT_ID,
            "query": "FROM (FROM Metric SELECT rate(average(container_cpu_usage_seconds_total), 1 second)*1000 AS `usage`, filter(average(kube_pod_container_resource_limits)*1000, WHERE resource = 'cpu') AS `limit` WHERE instrumentation.provider = 'prometheus' AND prometheus_server = '${var.prometheus_server_name}' AND (job = 'kubernetes-nodes-cadvisor' OR service = 'prometheus-kube-state-metrics') FACET container TIMESERIES 5 minutes SLIDE BY 10 seconds) SELECT average(`usage`)/average(`limit`)*100 FACET container TIMESERIES AUTO"
          }
        ]
      })
    }

    # Container MEM Usage (GB)
    widget {
      title  = "Container MEM Usage (GB)"
      row    = 2
      column = 1
      width  = 6
      visualization_id = "viz.area"
      configuration = jsonencode(
      {
        "nrqlQueries": [
          {
            "accountId": var.NEW_RELIC_ACCOUNT_ID,
            "query": "FROM (FROM Metric SELECT average(container_memory_usage_bytes) AS `usage` WHERE instrumentation.provider = 'prometheus' AND prometheus_server = '${var.prometheus_server_name}' AND job = 'kubernetes-nodes-cadvisor' FACET container TIMESERIES 5 minutes SLIDE BY 10 seconds) SELECT average(`usage`) FACET container TIMESERIES AUTO"
          }
        ]
      })
    }

    # Container MEM Utilization (%)
    widget {
      title  = "Container MEM Utilization (%)"
      row    = 2
      column = 7
      width  = 6
      visualization_id = "viz.line"
      configuration = jsonencode(
      {
        "nrqlQueries": [
          {
            "accountId": var.NEW_RELIC_ACCOUNT_ID,
            "query": "FROM (FROM Metric SELECT average(container_memory_usage_bytes) AS `usage`, filter(average(kube_pod_container_resource_limits), WHERE resource = 'memory') AS `limit` WHERE instrumentation.provider = 'prometheus' AND prometheus_server = '${var.prometheus_server_name}' AND (job = 'kubernetes-nodes-cadvisor' OR service = 'prometheus-kube-state-metrics') FACET container TIMESERIES 5 minutes SLIDE BY 10 seconds) SELECT average(`usage`)/average(`limit`)*100 FACET container TIMESERIES AUTO"
          }
        ]
      })
    }

    # Container File System Read Rate (1/s)
    widget {
      title  = "Container File System Read Rate (1/s)"
      row    = 3
      column = 1
      width  = 6
      visualization_id = "viz.area"
      configuration = jsonencode(
      {
        "nrqlQueries": [
          {
            "accountId": var.NEW_RELIC_ACCOUNT_ID,
            "query": "FROM (FROM Metric SELECT rate(average(container_fs_reads_total), 1 SECOND) AS `rate` WHERE instrumentation.provider = 'prometheus' AND prometheus_server = '${var.prometheus_server_name}' AND job = 'kubernetes-nodes-cadvisor' FACET container TIMESERIES 5 minutes SLIDE BY 10 seconds) SELECT average(`rate`) FACET container TIMESERIES AUTO"
          }
        ]
      })
    }

    # Container File System Write Rate (1/s)
    widget {
      title  = "Container File System Write Rate (1/s)"
      row    = 3
      column = 7
      width  = 6
      visualization_id = "viz.area"
      configuration = jsonencode(
      {
        "nrqlQueries": [
          {
            "accountId": var.NEW_RELIC_ACCOUNT_ID,
            "query": "FROM (FROM Metric SELECT rate(average(container_fs_writes_total), 1 SECOND) AS `rate` WHERE instrumentation.provider = 'prometheus' AND prometheus_server = '${var.prometheus_server_name}' AND job = 'kubernetes-nodes-cadvisor' FACET container TIMESERIES 5 minutes SLIDE BY 10 seconds) SELECT average(`rate`) FACET container TIMESERIES AUTO"
          }
        ]
      })
    }

    # Container Network Receive Rate (MB/s)
    widget {
      title  = "Container Network Receive Rate (MB/s)"
      row    = 4
      column = 1
      width  = 6
      visualization_id = "viz.area"
      configuration = jsonencode(
      {
        "nrqlQueries": [
          {
            "accountId": var.NEW_RELIC_ACCOUNT_ID,
            "query": "FROM (FROM Metric SELECT rate(average(container_network_receive_bytes_total)/1024/1024, 1 SECOND) AS `rate` WHERE instrumentation.provider = 'prometheus' AND prometheus_server = 'mydopecluster' AND job = 'kubernetes-nodes-cadvisor' FACET container TIMESERIES 5 minutes SLIDE BY 10 seconds) SELECT average(`rate`) FACET container TIMESERIES AUTO"
          }
        ]
      })
    }

    # Container Network Transmit Rate (MB/s)
    widget {
      title  = "Container Network Transmit Rate (MB/s)"
      row    = 4
      column = 7
      width  = 6
      visualization_id = "viz.area"
      configuration = jsonencode(
      {
        "nrqlQueries": [
          {
            "accountId": var.NEW_RELIC_ACCOUNT_ID,
            "query": "FROM (FROM Metric SELECT rate(average(container_network_transmit_bytes_total)/1024/1024, 1 SECOND) AS `rate` WHERE instrumentation.provider = 'prometheus' AND prometheus_server = 'mydopecluster' AND job = 'kubernetes-nodes-cadvisor' FACET container TIMESERIES 5 minutes SLIDE BY 10 seconds) SELECT average(`rate`) FACET container TIMESERIES AUTO"
          }
        ]
      })
    }
  }

  # Container Overview (ksm)
  page {
    name = "Container Overview (ksm)"

    # Containers
    widget {
      title  = "Containers"
      row    = 1
      column = 1
      height = 4
      width  = 3
      visualization_id = "viz.table"
      configuration = jsonencode(
      {
        "nrqlQueries": [
          {
            "accountId": var.NEW_RELIC_ACCOUNT_ID,
            "query": "FROM Metric SELECT uniques(container) WHERE instrumentation.provider = 'prometheus' AND prometheus_server = '${var.prometheus_server_name}'"
          }
        ]
      })
    }

    # Pod (Ready)
    widget {
      title  = "Pod (Ready)"
      row    = 1
      column = 4
      height = 2
      width  = 2
      visualization_id = "viz.billboard"
      configuration = jsonencode(
      {
        "nrqlQueries": [
          {
            "accountId": var.NEW_RELIC_ACCOUNT_ID,
            "query": "FROM (FROM Metric SELECT latest(kube_pod_status_ready) AS `num_ready` WHERE instrumentation.provider = 'prometheus' AND prometheus_server = '${var.prometheus_server_name}' FACET pod) SELECT sum(`num_ready`)"
          }
        ]
      })
    }
    # Pod (Scheduled)
    widget {
      title  = "Pod (Scheduled)"
      row    = 1
      column = 4
      height = 2
      width  = 2
      visualization_id = "viz.billboard"
      configuration = jsonencode(
      {
        "nrqlQueries": [
          {
            "accountId": var.NEW_RELIC_ACCOUNT_ID,
            "query": "FROM (FROM Metric SELECT latest(kube_pod_status_scheduled) AS `num_scheduled` WHERE instrumentation.provider = 'prometheus' AND prometheus_server = '${var.prometheus_server_name}' FACET pod) SELECT sum(`num_scheduled`)"
          }
        ]
      })
    }

    # Container Restarts
    widget {
      title  = "Container Restarts"
      row    = 1
      column = 4
      height = 2
      width  = 2
      visualization_id = "viz.billboard"
      configuration = jsonencode(
      {
        "nrqlQueries": [
          {
            "accountId": var.NEW_RELIC_ACCOUNT_ID,
            "query": "FROM (FROM Metric SELECT average(kube_pod_container_status_restarts_total) AS `num_restarts` WHERE instrumentation.provider = 'prometheus' AND prometheus_server = '${var.prometheus_server_name}' FACET container) SELECT sum(`num_restarts`)"
          }
        ]
      })
    }
  }
}
