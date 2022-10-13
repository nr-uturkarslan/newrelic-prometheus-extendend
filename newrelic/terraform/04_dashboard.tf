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
            "query": "FROM Metric SELECT uniqueCount(pod), uniqueCount(deployment), uniqueCount(daemonset), uniqueCount(service), uniqueCount(statefulset) WHERE instrumentation.provider = 'prometheus' LIMIT MAX"
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
            "query": "FROM Metric SELECT max(machine_cpu_cores) AS 'CPU (cores)', max(machine_memory_bytes)/1024/1024/1024 AS 'MEM (GB)' WHERE instrumentation.provider = 'prometheus' FACET instance"
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
            "query": "FROM (FROM Metric SELECT latest(kube_deployment_status_replicas_available) AS `num_available_deployment_replicas` WHERE instrumentation.provider = 'prometheus' AND `result` != 0.0 FACET deployment) SELECT sum(`num_available_deployment_replicas` AS 'Deployments')"
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
            "query": "FROM (FROM Metric SELECT latest(kube_deployment_status_replicas_unavailable) AS `num_unavailable_replicas` WHERE instrumentation.provider = 'prometheus' AND `result` != 0.0 FACET deployment) SELECT sum(`num_unavailable_replicas` AS 'Deployments')"
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
            "query": "FROM (FROM Metric SELECT latest(kube_daemonset_status_number_available) AS `num_available_replicas` WHERE instrumentation.provider = 'prometheus' AND `result` != 0.0 FACET daemonset) SELECT sum(`num_available_replicas` AS 'DaemonSets')"
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
            "query": "FROM (FROM Metric SELECT latest(kube_daemonset_status_number_unavailable) AS `num_unavailable_replicas` WHERE instrumentation.provider = 'prometheus' AND `result` != 0.0 FACET daemonset) SELECT sum(`num_unavailable_replicas` AS 'DaemonSets')"
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
            "query": "FROM (FROM Metric SELECT latest(kube_statefulset_status_replicas_available) AS `num_available_replicas` WHERE instrumentation.provider = 'prometheus' AND `result` != 0.0 FACET daemonset) SELECT sum(`num_available_replicas` AS 'StatefulSets')"
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
            "query": "FROM (FROM Metric SELECT latest(kube_statefulset_status_replicas_unavailable) AS `num_unavailable_replicas` WHERE instrumentation.provider = 'prometheus' AND `result` != 0.0 FACET daemonset) SELECT sum(`num_unavailable_replicas` AS 'StatefulSets')"
          }
        ]
      })
    }

    # Node CPU Usage
    widget {
      title  = "Node CPU Utilization"
      row    = 3
      column = 1
      width  = 4
      visualization_id = "viz.line"
      configuration = jsonencode(
      {
        "nrqlQueries": [
          {
            "accountId": var.NEW_RELIC_ACCOUNT_ID,
            "query": "SELECT 100-average((`idle_usage` * 100)) AS 'CPU utilization (%)' FROM (SELECT irate(node_cpu_seconds_total, 1 SECONDS) AS `idle_usage` FROM Metric WHERE (mode = 'idle') FACET dimensions() LIMIT MAX TIMESERIES 5 minutes SLIDE BY 10 seconds) FACET node LIMIT MAX TIMESERIES 5 minutes"
          }
        ]
      })
    }

    # Node MEM Usage
    widget {
      title  = "Node MEM Utilization"
      row    = 3
      column = 5
      width  = 4
      visualization_id = "viz.line"
      configuration = jsonencode(
      {
        "nrqlQueries": [
          {
            "accountId": var.NEW_RELIC_ACCOUNT_ID,
            "query": "SELECT (100 * (1 - (((average(node_memory_MemFree_bytes) + average(node_memory_Cached_bytes)) + average(node_memory_Buffers_bytes)) / average(node_memory_MemTotal_bytes)))) FROM Metric FACET node LIMIT 100 TIMESERIES 5 minutes SLIDE BY 10 seconds"
          }
        ]
      })
    }

    # Node STO Usage
    widget {
      title  = "Node STO Utilization"
      row    = 3
      column = 9
      width  = 4
      visualization_id = "viz.line"
      configuration = jsonencode(
      {
        "nrqlQueries": [
          {
            "accountId": var.NEW_RELIC_ACCOUNT_ID,
            "query": "SELECT (1 - (average(node_filesystem_avail_bytes) / average(node_filesystem_size_bytes))) * 100 FROM Metric SINCE 60 MINUTES AGO UNTIL NOW FACET node TIMESERIES"
          }
        ]
      })
    }
  }
}
