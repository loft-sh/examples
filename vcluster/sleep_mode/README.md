## Install vcluster
------------------------------------------
```
curl -L -o vcluster "https://github.com/loft-sh/vcluster/releases/latest/download/vcluster-linux-amd64" && sudo install -c -m 0755 vcluster /usr/local/bin && rm -f vcluster
```

------------------------------------------
## Create vclsuter.yaml file
```
experimental:
  sleepMode:
    enabled: true
    autoSleep:
      afterInactivity: 2m # Reduced for demo purposes
      exclude:
        selector:
          labels:
            dont: sleep
```
----------------------------------------- 
Login to the platform 

```
vcluster login https://mydemo.vcluster.cloud --access-key JdyHwb1XtYERFHfhErHRrEqXTLYyClw;ofghw;jghwq;rlghdBJ3u2bw

```

`vcluster create demo -f demo.yaml`
-----------------------------------------
## Create Deployment 
```
kubectl create deployment nginx --image=nginx --replicas=3
kubectl expose deployment nginx --port=80 --target-port=80 --type=ClusterIP
```
----------------------------------------- 
#Install ingress controller
```
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
helm install ingress-nginx ingress-nginx/ingress-nginx \
  --namespace ingress-nginx \
  --create-namespace \
  --set controller.hostNetwork=true \
  --set controller.dnsPolicy=ClusterFirstWithHostNet \
  --set controller.service.type=ClusterIP
```
----------------------------------------- 
## Ingress Class
```
kubectl apply -f - <<EOF
apiVersion: networking.k8s.io/v1
kind: IngressClass
metadata:
  name: nginx
spec:
  controller: k8s.io/ingress-nginx
EOF
```
----------------------------------------- 
## Create ingress.yaml
```
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: nginx-ingress
  annotations:
    nginx.ingress.kubernetes.io/mirror-target: 'enabled'
spec:
  ingressClassName: nginx
  rules:
  - host: demo.10.97.108.209.nip.io
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: nginx
            port:
              number: 80
```
-----------------------------------------             
## Apply Label to Ingress controller deployment
`kubectl label deploy -n ingress-nginx ingress-nginx-controller dont=sleep`
----------------------------------------

