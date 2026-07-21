# Local LLM on vCluster with the NVIDIA GPU Operator

This example demonstrates running local LLMs (via Ollama + Open-WebUI) inside two isolated vClusters that share a single GPU through NVIDIA GPU time-slicing. Each vCluster gets its own GPU replica, allowing multiple tenants to run AI workloads on the same physical GPU without interference.

## Prerequisites

- Kubernetes cluster with at least one NVIDIA GPU node
- [Helm](https://helm.sh/docs/intro/install/) installed
- vCluster CLI installed ([install guide](https://www.vcluster.com/docs/get-started))
- MetalLB (or another load balancer) and nginx ingress controller on the host cluster
- DNS or `/etc/hosts` entries for the ingress hostnames

## Overview

| File | Purpose |
|------|---------|
| `vcluster.yaml` | vCluster config — syncs IngressClasses from host, syncs Ingresses to host, and enables node sync (required for GPU scheduling) |
| `time-slicing-config-all.yaml` | ConfigMap for the NVIDIA GPU Operator — configures 4 time-sliced GPU replicas |
| `verify-timeslicing.yaml` | Job to verify time-slicing is working correctly |
| `ts1-ingress.yaml` | Ingress resources for the first vCluster (ts1) |
| `ts2-ingress.yaml` | Ingress resources for the second vCluster (ts2) |
| `continue.yaml` | Configuration for the Continue AI coding assistant in VS Code |

> **Note:** The README and YAML files reference a specific GPU node name. Replace `mai` with the name of your GPU node (`kubectl get nodes`) wherever it appears.

## Steps

### 1. Install the NVIDIA GPU Operator on the host cluster

```bash
helm repo add nvidia https://helm.ngc.nvidia.com/nvidia
helm repo update
helm install --wait --generate-name \
  -n gpu-operator --create-namespace \
  nvidia/gpu-operator --version=v25.3.0
```

### 2. Apply the time-slicing ConfigMap

This splits one physical GPU into 4 virtual replicas:

```bash
kubectl create -f time-slicing-config-all.yaml
```

Patch the cluster-policy to enable time-slicing:

```bash
kubectl patch clusterpolicy/cluster-policy -n gpu-operator --type merge \
  -p '{"spec": {"devicePlugin": {"config": {"name": "time-slicing-config-all", "default": "any"}}}}'
```

Verify the GPU replicas are visible on your GPU node:

```bash
kubectl describe node <gpu-node-name> | grep -i gpu.count
kubectl describe node <gpu-node-name> | grep -i gpu.replicas
```

### 3. Set up ingress and DNS on the host cluster

Verify that MetalLB and nginx ingress controller are running and have a LoadBalancer IP:

```bash
kubectl get services -n nginx-ingress | grep -i loadbalancer
```

Add the following entries to `/etc/hosts` (or configure real DNS records), replacing `<nginx-ip>` with the LoadBalancer IP:

```
<nginx-ip>   ts1.vcluster.ai
<nginx-ip>   ots1.vcluster.ai
<nginx-ip>   ts2.vcluster.ai
<nginx-ip>   ots2.vcluster.ai
```

### 4. Deploy the first vCluster (ts1)

```bash
vcluster create ts1 -n ts1 -f vcluster.yaml
```

After creation the vCluster CLI will connect automatically (or port-forward if no Docker Desktop is present).

### 5. Install the GPU Operator in ts1

Inside the vCluster, install the GPU Operator with driver and toolkit disabled (they run on the host):

```bash
helm install --wait --generate-name \
  -n gpu-operator --create-namespace \
  nvidia/gpu-operator --version=v25.3.0 \
  --set driver.enabled=false \
  --set toolkit.enabled=false \
  --set nfd.enabled=false
```

Apply time-slicing config inside ts1:

```bash
kubectl create -f time-slicing-config-all.yaml
kubectl patch clusterpolicy/cluster-policy -n gpu-operator --type merge \
  -p '{"spec": {"devicePlugin": {"config": {"name": "time-slicing-config-all", "default": "any"}}}}'
```

Verify the GPU replicas are visible inside ts1:

```bash
kubectl describe node <gpu-node-name> | grep -i gpu.count
kubectl describe node <gpu-node-name> | grep -i gpu.replicas
```

### 6. Install Open-WebUI with Ollama in ts1

```bash
helm repo add open-webui https://helm.openwebui.com
helm repo update
helm install open-webui open-webui/open-webui \
  --set image.tag=ollama \
  --set ollama.ollama.gpu.enabled=true \
  --set ollama.ollama.gpu.number=1 \
  --set ollama.ollama.gpu.type=nvidia \
  --set ollama.runtimeClassName=nvidia
```

Create the ingress for ts1:

```bash
kubectl create -f ts1-ingress.yaml
kubectl get ingress
```

Open the UI in your browser at `http://ts1.vcluster.ai` and set up your account.

### 7. Deploy the second vCluster (ts2)

Disconnect from ts1 and repeat steps 4–6 for ts2:

```bash
vcluster disconnect
vcluster create ts2 -n ts2 -f vcluster.yaml
```

Follow the same GPU Operator and Open-WebUI install steps, then:

```bash
kubectl create -f ts2-ingress.yaml
```

Open ts2's UI at `http://ts2.vcluster.ai`.

### 8. (Optional) Connect Continue in VS Code

[Continue](https://www.continue.dev/) is an open-source AI coding assistant for VS Code. To connect it to the Ollama instance running in ts1 or ts2:

1. Install the [Continue extension](https://marketplace.visualstudio.com/items?itemName=Continue.continue) in VS Code.
2. Apply the `continue.yaml` config or manually add the Ollama endpoint (`http://ots1.vcluster.ai`) as an OpenAI-compatible model provider in Continue's settings.
3. Select the model you downloaded in Open-WebUI and start chatting with your code.

## Cleanup

```bash
vcluster delete ts1 -n ts1
vcluster delete ts2 -n ts2
kubectl delete namespace ts1 ts2
```

## Learn More

- [vCluster docs](https://www.vcluster.com/docs/vcluster/)
- [NVIDIA GPU Operator docs](https://docs.nvidia.com/datacenter/cloud-native/gpu-operator/latest/index.html)
- [Ollama](https://ollama.com/)
- [Open-WebUI](https://docs.openwebui.com/)
- Community: [https://slack.vcluster.com](https://slack.vcluster.com)
