# Whiteboarding vCluster

This directory contains an architecture diagram drawn during a vCluster webinar whiteboarding session. It illustrates how vCluster works — virtual control planes running inside the host cluster, workload pods scheduled on host nodes, and the sync mechanism that keeps the virtual and host cluster state consistent.

## Contents

The PNG file in this directory shows:

- A host Kubernetes cluster with its API server and node pool
- One or more vCluster instances, each with their own virtual API server (running as a pod on the host)
- The sync loop between the virtual control plane and the host cluster
- How workloads created inside a vCluster appear as pods on host nodes under a translated namespace

## Learn More

- [vCluster Architecture docs](https://www.vcluster.com/docs/vcluster/understand/architecture)
- [vCluster documentation](https://www.vcluster.com/docs/vcluster/)
- Community: [https://slack.vcluster.com](https://slack.vcluster.com)
