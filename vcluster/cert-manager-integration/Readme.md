# cert-manager Integration with vCluster

This example demonstrates the native cert-manager integration in vCluster. With `integrations.certManager.enabled: true`, workloads inside the vCluster can request TLS certificates directly from the host cluster's cert-manager — no plugin or CRD sync required. cert-manager runs on the host and issues certificates on behalf of resources created inside the vCluster.

## Prerequisites

- vCluster CLI installed ([install guide](https://www.vcluster.com/docs/get-started))
- Kubernetes cluster with nginx ingress controller
- cert-manager installed on the **host cluster**

## Overview

| File | Purpose |
|------|---------|
| `vcluster.yaml` | vCluster config — enables cert-manager integration and ingress sync |
| `app.yaml` | nginx Deployment + ClusterIP Service inside the vCluster |
| `issuer.yaml` | Let's Encrypt ACME Issuer (created inside vCluster) |
| `certificate.yaml` | TLS Certificate resource (created inside vCluster) |
| `ingress.yaml` | Ingress resource with TLS (created inside vCluster) |

The `vcluster.yaml` enables two features:
- `integrations.certManager.enabled: true` — vCluster instructs the host's cert-manager to issue certificates for resources inside the vCluster.
- `sync.toHost.ingresses.enabled: true` — Ingress resources sync from the vCluster to the host so nginx can serve them.

> **Note:** `issuer.yaml` contains a demo email address (`saiyam-demo@gmail.com`). Replace this with your own email before applying — Let's Encrypt requires a valid email.
> `certificate.yaml` and `ingress.yaml` contain a hardcoded IP-based domain (`146.190.198.189.nip.io`). Replace these with a domain that resolves to your nginx ingress controller's external IP.

## Steps

### 1. Install cert-manager on the host cluster

```bash
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.16.2/cert-manager.yaml
```

Wait for cert-manager to be ready:

```bash
kubectl wait --for=condition=Available deployment --all -n cert-manager --timeout=120s
```

### 2. Install nginx ingress controller on the host cluster

```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.9.4/deploy/static/provider/cloud/deploy.yaml
```

### 3. Create the vCluster

```bash
vcluster create cert-demo -n cert-demo -f vcluster.yaml
```

### 4. Connect to the vCluster

```bash
vcluster connect cert-demo -n cert-demo
```

### 5. Update placeholder values in the YAML files

Edit the following files before applying:
- `issuer.yaml` — Replace `saiyam-demo@gmail.com` with your email address.
- `certificate.yaml` — Replace `cert.146.190.198.189.nip.io` with your domain.
- `ingress.yaml` — Replace `cert.146.190.198.189.nip.io` with your domain.

### 6. Deploy the application inside the vCluster

```bash
kubectl apply -f app.yaml
kubectl apply -f issuer.yaml
kubectl apply -f certificate.yaml
kubectl apply -f ingress.yaml
```

### 7. Verify the certificate was issued

```bash
kubectl get certificate
kubectl describe certificate example-cert
```

The certificate `READY` status should become `True` once Let's Encrypt completes the HTTP-01 challenge.

## Cleanup

```bash
vcluster disconnect
vcluster delete cert-demo -n cert-demo
kubectl delete namespace cert-demo
```

## Learn More

- [vCluster cert-manager integration docs](https://www.vcluster.com/docs/vcluster/configure/vcluster-yaml/integrations/cert-manager)
- [cert-manager docs](https://cert-manager.io/docs/)
- Community: [https://slack.vcluster.com](https://slack.vcluster.com)
