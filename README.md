# Examples

Practical, copy-paste-ready examples for [vCluster](https://www.vcluster.com/), [DevPod](https://devpod.sh/), and related Loft tools. Each example lives in its own directory with a README that walks you through the setup from scratch.

## vCluster Examples

Virtual Kubernetes clusters for multi-tenancy, isolation, and GitOps workflows.

| Example | Description |
|---------|-------------|
| [argocd-helm-vcluster](./vcluster/argocd-helm-vcluster/) | Deploy and manage vClusters using ArgoCD and Helm |
| [cert-manager-integration](./vcluster/cert-manager-integration/) | Native cert-manager integration — issue TLS certs inside a vCluster using the host's cert-manager |
| [eks-vcluster-platform](./vcluster/eks-vcluster-platform/) | EKS cluster setup (Karpenter, OIDC, GP3) for running vCluster Platform |
| [github-actions](./vcluster/github-actions/) | PR preview environments using GitHub Actions and vCluster Platform |
| [ingress-sync-oss](./vcluster/ingress-sync-oss/) | Expose apps inside a vCluster via the host's nginx ingress controller |
| [kyverno-demo](./vcluster/kyverno-demo/) | Apply host Kyverno policies to workloads running inside a vCluster |
| [metallb-nginx-vcluster](./vcluster/metallb-nginx-vcluster/) | vCluster with MetalLB (bare-metal LoadBalancer) and nginx ingress |
| [sleep_mode](./vcluster/sleep_mode/) | Auto-sleep idle vClusters with vCluster Platform to reduce resource usage |
| [snapshot-restore](./vcluster/snapshot-restore/) | Point-in-time OCI snapshots of a vCluster and restore from them |
| [sync-resources-from-vcluster](./vcluster/sync-resources-from-vcluster/) | Sync Ingress and other resources from a vCluster to the host cluster |
| [terraform-helm-vcluster](./vcluster/terraform-helm-vcluster/) | Infrastructure-as-code vCluster lifecycle management with Terraform |
| [vcluster-crd-sync](./vcluster/vcluster-crd-sync/) | Bidirectional CRD sync (cert-manager resources) between vCluster and host |
| [vcluster-llm-demo](./vcluster/vcluster-llm-demo/) | Run local LLMs (Ollama + Open-WebUI) on GPU-equipped vClusters |
| [vcluster-yaml-examples](./vcluster/vcluster-yaml-examples/) | Reference vcluster.yaml configs for ingress and external database |
| [whiteboarding-vcluster](./vcluster/whiteboarding-vcluster/) | Architecture diagram from the vCluster webinar whiteboarding session |

See [vcluster/README.md](./vcluster/README.md) for more detail on each example.

## DevPod Examples

Cloud development environments that work with any IDE.

| Example | Description |
|---------|-------------|
| [jupyter-notebook-hello-world](./devpod/jupyter-notebook-hello-world/) | Launch a Jupyter notebook dev environment with DevPod |

## DevSpace Examples

Coming soon.

## Loft Examples

Coming soon.

## Community

Questions or feedback? Join us on Slack: [https://slack.vcluster.com](https://slack.vcluster.com)
