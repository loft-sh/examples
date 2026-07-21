# GitHub Actions + vCluster Platform — PR Preview Environments

This example shows how to use GitHub Actions to automatically create and delete ephemeral vCluster preview environments when a pull request is labeled. When a PR receives the `preview` label, an action spins up a vCluster on vCluster Platform and deploys the application to it. When the label is removed or the PR is closed, the cluster is deleted.

## Prerequisites

- GitHub Account and public repository
- Kubernetes cluster with vCluster Platform installed
- nginx ingress controller on the host cluster
- Wildcard DNS or DNS record for ingress access

## Overview

| File | Purpose |
|------|---------|
| `create-preview-environment.yaml` | GitHub Actions workflow — triggered when `preview` label is added to a PR; creates the vCluster and deploys the app |
| `delete-preview-environment.yaml` | GitHub Actions workflow — triggered when `preview` label is removed or PR is closed; deletes the vCluster |
| `preview-template.yaml` | vCluster Platform template — configures ingress sync and auto-sleep after 1 hour of inactivity |
| `my-app/my-app.yaml` | Sample application deployment referenced by the create workflow |

### Workflow summary

1. Developer opens a PR targeting `main`.
2. Developer adds the `preview` label.
3. `create-preview-environment.yaml` runs:
   - Installs the vCluster CLI.
   - Logs in to vCluster Platform using `VCLUSTER_PLATFORM_URL` and `VCLUSTER_ACCESS_KEY` secrets.
   - Creates a vCluster named `pr-<number>` using the `preview-template`.
   - Checks out the PR branch and deploys `./deployments/my-app.yaml` to the vCluster.
4. Developer removes the `preview` label (or the PR is merged/closed).
5. `delete-preview-environment.yaml` runs and deletes the `pr-<number>` vCluster.

## Steps

### 1. Create a template in vCluster Platform

Apply `preview-template.yaml` to your vCluster Platform instance to register the template:

```bash
kubectl apply -f preview-template.yaml
```

The template enables ingress sync and sets auto-sleep to 1 hour.

### 2. Create GitHub Secrets

In your repository, go to **Settings → Secrets and variables → Actions** and add:

| Secret | Value |
|--------|-------|
| `VCLUSTER_PLATFORM_URL` | Your publicly accessible vCluster Platform URL (e.g. `https://vcluster.example.com`) |
| `VCLUSTER_ACCESS_KEY` | An access key from vCluster Platform ([how to create one](https://www.vcluster.com/docs/platform/administer/users-permissions/access-keys)) |

### 3. Add the GitHub Actions workflows

Copy `create-preview-environment.yaml` and `delete-preview-environment.yaml` to `.github/workflows/` in your repository. Update the preview application hostname in `create-preview-environment.yaml` (`--link "Preview=http://app.vcluster-demo.local"`) to match your ingress setup.

### 4. Add your application deployment

Create `deployments/my-app.yaml` in your repository. Update the ingress hostname in the file to match your environment. A sample file is provided in `my-app/my-app.yaml`.

### 5. Create a pull request and apply the label

Open a PR targeting `main`, then add the `preview` label. The create workflow will run automatically.

### 6. Verify the deployment

Check the vCluster Platform UI or CLI to see the created cluster:

```bash
vcluster platform list vclusters --project default
```

### 7. Delete the preview environment

Remove the `preview` label from the PR. The delete workflow will run and tear down the vCluster.

## Cleanup

Clusters are deleted automatically by the workflow. To delete manually:

```bash
vcluster platform delete vcluster pr-<number> --project default
```

## Learn More

- [vCluster Platform docs](https://www.vcluster.com/docs/platform/)
- [vCluster Platform access keys](https://www.vcluster.com/docs/platform/administer/users-permissions/access-keys)
- Community: [https://slack.vcluster.com](https://slack.vcluster.com)
