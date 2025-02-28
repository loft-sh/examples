# Step 1: Install vCluster
```
helm repo add loft https://charts.loft.sh
helm repo update
kubectl create namespace vcluster
```

# Step2 Deploy vCluster
```
helm upgrade --install my-vcluster loft/vcluster -n vcluster -f vcluster-values.yaml
kubectl wait --for=condition=ready pod -l app=vcluster --timeout=300s -n vcluster
kubectl get pods -n vcluster
```

# Step3 Connect to vcluster
```
curl -L https://github.com/loft-sh/vcluster/releases/latest/download/vcluster-linux-amd64 -o /usr/local/bin/vcluster
chmod +x /usr/local/bin/vcluster
vcluster connect my-vcluster -n vcluster
```

# Step4 Install Kyverno on host cluster
```
kubectl create -f https://github.com/kyverno/kyverno/releases/download/v1.13.0/install.yaml

```
# Step5 Policy Creation 
```
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
      do not use the `NodePort` type.      
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

