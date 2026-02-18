# vCluster Sleep Mode

This example demonstrates sleep mode for vClusters — a vCluster Platform feature that automatically pauses idle virtual clusters to free up host cluster resources. When a vCluster has had no activity for a configurable period, it scales down to zero. It resumes automatically when a new request arrives.

> **Note:** Sleep mode requires **vCluster Platform** (not OSS vCluster). You need a running vCluster Platform instance to follow this guide.

## Prerequisites

- vCluster CLI installed ([install guide](https://www.vcluster.com/docs/get-started))
- vCluster Platform instance (self-hosted or vcluster.cloud)
- nginx ingress controller on the host cluster (for the ingress demo steps)

## Steps

### 1. Install the vCluster CLI

```bash
curl -L -o vcluster "https://github.com/loft-sh/vcluster/releases/latest/download/vcluster-linux-amd64" \
  && sudo install -c -m 0755 vcluster /usr/local/bin && rm -f vcluster
```

### 2. Create a `vcluster.yaml` with sleep mode enabled

```yaml
experimental:
  sleepMode:
    enabled: true
    autoSleep:
      afterInactivity: 2m   # 2 minutes — reduce for demo; use a longer value in production
      exclude:
        selector:
          labels:
            dont: sleep
```

The `exclude` selector prevents pods with the label `dont=sleep` from triggering the inactivity timer — useful for keeping infrastructure pods (like an ingress controller) from being counted as activity.

### 3. Log in to vCluster Platform

```bash
vcluster login https://YOUR_PLATFORM_URL --access-key YOUR_ACCESS_KEY
```

Replace `YOUR_PLATFORM_URL` with your vCluster Platform URL and `YOUR_ACCESS_KEY` with an access key from the platform ([how to create one](https://www.vcluster.com/docs/platform/administer/users-permissions/access-keys)).

### 4. Create the vCluster

```bash
vcluster create demo -f vcluster.yaml
```

### 5. Deploy a workload inside the vCluster

```bash
kubectl create deployment nginx --image=nginx --replicas=3
kubectl expose deployment nginx --port=80 --target-port=80 --type=ClusterIP
```

### 6. (Optional) Set up ingress inside the vCluster

Install nginx ingress controller inside the vCluster:

```bash
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
helm install ingress-nginx ingress-nginx/ingress-nginx \
  --namespace ingress-nginx \
  --create-namespace \
  --set controller.hostNetwork=true \
  --set controller.dnsPolicy=ClusterFirstWithHostNet \
  --set controller.service.type=ClusterIP
```

Apply an IngressClass:

```bash
kubectl apply -f - <<EOF
apiVersion: networking.k8s.io/v1
kind: IngressClass
metadata:
  name: nginx
spec:
  controller: k8s.io/ingress-nginx
EOF
```

Apply an ingress (replace the hostname with your domain or nip.io address):

```bash
kubectl apply -f - <<EOF
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: nginx-ingress
  annotations:
    nginx.ingress.kubernetes.io/mirror-target: 'enabled'
spec:
  ingressClassName: nginx
  rules:
  - host: demo.<YOUR_IP>.nip.io
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: nginx
            port:
              number: 80
EOF
```

Label the ingress controller deployment to exclude it from sleep inactivity tracking:

```bash
kubectl label deploy -n ingress-nginx ingress-nginx-controller dont=sleep
```

### 7. Watch the vCluster sleep

After the configured inactivity period (2 minutes in the demo config), the vCluster will scale down. In the vCluster Platform UI you can see the cluster status change to `Sleeping`.

Any incoming request to the cluster API or ingress will wake it up automatically.

## Cleanup

```bash
vcluster delete demo
```

## Learn More

- [vCluster sleep mode docs](https://www.vcluster.com/docs/vcluster/)
- [vCluster Platform docs](https://www.vcluster.com/docs/platform/)
- Community: [https://slack.vcluster.com](https://slack.vcluster.com)
