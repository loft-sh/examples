# Local LLM on vCluster with the Nvidia GPU Operator

In this demo we are going to configure time-slicing. We will then deploy two virtual clusters. Within the virtual clusters we will deploy Open-WebUI and then download a model from Ollam. The model used will need to be smaller than half of the memory we have on the graphics card since we are going to load multiple models.

## Installing the GPU Operator

We are going to start out by making sure we are using the right context. In our demo we are going to use the ai context.

```sh
kubectx
```

Now that we have selected the correct context, let's go ahead and install the GPU operator.

```sh
helm install --wait --generate-name -n gpu-operator --create-namespace nvidia/gpu-operator --version=v25.3.0
```

Next we need to add the timeslicing configmap. This will let the GPU operator know that we are going to be using timeslicing. If we want to use run multiple workloads on the same GPU then we need timeslicing or MIG (Multi-Instance GPU). Timeslicing can also be used in addition to MIG.

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: time-slicing-config-all
  namespace: gpu-operator
data:
  any: |-
    version: v1
    flags:
      migStrategy: none
    sharing:
      timeSlicing:
        resources:
        - name: nvidia.com/gpu
          replicas: 4
```

```sh
kubectl create -f time-slicing-config-all.yaml
```

We created the configmap but we need to patch the cluster-policy.

```sh
 kubectl patch clusterpolicy/cluster-policy -n gpu-operator --type merge -p '{"spec": {"devicePlugin": {"config": {"name": "time-slicing-config-all", "default": "any"}}}}'
```

Now we can describe the node and see the gpu count and the gpu relicas. We have 1 GPU and we have split it into 4 available replicas. In a production environment you would expect more GPUs and more replicas on those GPUs. The amount of replicas will depend on your needs.

```sh
kubectl describe node mai | grep -i gpu.count && kubectl describe node mai | grep -i gpu.replicas
```

## Setup for the vCluster to use an ingress controller + DNS

We definitely need an ingress controller on the host cluster and a loadbalancer. In this setup we are using MetalLB with an On-Prem Bare Metal K3s installation. For more information about how to set that up, check out this video (https://youtu.be/AsYEYoLW-Uk)

```sh
kubectl get services -n nginx-ingress | grep -i loadbalancer
```

For this demo we're actually just updating /etc/hosts to point to the LoadBalancer instead of configuring real DNS, however in a production environment you would want to configure DNS either locally through a DNS service or if using a public cloud you could use your registrar / DNS host with a DNS record. Here we are just showing that /etc/hosts has four records that we are going to use when we configure ingress.

```sh
grep -i vcluster.ai /etc/hosts
```

## Deploying our first vCluster

Using the vCluster CLI we can list out the current virtual clusters. We currently do not have any deployed.

```sh
vcluster list
```

Let's take a look at the vcluster.yaml file. We need to configure a couple of things. First we need the ingressclass synced from the host cluster to the vCluster, we also need the ingress resources within the vCluster to sync to the host cluster, finally we need to sync nodes.

```yaml
sync:
  fromHost:
    ingressClasses:
      enabled: true
    nodes:
      enabled: true
  toHost:
    ingresses:
      enabled: true
```

Now it's time to create the vCluster. Using the vCluster CLI and the vcluster.yaml file we can create it using this command:

```sh
vcluster create ts1 -n ts1 -f vcluster.yaml
```

After the vCluster has been created, if you have a container engine installed (like Docker) it will bring up a container and port forward for you. If you aren't using Docker Desktop then it will port forward in the current terminal. We're going to use the port forwarding container to connect to the vCluster, however you can also add ingress in front if you want to access it over a hostname.

Let's check the context to make sure we're using the right one before installing the GPU-Operator in the virtual cluster.

```sh
kubectx
```

Time to install the GPU Operator. We're going to disable a couple of things since we have the full operator running on the host cluster. Install with the command below which disables the driver and toolkit.

```sh
helm install --wait --generate-name -n gpu-operator --create-namespace nvidia/gpu-operator --version=v25.3.0 --set driver.enabled=false --set toolkit.enabled=false --set nfd.enabled=false
```

```sh
kubectl create -f time-slicing-config-all.yaml
```

```sh
 kubectl patch clusterpolicy/cluster-policy -n gpu-operator --type merge -p '{"spec": {"devicePlugin": {"config": {"name": "time-slicing-config-all", "default": "any"}}}}'
```

```sh
kubectl describe node mai | grep -i gpu.count && kubectl describe node mai | grep -i gpu.replicas
```

## Installing the first instances of Open-WebUI

Now we can install the open-webui in vCluster. In this demo we are going to use ollama, so we need to set a couple of values to make sure it knows what to use. We're using the gpu type of Nvidia and allocating 1 GPU, and we're using the nvidia runtimeClass. If you install without these options it will try to use the CPU instead.

```sh
helm install open-webui open-webui/open-webui --set image.tag=ollama --set ollama.ollama.gpu.enabled=true --set ollama.ollama.gpu.number=1 --set ollama.ollama.gpu.type=nvidia --set ollama.runtimeClassName=nvidia
```

Let's create the ingress resource so that we can interact with the UI from our desktop.

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: open-webui-ingress
spec:
  ingressClassName: nginx
  rules:
  - host: ts1.vcluster.ai
    http:
      paths:
      - backend:
          service:
            name: open-webui
            port:
              number: 80
        path: /
        pathType: ImplementationSpecific
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: ollama-open-webui-ingress
spec:
  ingressClassName: nginx
  rules:
  - host: ots1.vcluster.ai
    http:
      paths:
      - backend:
          service:
            name: open-webui-ollama
            port:
              number: 11434
        path: /
        pathType: ImplementationSpecific
```

```sh
kubectl create -f ts1-ingress.yaml
```

Check on the ingress resource to make sure it finishes deploying.

```sh
kubectl get ingress
```

Now we can open the UI in Firefox and fill in the required information to log in.

```sh
open -a Firefox "http://ts1.vcluster.ai"
```

Time to disconnect from the current vCluster so we can deploy another one.

```sh
vcluster disconnect
```

## Deploying our second vCluster

These commmands are going to mirror what we just did above however we're creating a ts2 vCluster and a ts2 ingress resource.

```sh
vcluster create ts2 -n ts2 -f vcluster.yaml
```

```sh
kubectx
```

```sh
helm install --wait --generate-name -n gpu-operator --create-namespace nvidia/gpu-operator --version=v25.3.0 --set driver.enabled=false --set toolkit.enabled=false --set nfd.enabled=false
```

```sh
kubectl create -f time-slicing-config-all.yaml
```

```sh
kubectl patch clusterpolicy/cluster-policy -n gpu-operator --type merge -p '{"spec": {"devicePlugin": {"config": {"name": "time-slicing-config-all", "default": "any"}}}}'
```

```sh
kubectl describe node mai | grep -i gpu.count && kubectl describe node mai | grep -i gpu.replicas
```

```sh
helm install open-webui open-webui/open-webui --set image.tag=ollama --set ollama.ollama.gpu.enabled=true --set ollama.ollama.gpu.number=1 --set ollama.ollama.gpu.type=nvidia --set ollama.runtimeClassName=nvidia
```

```sh
kubectl create -f ts2-ingress.yaml
```

```sh
kubectl get ingress
```

```sh
open -a Firefox "http://ts2.vcluster.ai"
```

## VS Code and Continue

Now that we have everything running we can connect Continue to it in VS Code.