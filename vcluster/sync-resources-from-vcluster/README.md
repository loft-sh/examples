# Sync Resources from vCluster to Host

This example shows how to create workloads inside a vCluster and have their Ingress resources sync back to the host cluster — allowing the host's nginx ingress controller and cert-manager to handle routing and TLS for applications running inside the vCluster.

> **Note:** `values.yaml` in this directory uses the **pre-v0.20 legacy API syntax** (e.g. `syncer.extraArgs`, `sync.ingresses.enabled`). The current vCluster v0.20+ format uses `vcluster.yaml` with a different structure. If you are running vCluster v0.20 or later, refer to the [vcluster.yaml configuration reference](https://www.vcluster.com/docs/vcluster/configure/vcluster-yaml/) for the updated syntax.

## Prerequisites

- vCluster CLI installed ([install guide](https://www.vcluster.com/docs/get-started))
- Kubernetes cluster (EKS or any cluster with an external load balancer)
- Helm installed
- A domain name you control

## Overview

| File | Purpose |
|------|---------|
| `values.yaml` | Legacy vCluster Helm values (pre-v0.20) — enables ingress sync and sets the vCluster API domain |
| `demo-vcluster-ingress.yaml` | Ingress resource for the vCluster API endpoint (host cluster) |
| `cluster-issuer.yaml` | cert-manager ClusterIssuer for Let's Encrypt (host cluster) |
| `app.yaml` | Demo application — Deployment, Service, and Ingress (inside vCluster) |
| `plugin.yaml` | Legacy syncer plugin config — for reference only |

## Steps

### 1. Install nginx ingress controller on the host cluster

```bash
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
helm install nginx-ingress ingress-nginx/ingress-nginx \
  --create-namespace -n nginx-ingress \
  --set "controller.extraArgs.enable-ssl-passthrough=true"
```

Find the LoadBalancer address:

```bash
kubectl get service -n nginx-ingress | grep LoadBalancer | awk '{print $4}'
```

Create a CNAME (for cloud load balancers) or A record (for IP-based load balancers) pointing your domain to this address. For example:

```
demo IN CNAME <uuid>.us-west-1.elb.amazonaws.com
```

### 2. Install cert-manager on the host cluster

```bash
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/latest/download/cert-manager.yaml
```

Wait for cert-manager to be ready:

```bash
kubectl wait --for=condition=Available deployment --all -n cert-manager --timeout=120s
```

### 3. Create the cert-manager ClusterIssuer

Edit `cluster-issuer.yaml` and add your email address, then apply:

```bash
kubectl apply -f cluster-issuer.yaml
```

### 4. Create the vCluster namespace and API ingress

```bash
kubectl create namespace demo-vcluster
kubectl create -f demo-vcluster-ingress.yaml
```

Edit `demo-vcluster-ingress.yaml` first and replace the hostname with your domain.

### 5. Create the vCluster

> **Legacy command (pre-v0.20):**

```bash
vcluster create demo-vcluster --namespace demo-vcluster --connect=false -f values.yaml
```

Edit `values.yaml` and replace `demo.vcluster-demo.com` with your actual domain before running this command.

### 6. Connect to the vCluster

```bash
vcluster connect demo-vcluster --update-current=false --server=https://demo.vcluster-demo.com
```

### 7. Deploy the application inside the vCluster

Edit `app.yaml` to update the domain, then:

```bash
kubectl --kubeconfig ./kubeconfig.yaml apply -f app.yaml
```

The Ingress resource in `app.yaml` will sync to the host cluster, where nginx and cert-manager will handle routing and TLS.

## Cleanup

```bash
vcluster delete demo-vcluster -n demo-vcluster
kubectl delete namespace demo-vcluster
```

## Learn More

- [vCluster sync configuration docs](https://www.vcluster.com/docs/vcluster/configure/vcluster-yaml/sync/)
- [vcluster.yaml configuration reference](https://www.vcluster.com/docs/vcluster/configure/vcluster-yaml/)
- Community: [https://slack.vcluster.com](https://slack.vcluster.com)
