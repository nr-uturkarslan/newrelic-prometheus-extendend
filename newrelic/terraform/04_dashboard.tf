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

  #####################
  ### NODE OVERVIEW ###
  #####################
  page {
    name = "Node Overview"

    # Page Description
    widget {
      title  = "Page Description"
      row    = 1
      column = 1
      height = 2
      width  = 4
      visualization_id = "viz.markdown"
      configuration = jsonencode(
      {
        "text": "## Node Overview\nTo be able to visualize every widget properly, Prometheus should be able to scrape the following resources:\n- Nodes Endpoints\n- Node Exporter\n- Kube State Metrics"
      })
    }

    # Node Capacities
    widget {
      title  = "Node Capacities"
      row    = 2
      column = 1
      height = 3
      width  = 4
      visualization_id = "viz.table"
      configuration = jsonencode(
      {
        "nrqlQueries": [
          {
            "accountId": var.NEW_RELIC_ACCOUNT_ID,
            "query": "FROM Metric SELECT max(machine_cpu_cores) AS 'CPU (cores)', max(machine_memory_bytes)/1024/1024/1024 AS 'MEM (GB)' WHERE instrumentation.provider = 'prometheus' AND prometheus_server = '${var.prometheus_server_name}' AND job = 'kubernetes-nodes-cadvisor' FACET instance"
          }
        ]
      })
    }

    # Node to Pod Map
    widget {
      title  = "Node to Pod Map"
      row    = 1
      column = 5
      height = 5
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

    # Num Namespaces by Nodes
    widget {
      title  = "Num Namespaces by Nodes"
      row    = 1
      column = 9
      height = 2
      width  = 4
      visualization_id = "viz.line"
      configuration = jsonencode(
      {
        "nrqlQueries": [
          {
            "accountId": var.NEW_RELIC_ACCOUNT_ID,
            "query": "FROM Metric SELECT uniqueCount(namespace) WHERE instrumentation.provider = 'prometheus' AND prometheus_server = '${var.prometheus_server_name}' AND job = 'kubernetes-nodes' AND pod IS NOT NULL FACET instance TIMESERIES AUTO"
          }
        ]
      })
    }

    # Num Pods by Nodes
    widget {
      title  = "Num Pods by Nodes"
      row    = 2
      column = 9
      height = 3
      width  = 4
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

    # Node CPU Usage (mCPU)
    widget {
      title  = "Node CPU Usage (mCPU)"
      row    = 3
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
      row    = 3
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
      row    = 4
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
      row    = 4
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
      row    = 5
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
      row    = 5
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

  ##########################
  ### NAMESPACE OVERVIEW ###
  ##########################
  page {
    name = "Namespace Overview"

    # Page Description
    widget {
      title  = "Page Description"
      row    = 1
      column = 1
      height = 2
      width  = 4
      visualization_id = "viz.markdown"
      configuration = jsonencode(
      {
        "text": "## Namespace Overview\nTo be able to visualize every widget properly, Prometheus should be able to scrape the following resources:\n- Node cAdvisor\n- Kube State Metrics"
      })
    }

    # Namespaces
    widget {
      title  = "Namespaces"
      row    = 1
      column = 5
      height = 2
      width  = 2
      visualization_id = "viz.table"
      configuration = jsonencode(
      {
        "nrqlQueries": [
          {
            "accountId": var.NEW_RELIC_ACCOUNT_ID,
            "query": "FROM Metric SELECT uniques(namespace) WHERE instrumentation.provider = 'prometheus' AND prometheus_server = '${var.prometheus_server_name}' AND job = 'kubernetes-nodes'"
          }
        ]
      })
    }

    # Deployments in Namespaces
    widget {
      title  = "Deployments in Namespaces"
      row    = 1
      column = 7
      height = 2
      width  = 2
      visualization_id = "viz.bar"
      configuration = jsonencode(
      {
        "nrqlQueries": [
          {
            "accountId": var.NEW_RELIC_ACCOUNT_ID,
            "query": "FROM Metric SELECT uniqueCount(deployment) OR 0 WHERE instrumentation.provider = 'prometheus' AND prometheus_server = '${var.prometheus_server_name}' AND service = 'prometheus-kube-state-metrics' FACET namespace"
          }
        ]
      })
    }

    # DaemonSets in Namespaces
    widget {
      title  = "DaemonSets in Namespaces"
      row    = 1
      column = 9
      height = 2
      width  = 2
      visualization_id = "viz.bar"
      configuration = jsonencode(
      {
        "nrqlQueries": [
          {
            "accountId": var.NEW_RELIC_ACCOUNT_ID,
            "query": "FROM Metric SELECT uniqueCount(daemonset) OR 0 WHERE instrumentation.provider = 'prometheus' AND prometheus_server = '${var.prometheus_server_name}' AND service = 'prometheus-kube-state-metrics' FACET namespace"
          }
        ]
      })
    }

    # StatefulSets in Namespaces
    widget {
      title  = "StatefulSets in Namespaces"
      row    = 1
      column = 11
      height = 2
      width  = 2
      visualization_id = "viz.bar"
      configuration = jsonencode(
      {
        "nrqlQueries": [
          {
            "accountId": var.NEW_RELIC_ACCOUNT_ID,
            "query": "FROM Metric SELECT uniqueCount(statefulset) OR 0 WHERE instrumentation.provider = 'prometheus' AND prometheus_server = '${var.prometheus_server_name}' AND service = 'prometheus-kube-state-metrics' FACET namespace"
          }
        ]
      })
    }

    # Pods in Namespaces (Running)
    widget {
      title  = "Pods in Namespaces (Running)"
      row    = 3
      column = 1
      height = 3
      width  = 3
      visualization_id = "viz.bar"
      configuration = jsonencode(
      {
        "nrqlQueries": [
          {
            "accountId": var.NEW_RELIC_ACCOUNT_ID,
            "query": "FROM (FROM Metric SELECT latest(kube_pod_status_phase) AS `running` WHERE instrumentation.provider = 'prometheus' AND prometheus_server = '${var.prometheus_server_name}' AND service = 'prometheus-kube-state-metrics' AND phase = 'Running' FACET namespace, pod LIMIT MAX) SELECT sum(`running`) FACET namespace"
          }
        ]
      })
    }

    # Pods in Namespaces (Pending)
    widget {
      title  = "Pods in Namespaces (Pending)"
      row    = 3
      column = 4
      height = 3
      width  = 3
      visualization_id = "viz.bar"
      configuration = jsonencode(
      {
        "nrqlQueries": [
          {
            "accountId": var.NEW_RELIC_ACCOUNT_ID,
            "query": "FROM (FROM Metric SELECT latest(kube_pod_status_phase) AS `pending` WHERE instrumentation.provider = 'prometheus' AND prometheus_server = '${var.prometheus_server_name}' AND service = 'prometheus-kube-state-metrics' AND phase = 'Pending' FACET namespace, pod LIMIT MAX) SELECT sum(`pending`) FACET namespace"
          }
        ]
      })
    }

    # Pods in Namespaces (Failed)
    widget {
      title  = "Pods in Namespaces (Failed)"
      row    = 3
      column = 7
      height = 3
      width  = 3
      visualization_id = "viz.bar"
      configuration = jsonencode(
      {
        "nrqlQueries": [
          {
            "accountId": var.NEW_RELIC_ACCOUNT_ID,
            "query": "FROM (FROM Metric SELECT latest(kube_pod_status_phase) AS `failed` WHERE instrumentation.provider = 'prometheus' AND prometheus_server = '${var.prometheus_server_name}' AND service = 'prometheus-kube-state-metrics' AND phase = 'Failed' FACET namespace, pod LIMIT MAX) SELECT sum(`failed`) FACET namespace"
          }
        ]
      })
    }

    # Pods in Namespaces (Unknown)
    widget {
      title  = "Pods in Namespaces (Unknown)"
      row    = 3
      column = 10
      height = 3
      width  = 3
      visualization_id = "viz.bar"
      configuration = jsonencode(
      {
        "nrqlQueries": [
          {
            "accountId": var.NEW_RELIC_ACCOUNT_ID,
            "query": "FROM (FROM Metric SELECT latest(kube_pod_status_phase) AS `unknown` WHERE instrumentation.provider = 'prometheus' AND prometheus_server = '${var.prometheus_server_name}' AND service = 'prometheus-kube-state-metrics' AND phase = 'Unknown' FACET namespace, pod LIMIT MAX) SELECT sum(`unknown`) FACET namespace"
          }
        ]
      })
    }
  }

  ####################
  ### POD OVERVIEW ###
  ####################
  page {
    name = "Pod Overview"

    # Page Description
    widget {
      title  = "Page Description"
      row    = 1
      column = 1
      height = 2
      width  = 4
      visualization_id = "viz.markdown"
      configuration = jsonencode(
      {
        "text": "## Pod Overview\nTo be able to visualize every widget properly, Prometheus should be able to scrape the following resources:\n- Node cAdvisor\n- Kube State Metrics"
      })
    }

    # Containers
    widget {
      title  = "Containers"
      row    = 1
      column = 5
      height = 4
      width  = 4
      visualization_id = "viz.table"
      configuration = jsonencode(
      {
        "nrqlQueries": [
          {
            "accountId": var.NEW_RELIC_ACCOUNT_ID,
            "query": "FROM Metric SELECT uniques(container) WHERE instrumentation.provider = 'prometheus' AND prometheus_server = '${var.prometheus_server_name}' AND job = 'kubernetes-nodes-cadvisor'"
          }
        ]
      })
    }

    # Container (Ready)
    widget {
      title  = "Container (Ready)"
      row    = 3
      column = 1
      height = 2
      width  = 2
      visualization_id = "viz.billboard"
      configuration = jsonencode(
      {
        "nrqlQueries": [
          {
            "accountId": var.NEW_RELIC_ACCOUNT_ID,
            "query": "FROM (FROM Metric SELECT latest(kube_pod_container_status_ready) AS `ready` WHERE instrumentation.provider = 'prometheus' AND prometheus_server = '${var.prometheus_server_name}' AND service = 'prometheus-kube-state-metrics' FACET container LIMIT MAX) SELECT sum(`ready`)"
          }
        ]
      })
    }

    # Container (Waiting)
    widget {
      title  = "Container (Waiting)"
      row    = 3
      column = 3
      height = 2
      width  = 2
      visualization_id = "viz.billboard"
      configuration = jsonencode(
      {
        "nrqlQueries": [
          {
            "accountId": var.NEW_RELIC_ACCOUNT_ID,
            "query": "FROM (FROM Metric SELECT latest(kube_pod_container_status_waiting) AS `waiting` WHERE instrumentation.provider = 'prometheus' AND prometheus_server = '${var.prometheus_server_name}' AND service = 'prometheus-kube-state-metrics' FACET container LIMIT MAX) SELECT sum(`waiting`)"
          }
        ]
      })
    }

    # Pod (Running)
    widget {
      title  = "Pod (Running)"
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
            "query": "FROM (FROM Metric SELECT latest(kube_pod_status_phase) AS `running` WHERE instrumentation.provider = 'prometheus' AND prometheus_server = '${var.prometheus_server_name}' AND service = 'prometheus-kube-state-metrics' AND phase = 'Running' FACET pod LIMIT MAX) SELECT sum(`running`)"
          }
        ]
      })
    }

    # Pod (Pending)
    widget {
      title  = "Pod (Pending)"
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
            "query": "FROM (FROM Metric SELECT latest(kube_pod_status_phase) AS `pending` WHERE instrumentation.provider = 'prometheus' AND prometheus_server = '${var.prometheus_server_name}' AND service = 'prometheus-kube-state-metrics' AND phase = 'Pending' FACET pod LIMIT MAX) SELECT sum(`pending`)"
          }
        ]
      })
    }

    # Pod (Failed)
    widget {
      title  = "Pod (Failed)"
      row    = 3
      column = 9
      height = 2
      width  = 2
      visualization_id = "viz.billboard"
      configuration = jsonencode(
      {
        "nrqlQueries": [
          {
            "accountId": var.NEW_RELIC_ACCOUNT_ID,
            "query": "FROM (FROM Metric SELECT latest(kube_pod_status_phase) AS `failed` WHERE instrumentation.provider = 'prometheus' AND prometheus_server = '${var.prometheus_server_name}' AND service = 'prometheus-kube-state-metrics' AND phase = 'Failed' FACET pod LIMIT MAX) SELECT sum(`failed`)"
          }
        ]
      })
    }

    # Pod (Unknown)
    widget {
      title  = "Pod (Unknown)"
      row    = 3
      column = 11
      height = 2
      width  = 2
      visualization_id = "viz.billboard"
      configuration = jsonencode(
      {
        "nrqlQueries": [
          {
            "accountId": var.NEW_RELIC_ACCOUNT_ID,
            "query": "FROM (FROM Metric SELECT latest(kube_pod_status_phase) AS `unknown` WHERE instrumentation.provider = 'prometheus' AND prometheus_server = '${var.prometheus_server_name}' AND service = 'prometheus-kube-state-metrics' AND phase = 'Unknown' FACET pod LIMIT MAX) SELECT sum(`unknown`)"
          }
        ]
      })
    }

    # Container CPU Usage (mCPU)
    widget {
      title  = "Container CPU Usage (mCPU)"
      row    = 5
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
      row    = 5
      column = 7
      width  = 6
      height = 3
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

    # Container MEM Usage in each Pod (GB)
    widget {
      title  = "Container MEM Usage in each Pod (GB)"
      row    = 8
      column = 1
      width  = 6
      height = 3
      visualization_id = "viz.area"
      configuration = jsonencode(
      {
        "nrqlQueries": [
          {
            "accountId": var.NEW_RELIC_ACCOUNT_ID,
            "query": "FROM (FROM Metric SELECT average(container_memory_usage_bytes) AS `usage` WHERE instrumentation.provider = 'prometheus' AND prometheus_server = '${var.prometheus_server_name}' AND job = 'kubernetes-nodes-cadvisor' AND container IS NOT NULL AND pod IS NOT NULL FACET pod, container TIMESERIES 5 minutes SLIDE BY 10 seconds LIMIT MAX) SELECT average(`usage`) FACET pod, container TIMESERIES AUTO LIMIT MAX"
          }
        ]
      })
    }

    # Container MEM Utilization in each Pod (%)
    widget {
      title  = "Container MEM Utilization in each Pod (%)"
      row    = 8
      column = 7
      width  = 6
      height = 3
      visualization_id = "viz.line"
      configuration = jsonencode(
      {
        "nrqlQueries": [
          {
            "accountId": var.NEW_RELIC_ACCOUNT_ID,
            "query": "FROM (FROM Metric SELECT average(container_memory_usage_bytes) AS `usage`, filter(average(kube_pod_container_resource_limits), WHERE resource = 'memory') AS `limit` WHERE instrumentation.provider = 'prometheus' AND prometheus_server = '${var.prometheus_server_name}' AND (job = 'kubernetes-nodes-cadvisor' OR service = 'prometheus-kube-state-metrics' AND container IS NOT NULL AND pod IS NOT NULL) FACET pod, container TIMESERIES 5 minutes SLIDE BY 10 seconds) SELECT average(`usage`)/average(`limit`)*100 FACET pod, container TIMESERIES AUTO"
          }
        ]
      })
    }

    # Container File System Read Rate (1/s)
    widget {
      title  = "Container File System Read Rate (1/s)"
      row    = 11
      column = 1
      width  = 6
      height = 3
      visualization_id = "viz.area"
      configuration = jsonencode(
      {
        "nrqlQueries": [
          {
            "accountId": var.NEW_RELIC_ACCOUNT_ID,
            "query": "FROM (FROM Metric SELECT rate(average(container_fs_reads_total), 1 SECOND) AS `rate` WHERE instrumentation.provider = 'prometheus' AND prometheus_server = '${var.prometheus_server_name}' AND job = 'kubernetes-nodes-cadvisor' AND container IS NOT NULL AND pod IS NOT NULL FACET pod, container TIMESERIES 5 minutes SLIDE BY 10 seconds) SELECT average(`rate`) FACET pod, container TIMESERIES AUTO"
          }
        ]
      })
    }

    # Container File System Write Rate (1/s)
    widget {
      title  = "Container File System Write Rate (1/s)"
      row    = 11
      column = 7
      width  = 6
      height = 3
      visualization_id = "viz.area"
      configuration = jsonencode(
      {
        "nrqlQueries": [
          {
            "accountId": var.NEW_RELIC_ACCOUNT_ID,
            "query": "FROM (FROM Metric SELECT rate(average(container_fs_writes_total), 1 SECOND) AS `rate` WHERE instrumentation.provider = 'prometheus' AND prometheus_server = '${var.prometheus_server_name}' AND job = 'kubernetes-nodes-cadvisor' AND container IS NOT NULL AND pod IS NOT NULL FACET pod, container TIMESERIES 5 minutes SLIDE BY 10 seconds) SELECT average(`rate`) FACET pod, container TIMESERIES AUTO"
          }
        ]
      })
    }

    # Container Network Receive Rate (MB/s)
    widget {
      title  = "Container Network Receive Rate (MB/s)"
      row    = 14
      column = 1
      width  = 6
      height = 3
      visualization_id = "viz.area"
      configuration = jsonencode(
      {
        "nrqlQueries": [
          {
            "accountId": var.NEW_RELIC_ACCOUNT_ID,
            "query": "FROM (FROM Metric SELECT rate(average(container_network_receive_bytes_total)/1024/1024, 1 SECOND) AS `rate` WHERE instrumentation.provider = 'prometheus' AND prometheus_server = '${var.prometheus_server_name}' AND job = 'kubernetes-nodes-cadvisor' AND container IS NOT NULL AND pod IS NOT NULL FACET pod, container TIMESERIES 5 minutes SLIDE BY 10 seconds) SELECT average(`rate`) FACET pod, container TIMESERIES AUTO"
          }
        ]
      })
    }

    # Container Network Transmit Rate (MB/s)
    widget {
      title  = "Container Network Transmit Rate (MB/s)"
      row    = 14
      column = 7
      width  = 6
      height = 3
      visualization_id = "viz.area"
      configuration = jsonencode(
      {
        "nrqlQueries": [
          {
            "accountId": var.NEW_RELIC_ACCOUNT_ID,
            "query": "FROM (FROM Metric SELECT rate(average(container_network_transmit_bytes_total)/1024/1024, 1 SECOND) AS `rate` WHERE instrumentation.provider = 'prometheus' AND prometheus_server = '${var.prometheus_server_name}' AND job = 'kubernetes-nodes-cadvisor' AND container IS NOT NULL AND pod IS NOT NULL FACET pod, container TIMESERIES 5 minutes SLIDE BY 10 seconds) SELECT average(`rate`) FACET pod, container TIMESERIES AUTO"
          }
        ]
      })
    }
  }
}
