# vCluster Examples

Practical examples for [vCluster](https://www.vcluster.com/) — virtual Kubernetes clusters that run inside a host cluster. Each example is self-contained with its own README and YAML files.

## Video Tutorials

Many of these examples have companion walkthroughs on the **[vCluster YouTube channel](https://www.youtube.com/@vcluster)**. Subscribe to stay up to date with new demos and feature releases.

## Examples

| Example | Description | Key Technologies |
|---------|-------------|-----------------|
| [argocd-helm-vcluster](./argocd-helm-vcluster/) | Manage the full vCluster lifecycle declaratively with ArgoCD — create, update, and delete virtual clusters via a Helm-backed Application manifest. Good starting point for GitOps-driven platform teams. | ArgoCD, Helm, nginx ingress |
| [cert-manager-integration](./cert-manager-integration/) | Use cert-manager running on the host cluster to issue TLS certificates for workloads inside a vCluster, with no plugin needed. Demonstrates the native `integrations.certManager` config option. | cert-manager, nginx ingress |
| [eks-vcluster-platform](./eks-vcluster-platform/) | Reference eksctl config for an EKS cluster sized for vCluster Platform — includes Karpenter, OIDC/IRSA, IAM service accounts, and GP3 as the default storage class. | EKS, eksctl, Karpenter |
| [github-actions](./github-actions/) | Spin up an ephemeral vCluster per pull request automatically: add the `preview` label to create, remove it to destroy. Covers GitHub Actions workflows and vCluster Platform templates. | GitHub Actions, vCluster Platform |
| [ingress-sync-oss](./ingress-sync-oss/) | Deploy the 2048 game inside a vCluster and expose it over HTTPS using the host's nginx ingress and Let's Encrypt. Shows how `sync.toHost.ingresses` and `sync.fromHost.ingressClasses` work together. | nginx ingress, cert-manager, Let's Encrypt |
| [kyverno-demo](./kyverno-demo/) | Show that Kyverno policies installed on the host cluster automatically govern workloads created inside any vCluster — ideal for demonstrating centralized policy enforcement across tenants. | Kyverno |
| [metallb-nginx-vcluster](./metallb-nginx-vcluster/) | Set up vCluster on a bare-metal or on-prem cluster where MetalLB provides LoadBalancer IPs and nginx handles ingress. Exposes the vCluster API over a hostname without a cloud load balancer. | MetalLB, nginx ingress |
| [sleep_mode](./sleep_mode/) | Automatically pause idle vClusters after a configurable inactivity period using vCluster Platform's sleep mode, then wake them on the next API or ingress request. Reduces host cluster resource consumption. | vCluster Platform |
| [snapshot-restore](./snapshot-restore/) | Take an OCI image-based point-in-time snapshot of a vCluster and restore it in-place or use it to create a fresh cluster from the saved state. | OCI / Docker Hub |
| [sync-resources-from-vcluster](./sync-resources-from-vcluster/) | Create Ingress resources inside a vCluster and have them automatically sync to the host cluster, where nginx and cert-manager handle routing and TLS termination. | nginx ingress, cert-manager |
| [terraform-helm-vcluster](./terraform-helm-vcluster/) | Manage the vCluster Helm release with Terraform — create, update, and destroy virtual clusters as part of an existing infrastructure-as-code pipeline. | Terraform, Helm |
| [vcluster-crd-sync](./vcluster-crd-sync/) | Bidirectional CRD sync with cert-manager: host ClusterIssuers appear read-only inside the vCluster; Certificates, Issuers, and Ingresses created inside the vCluster sync back to the host for processing. | cert-manager, nginx ingress |
| [vcluster-llm-demo](./vcluster-llm-demo/) | Run two isolated Ollama + Open-WebUI instances on a single GPU using NVIDIA time-slicing — each deployed inside its own vCluster for tenant isolation. | NVIDIA GPU Operator, Ollama, Open-WebUI, MetalLB |
| [vcluster-yaml-examples](./vcluster-yaml-examples/) | Two reference `vcluster.yaml` configs: one enabling nginx ingress for the vCluster API with bidirectional ingress sync, another switching the backing datastore to external MySQL. | Helm |
| [whiteboarding-vcluster](./whiteboarding-vcluster/) | Architecture diagram from a vCluster webinar whiteboarding session illustrating the virtual control plane, sync loop, and host node relationship. | — |

## Getting Started

Install the vCluster CLI:

```bash
curl -L -o vcluster "https://github.com/loft-sh/vcluster/releases/latest/download/vcluster-linux-amd64" \
  && sudo install -c -m 0755 vcluster /usr/local/bin && rm -f vcluster
```

Or follow the [official install guide](https://www.vcluster.com/docs/get-started) for your platform.

## Learn More

- [vCluster Documentation](https://www.vcluster.com/docs/vcluster/)
- [vcluster.yaml Configuration Reference](https://www.vcluster.com/docs/vcluster/configure/vcluster-yaml/)
- [vCluster YouTube Channel](https://www.youtube.com/@vcluster) — video walkthroughs and feature demos
- Community: [https://slack.vcluster.com](https://slack.vcluster.com)
