# Kyverno + vCluster

This example demonstrates how Kyverno policies installed on the host cluster automatically apply to workloads scheduled by a vCluster. Because vCluster runs virtual cluster workloads as pods on the host, any Kyverno policy that targets Pod or Service resources on the host also governs resources created inside the vCluster — giving platform teams centralized policy enforcement across all virtual clusters.

## Prerequisites

- vCluster CLI installed ([install guide](https://www.vcluster.com/docs/get-started))
- Kubernetes cluster (host)

## Steps

### Step 1: Create a vCluster

```bash
vcluster create my-vcluster --namespace vcluster
```

Wait for the vCluster to be ready:

```bash
kubectl wait --for=condition=ready pod -l app=vcluster --timeout=300s -n vcluster
kubectl get pods -n vcluster
```

### Step 2: Connect to the vCluster

```bash
vcluster connect my-vcluster -n vcluster
```

### Step 3: Install Kyverno on the **host cluster**

Open a second terminal (or disconnect first), then install Kyverno on the host:

```bash
# Disconnect from vCluster context first
vcluster disconnect

kubectl create -f https://github.com/kyverno/kyverno/releases/download/v1.13.0/install.yaml
```

Wait for Kyverno to be ready:

```bash
kubectl wait --for=condition=Available deployment --all -n kyverno --timeout=120s
```

### Step 4: Apply a policy on the host cluster

The following policy prevents any Service of type `NodePort` from being created — on the host or inside any vCluster:

```bash
cat << EOF | kubectl apply -f -
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: restrict-nodeport
  annotations:
    policies.kyverno.io/title: Disallow NodePort
    policies.kyverno.io/category: Best Practices
    policies.kyverno.io/minversion: 1.6.0
    policies.kyverno.io/severity: medium
    policies.kyverno.io/subject: Service
    policies.kyverno.io/description: >-
      A Kubernetes Service of type NodePort uses a host port to receive traffic from
      any source. A NetworkPolicy cannot be used to control traffic to host ports.
      Although NodePort Services can be useful, their use must be limited to Services
      with additional upstream security checks. This policy validates that any new Services
      do not use the NodePort type.
spec:
  validationFailureAction: enforce
  background: true
  rules:
  - name: validate-nodeport
    match:
      any:
      - resources:
          kinds:
          - Service
    validate:
      message: "Services of type NodePort are not allowed."
      pattern:
        spec:
          =(type): "!NodePort"
EOF
```

### Step 5: Test the policy from inside the vCluster

Connect to the vCluster and attempt to create a NodePort service:

```bash
vcluster connect my-vcluster -n vcluster
```

```bash
kubectl create service nodeport test-nodeport --tcp=80:80
```

You should see a Kyverno denial error. The policy is enforced even though the request originates from inside the vCluster.

## Cleanup

```bash
vcluster disconnect
vcluster delete my-vcluster -n vcluster
kubectl delete namespace vcluster
kubectl delete -f https://github.com/kyverno/kyverno/releases/download/v1.13.0/install.yaml
```

## Learn More

- [vCluster docs](https://www.vcluster.com/docs/vcluster/)
- [Kyverno docs](https://kyverno.io/docs/)
- Community: [https://slack.vcluster.com](https://slack.vcluster.com)
