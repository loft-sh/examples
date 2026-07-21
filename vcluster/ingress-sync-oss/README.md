# Ingress Sync with vCluster (OSS)

This example demonstrates how to deploy an application inside a vCluster and expose it externally through the host cluster's nginx ingress controller. The vCluster syncs Ingress resources to the host and receives IngressClass resources from the host, enabling seamless TLS termination via cert-manager and Let's Encrypt.

## Prerequisites

- vCluster CLI installed ([install guide](https://www.vcluster.com/docs/get-started))
- Kubernetes cluster with nginx ingress controller
- cert-manager installed on the host cluster
- A domain name with DNS pointing to your ingress controller's external IP

## Overview

| File | Purpose |
|------|---------|
| `vcluster.yaml` | vCluster config — enables ingress sync to host and IngressClass sync from host |
| `game-deployment.yaml` | Deploys the 2048 game application |
| `game-service.yaml` | ClusterIP service for the 2048 game |
| `game-ingress.yaml` | Ingress resource (inside vCluster) with TLS via cert-manager |
| `cluster-issuer-staging.yaml` | Let's Encrypt staging ClusterIssuer (for testing) |
| `cluster-issuer-prod.yaml` | Let's Encrypt production ClusterIssuer |

The `vcluster.yaml` configures two sync behaviors:
- `sync.toHost.ingresses.enabled: true` — Ingress resources created inside the vCluster are synced to the host cluster so nginx can route traffic to them.
- `sync.fromHost.ingressClasses.enabled: true` — IngressClasses from the host cluster are visible inside the vCluster.

## Steps

### 1. Create the vCluster

```bash
vcluster create ingress-demo -n ingress-demo -f vcluster.yaml
```

### 2. Update the ClusterIssuer email addresses

Before applying, edit `cluster-issuer-staging.yaml` and `cluster-issuer-prod.yaml` and replace the `email` field with your own email address. This is required by Let's Encrypt.

### 3. Apply the ClusterIssuers on the host cluster

The ClusterIssuers must be applied to the **host cluster**, not inside the vCluster, since cert-manager runs on the host.

```bash
# Use staging first to avoid rate limits while testing
kubectl apply -f cluster-issuer-staging.yaml

# Once confirmed working, apply production
kubectl apply -f cluster-issuer-prod.yaml
```

### 4. Connect to the vCluster

```bash
vcluster connect ingress-demo -n ingress-demo
```

### 5. Update the Ingress hostname

Edit `game-ingress.yaml` and replace `game1.hrittikhere.live` with your own domain name. The domain must resolve to your nginx ingress controller's external IP.

### 6. Deploy the 2048 game inside the vCluster

```bash
kubectl apply -f game-deployment.yaml
kubectl apply -f game-service.yaml
kubectl apply -f game-ingress.yaml
```

### 7. Verify the ingress synced to the host

```bash
# Disconnect from vCluster first
vcluster disconnect

# Check that the ingress appears on the host cluster
kubectl get ingress -A
```

Once cert-manager issues the certificate, the game will be accessible at your configured hostname over HTTPS.

## Cleanup

```bash
vcluster delete ingress-demo -n ingress-demo
kubectl delete namespace ingress-demo
```

## Learn More

- [vCluster Ingress Sync docs](https://www.vcluster.com/docs/vcluster/configure/vcluster-yaml/sync/to-host/networking/ingresses)
- [vCluster Sync from Host docs](https://www.vcluster.com/docs/vcluster/configure/vcluster-yaml/sync/from-host/)
- [cert-manager docs](https://cert-manager.io/docs/)
- Community: [https://slack.vcluster.com](https://slack.vcluster.com)
