# vCluster Snapshot and Restore

This example demonstrates how to take an OCI image-based point-in-time snapshot of a vCluster and restore it — either in-place or by creating a new vCluster from the snapshot. Snapshots capture the full vCluster state (namespaces, CRDs, workloads) and store it as a container image in any OCI-compatible registry.

## Prerequisites

- vCluster CLI installed ([install guide](https://www.vcluster.com/docs/get-started))
- Kubernetes cluster (host)
- An OCI-compatible container registry account (Docker Hub, GHCR, ECR, etc.)
- Docker or another container build tool (for building the custom application image)

## Overview

| File | Purpose |
|------|---------|
| `deployment.yaml` | Sample nginx Deployment that uses a custom image — replace the image reference before use |

> **Note:** `deployment.yaml` references `mpetason/vs-rr:1987`. You need to build and push your own image, or replace this with any image you want to test snapshot/restore with (e.g. `nginx:latest`).

## Steps

### 1. Create a vCluster

```bash
vcluster create test
```

### 2. Deploy a workload inside the vCluster

You can use the provided `deployment.yaml` (update the image first) or deploy anything you like:

```bash
# Option A: use a simple nginx image
kubectl create namespace testc
kubectl create deployment nginx-deployment -n testc --image=nginx
kubectl get pods -n testc

# Option B: build and push your own image, update deployment.yaml, then apply
# docker build -t YOUR_DOCKERHUB_USERNAME/my-app:v1 --platform linux/amd64 .
# docker push YOUR_DOCKERHUB_USERNAME/my-app:v1
# kubectl apply -f deployment.yaml -n testc
```

### 3. Take an OCI snapshot

Replace `YOUR_DOCKERHUB_USERNAME` with your registry username:

```bash
vcluster snapshot test oci://docker.io/YOUR_DOCKERHUB_USERNAME/vcluster-test:snapshot1
```

The snapshot is pushed to your registry as a container image. The vCluster continues running normally while this happens.

### 4. Verify the snapshot exists

```bash
docker pull YOUR_DOCKERHUB_USERNAME/vcluster-test:snapshot1
```

### 5. Simulate a change or breakage

```bash
# For example, install additional CRDs on the vCluster
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.17.0/cert-manager.yaml
kubectl get crd | grep cert-manager
```

### 6. Restore in place (option A)

Restore the vCluster from the snapshot while keeping the same vCluster name:

```bash
vcluster restore test oci://docker.io/YOUR_DOCKERHUB_USERNAME/vcluster-test:snapshot1
```

After restore, reconnect and verify:

```bash
vcluster connect test
kubectl get crd        # cert-manager CRDs should be gone
kubectl get pods -n testc
```

### 7. Create a new vCluster from the snapshot (option B)

You can also delete the current vCluster and create a fresh one from the snapshot:

```bash
vcluster delete test
vcluster create test --restore oci://docker.io/YOUR_DOCKERHUB_USERNAME/vcluster-test:snapshot1
```

The new vCluster will have all the state from when the snapshot was taken.

### 8. Local snapshots (alternative)

To save the snapshot locally instead of pushing to a registry:

```bash
vcluster snapshot test "container:///data/test-snapshot.tar.gz"

# Copy it out of the vCluster pod
kubectl cp vcluster-test/test-0:data/test-snapshot.tar.gz test-snapshot.tar.gz
```

> **Note:** The `--restore` flag currently requires a remote OCI endpoint. Local restore support may change in future vCluster versions — check the [docs](https://www.vcluster.com/docs/vcluster/) for updates.

## Cleanup

```bash
vcluster delete test
```

## Learn More

- [vCluster snapshot/restore docs](https://www.vcluster.com/docs/vcluster/)
- Community: [https://slack.vcluster.com](https://slack.vcluster.com)
