# MetalLB + NGINX + vCluster

This example sets up a vCluster on a bare-metal or on-premises Kubernetes cluster where MetalLB provides LoadBalancer IP addresses and nginx provides ingress. The vCluster API is exposed over an nginx Ingress resource, making it accessible over a hostname without needing a cloud load balancer.

## Prerequisites

- vCluster CLI installed ([install guide](https://www.vcluster.com/docs/get-started))
- Bare-metal, on-prem, or VM-based Kubernetes cluster (MetalLB does not work with cloud-managed clusters that already provide a load balancer implementation — e.g. EKS, GKE, AKS)
- Helm installed

## Overview

| File | Purpose |
|------|---------|
| `metallb.yaml` | MetalLB IPAddressPool and L2Advertisement — defines which IPs MetalLB assigns to LoadBalancer services |
| `vcluster.yaml` | vCluster config — enables ingress for the API endpoint and syncs ingress resources bidirectionally |

> **Note:** `metallb.yaml` contains hardcoded IP addresses (`192.168.86.15-192.168.86.25`). Replace this range with an available range on your network before applying.

## Steps

### 1. Install MetalLB

```bash
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.14.5/config/manifests/metallb-native.yaml
```

Wait for MetalLB to be ready:

```bash
kubectl wait --for=condition=Available deployment --all -n metallb-system --timeout=120s
```

### 2. Configure MetalLB

Edit `metallb.yaml` and replace `192.168.86.15-192.168.86.25` with an IP address range that is:
- On the same subnet as your Kubernetes nodes
- Not already assigned to any other host

Then apply:

```bash
kubectl apply -f metallb.yaml
```

### 3. Install nginx ingress controller

```bash
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
helm install nginx-ingress ingress-nginx/ingress-nginx \
  --create-namespace -n nginx-ingress \
  --set "controller.extraArgs.enable-ssl-passthrough=true"
```

MetalLB will assign a LoadBalancer IP from your configured pool to the nginx ingress controller service.

### 4. Configure DNS or `/etc/hosts`

Find the IP assigned to the nginx ingress controller:

```bash
kubectl get service -n nginx-ingress
```

Then either:
- Add a DNS record pointing your desired hostname to that IP, or
- Add a line to `/etc/hosts` for local testing (example from `vcluster.yaml`):
  ```
  <nginx-LoadBalancer-IP>   demo.vcluster.local
  ```

### 5. Update `vcluster.yaml`

Edit `vcluster.yaml` and replace `demo.vcluster.local` with the hostname you configured above.

### 6. Create the vCluster

```bash
vcluster create demo-vcluster -n demo-vcluster --connect=false -f vcluster.yaml
```

Verify the vCluster is running:

```bash
vcluster list
```

### 7. Connect to the vCluster

```bash
vcluster connect demo-vcluster -n demo-vcluster --update-current=false --server=https://demo.vcluster.local
```

Replace `demo.vcluster.local` with your configured hostname.

## Troubleshooting

- **Ingress resource missing class**: If the vCluster ingress was created without an `ingressClassName`, check that your nginx ingress controller is set as the default. You can also specify it explicitly in `vcluster.yaml` under `controlPlane.ingress.spec.ingressClassName: nginx`.
- **MetalLB not assigning IPs**: Verify the IP range in `metallb.yaml` is on the correct subnet and not conflicting with other hosts. Check MetalLB controller logs: `kubectl logs -n metallb-system -l component=controller`.

## Cleanup

```bash
vcluster delete demo-vcluster -n demo-vcluster
kubectl delete namespace demo-vcluster
```

## Learn More

- [vCluster docs](https://www.vcluster.com/docs/vcluster/)
- [MetalLB docs](https://metallb.universe.tf/)
- [nginx ingress controller docs](https://kubernetes.github.io/ingress-nginx/)
- Community: [https://slack.vcluster.com](https://slack.vcluster.com)
