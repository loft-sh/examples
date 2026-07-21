# ArgoCD + Helm + vCluster

This example shows how to use ArgoCD to create and manage a vCluster via the Helm chart from `charts.loft.sh`. ArgoCD watches `application.yaml` and ensures the vCluster is deployed declaratively — any drift is automatically reconciled. The vCluster is configured to expose its API over nginx ingress and to sync Ingress resources bidirectionally with the host cluster.

## Prerequisites

- ArgoCD installed on your Kubernetes cluster
- nginx ingress controller on the host cluster
- vCluster CLI installed ([install guide](https://www.vcluster.com/docs/get-started))

## Overview

| File | Purpose |
|------|---------|
| `application.yaml` | ArgoCD Application resource that deploys vCluster via Helm |

The `application.yaml` deploys the `vcluster` Helm chart from `https://charts.loft.sh` into the `demo-vcluster` namespace. The inline Helm values configure:
- `controlPlane.ingress` — exposes the vCluster API over nginx ingress at `demo.vcluster.local`
- `controlPlane.proxy.extraSANs` — adds the ingress hostname as a TLS SAN so `kubectl` trusts the API server
- `sync.fromHost.ingressClasses` + `sync.toHost.ingresses` — syncs IngressClasses from host and Ingresses from vCluster to host

> **Note:** The `application.yaml` pins chart version `0.20.0-beta.6`. Check [https://charts.loft.sh](https://charts.loft.sh) for the latest stable version and update `targetRevision` accordingly.

## Steps

### 1. Update `application.yaml`

Edit `application.yaml` and replace:
- `demo.vcluster.local` with your actual hostname (must resolve to the nginx ingress controller's IP or load balancer)
- `targetRevision: 0.20.0-beta.6` with the latest stable vCluster chart version

### 2. Apply the ArgoCD Application

```bash
kubectl apply -f application.yaml
```

ArgoCD will create the `demo-vcluster` namespace and deploy the vCluster Helm release automatically.

### 3. Monitor the deployment in ArgoCD

Open the ArgoCD UI and check the `demo-vcluster` application. It should sync to `Healthy` once the vCluster pod is running.

### 4. Connect to the vCluster

```bash
vcluster connect demo-vcluster -n demo-vcluster --update-current=false --server=https://demo.vcluster.local
```

Replace `demo.vcluster.local` with the hostname you configured in step 1.

### 5. Use the vCluster

```bash
export KUBECONFIG=./kubeconfig.yaml
kubectl get namespace
```

## Cleanup

To delete the vCluster, remove the ArgoCD Application (ArgoCD will cascade-delete the Helm release):

```bash
kubectl delete -f application.yaml
kubectl delete namespace demo-vcluster
```

## Learn More

- [vCluster Helm chart reference](https://www.vcluster.com/docs/vcluster/deploy/basics)
- [vCluster with ArgoCD](https://www.vcluster.com/docs/vcluster/integrations/ci-cd/argocd)
- [vcluster.yaml Configuration Reference](https://www.vcluster.com/docs/vcluster/configure/vcluster-yaml/)
- Community: [https://slack.vcluster.com](https://slack.vcluster.com)
