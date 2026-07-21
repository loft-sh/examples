# vCluster Platform on EKS

This example provides configuration for setting up an EKS cluster suitable for running vCluster Platform. It includes Karpenter for node autoscaling, OIDC for IAM service account federation, and GP3 as the default storage class.

## Prerequisites

- AWS CLI configured with appropriate permissions
- [eksctl](https://eksctl.io/) installed
- [Helm](https://helm.sh/docs/intro/install/) installed
- [vCluster CLI](https://www.vcluster.com/docs/get-started) installed

## Overview

| File | Purpose |
|------|---------|
| `eksctl.yaml` | EKS cluster definition — Kubernetes 1.30, Karpenter, OIDC, managed node groups, and EBS CSI driver |
| `gp3.yaml` | GP3 StorageClass set as the default, backed by the EBS CSI driver |

The `eksctl.yaml` configures:
- **OIDC** — Enables IAM Roles for Service Accounts (IRSA) used by external-dns, cert-manager, and the AWS Load Balancer Controller.
- **Karpenter** — Cluster autoscaler with Spot Interruption Queue support.
- **Managed node group** — Small `t3a.small` group that bootstraps the cluster; Karpenter handles scaling beyond that.
- **Addons** — VPC CNI, CoreDNS, kube-proxy, and EBS CSI driver with appropriate IAM policies.

## Steps

### 1. Create the EKS cluster

```bash
eksctl create cluster -f eksctl.yaml
```

This takes 15–20 minutes. Once complete, eksctl updates your kubeconfig automatically.

### 2. Set GP3 as the default StorageClass

The default EKS GP2 StorageClass should be removed or marked non-default before applying `gp3.yaml`.

```bash
# Remove the default annotation from the gp2 StorageClass
kubectl patch storageclass gp2 -p '{"metadata": {"annotations": {"storageclass.kubernetes.io/is-default-class": "false"}}}'

# Apply the GP3 StorageClass
kubectl apply -f gp3.yaml
```

### 3. Verify the storage class

```bash
kubectl get storageclass
```

`gp3` should appear with `(default)` in the output.

### 4. Install vCluster Platform

Follow the [vCluster Platform installation guide](https://www.vcluster.com/docs/platform/install/quick-start-guide) to install the platform on your EKS cluster. Use Helm:

```bash
helm repo add loft-sh https://charts.loft.sh
helm repo update
helm upgrade --install vcluster-platform loft-sh/vcluster-platform \
  --namespace vcluster-platform \
  --create-namespace
```

### 5. Access vCluster Platform

```bash
# Get the platform URL
kubectl get service -n vcluster-platform
```

Follow the [initial setup guide](https://www.vcluster.com/docs/platform/install/quick-start-guide) to configure admin credentials and create your first virtual cluster.

## Notes

- The `eksctl.yaml` uses `us-west-1` and cluster name `eks-vcluster-platform`. Update these to match your environment.
- The Karpenter version (`v0.31.3`) should be kept in sync with your EKS cluster version — check [Karpenter compatibility](https://karpenter.sh/docs/upgrading/compatibility/) for the latest recommended version.
- Service account IAM policies for `external-dns`, `cert-manager`, and `aws-load-balancer-controller` are pre-wired via `wellKnownPolicies`. You still need to deploy those tools separately.

## Cleanup

```bash
eksctl delete cluster -f eksctl.yaml
```

## Learn More

- [vCluster Platform docs](https://www.vcluster.com/docs/platform/)
- [eksctl docs](https://eksctl.io/introduction/)
- [Karpenter docs](https://karpenter.sh/)
- Community: [https://slack.vcluster.com](https://slack.vcluster.com)
