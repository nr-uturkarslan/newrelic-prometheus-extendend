# Prometheus for New Relic

This repository is dedicated for various metric forwarding cases to one or more New Relic accounts with Prometheus.

None of the Prometheus related Docker images (`prometheus`, `kube state metrics`, `node exporter`...) are changed. Instead, satisfying different scraping & forwarding cases are accomplished via manipulation of Kubernetes manifests.

**REMARK**: Contribution is highly encouraged :)

## Introduction

In many organisations, the Kubernetes cluster itself is maintained by a dedicated ops team where on top of the underlying infrastructure, the dev teams run their applications.

When it comes to New Relic for observability, it is a quite often case where due to different reasons (data isolation, billing, least privileges...) each of these team have their own New Relic account. This causes automatic data segregation since the monitoring agents (APM, browser, infra...) are configured to report to their specific accounts. 

However, the dev teams can require some insights regarding the infrastructure or the ops team can deploy & maintain some common apps for everyone (Kafka, DBs, custom apps...) and want to know more about them.

This repo is meant to satisfy such common use cases with genericly configurable manifests.

## Chart configuration

How to set the variables for different use cases can be found here: [Chart configuration](charts/prometheus/README.md)
