# CRD Sync with vCluster

This example demonstrates bidirectional CRD synchronization between a vCluster and its host cluster using cert-manager resources. cert-manager `ClusterIssuers` are synced **from** the host into the vCluster (read-only), while `Certificates`, `Issuers`, and `Ingresses` created inside the vCluster are synced **to** the host cluster so cert-manager can act on them.

## Prerequisites

- vCluster CLI installed ([install guide](https://www.vcluster.com/docs/get-started))
- Kubernetes cluster with nginx ingress controller
- cert-manager installed on the **host cluster** (`certificates.cert-manager.io` CRD must exist)

## Overview

| File | Purpose |
|------|---------|
| `vcluster.yaml` | vCluster config — defines CRD sync rules (toHost and fromHost) |
| `demo.yaml` | Sample nginx Deployment + ClusterIP Service inside the vCluster |
| `cert-issuer.yaml` | Let's Encrypt ACME Issuer (created inside vCluster, synced to host) |
| `certificate.yaml` | TLS Certificate resource (created inside vCluster, synced to host) |
| `app-ingress.yaml` | Ingress with cert-manager annotation (created inside vCluster, synced to host) |

### How the sync works

**From host → vCluster (read-only):**
- `clusterissuers.cert-manager.io` — ClusterIssuers created on the host appear as read-only resources inside the vCluster.

**From vCluster → host:**
- `issuers.cert-manager.io` — Issuers created in the vCluster are synced to the host so cert-manager can process them.
- `certificates.cert-manager.io` — Certificates are synced to the host; cert-manager issues them and the resulting Secret is synced back.
- `networking.k8s.io/v1/Ingress` — Ingress annotations (including `cert-manager.io/issuer`) are rewritten to reference the correct host-side Issuer name.

## Steps

### 1. Install cert-manager on the host cluster

```bash
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/latest/download/cert-manager.yaml
```

Wait for cert-manager to be ready:

```bash
kubectl wait --for=condition=Available deployment --all -n cert-manager --timeout=120s
```

### 2. Create the vCluster

```bash
vcluster create crd-sync-demo -n crd-sync-demo -f vcluster.yaml
```

### 3. Connect to the vCluster

```bash
vcluster connect crd-sync-demo -n crd-sync-demo
```

### 4. Update placeholder values

Before applying, edit the following files and replace the placeholder values:

- `cert-issuer.yaml` — Replace `your-email@gmail.com` with your real email address (required by Let's Encrypt).
- `certificate.yaml` — Replace `ppp.xx.xxx.xx.xxx.nip.io` with your actual domain.
- `app-ingress.yaml` — Replace `ppp.xx.xxx.xx.xx.nip.io` with your actual domain.

### 5. Deploy the demo application inside the vCluster

```bash
kubectl apply -f demo.yaml
```

### 6. Create the Issuer and Certificate inside the vCluster

```bash
kubectl apply -f cert-issuer.yaml
kubectl apply -f certificate.yaml
```

### 7. Create the Ingress inside the vCluster

```bash
kubectl apply -f app-ingress.yaml
```

### 8. Verify resources on the host cluster

```bash
# Disconnect from vCluster
vcluster disconnect

# Check that Issuer and Certificate were synced to host
kubectl get issuers -A
kubectl get certificates -A

# Check that cert-manager issued the certificate
kubectl get certificaterequests -A
```

## Cleanup

```bash
vcluster delete crd-sync-demo -n crd-sync-demo
kubectl delete namespace crd-sync-demo
```

## Learn More

- [vCluster CRD Sync docs](https://www.vcluster.com/docs/vcluster/configure/vcluster-yaml/sync/)
- [cert-manager docs](https://cert-manager.io/docs/)
- Community: [https://slack.vcluster.com](https://slack.vcluster.com)
