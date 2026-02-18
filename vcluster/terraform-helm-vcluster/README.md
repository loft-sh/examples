# Terraform + Helm + vCluster

This example demonstrates infrastructure-as-code lifecycle management for vClusters using Terraform's Helm provider. Instead of running `vcluster create` manually, Terraform manages the vCluster Helm release — enabling version-controlled, repeatable deployments and integration with existing Terraform infrastructure pipelines.

## Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/install) installed
- vCluster CLI installed ([install guide](https://www.vcluster.com/docs/get-started))
- Kubernetes cluster with a valid kubeconfig at `~/.kube/config`
- nginx ingress controller on the host cluster (for the ingress-enabled API access)

## Overview

| File | Purpose |
|------|---------|
| `main.tf` | Terraform config — uses the `helm` provider to deploy the vCluster Helm chart |
| `vcluster.yaml` | vCluster values passed to Helm — enables ingress for the API and configures ingress sync |

The `main.tf` uses the `helm` provider pointing at `~/.kube/config` and deploys the `vcluster` chart from `https://charts.loft.sh` into the `terraform-vcluster` namespace.

> **Note:** `main.tf` pins the chart to version `0.20.0-beta.5`. Update the `version` field to a stable release before use. Check available versions at [https://charts.loft.sh](https://charts.loft.sh) or with:
> ```bash
> helm search repo loft-sh/vcluster --versions
> ```

## Steps

### 1. Update `vcluster.yaml`

Edit `vcluster.yaml` and replace `demo.vcluster.local` with the hostname you want to use for vCluster API access. The hostname must resolve to your nginx ingress controller's IP or load balancer.

### 2. Update `main.tf`

Update the `version` field in `main.tf` to a stable chart version, for example:

```hcl
version = "0.22.0"   # Replace with the latest stable version
```

### 3. Initialize Terraform

```bash
terraform init
```

### 4. Preview the changes

```bash
terraform plan
```

Review the output to confirm Terraform will create the `terraform-vcluster` namespace and Helm release.

### 5. Apply the configuration

```bash
terraform apply
```

Type `yes` when prompted. Terraform creates the vCluster and waits for it to be ready.

### 6. Connect to the vCluster

```bash
vcluster connect terraform-vcluster -n terraform-vcluster --update-current=false --server=https://demo.vcluster.local
```

Replace `demo.vcluster.local` with the hostname you configured.

## Cleanup

```bash
terraform destroy
```

Type `yes` when prompted. Terraform removes the Helm release and the namespace.

## Learn More

- [vCluster docs](https://www.vcluster.com/docs/vcluster/)
- [Terraform Helm provider docs](https://registry.terraform.io/providers/hashicorp/helm/latest/docs)
- [vcluster.yaml configuration reference](https://www.vcluster.com/docs/vcluster/configure/vcluster-yaml/)
- Community: [https://slack.vcluster.com](https://slack.vcluster.com)
