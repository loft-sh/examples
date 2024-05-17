# MetalLB + NGINX + vCluster

## Commands Used

### Install MetalLB

`kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.14.5/config/manifests/metallb-native.yaml`

### Configure MetalLB

Update the metallb.yaml file so that it uses an IP address range within your network.

`kubectl create -f metallb.yaml`

### Install NGINX

`helm install nginx-ingress --create-namespace -n nginx-ingress ingress-nginx/ingress-nginx --set "controller.extraArgs.enable-ssl-passthrough=true"`

### Create a virtual cluster

Update the vcluster.yaml file with your hostname. If you are testing locally then you can edit /etc/hosts and add the record. In my example I am using:

192.168.86.15   demo.vcluster.local

`vcluster create --connect=false --upgrade demo-vcluster -n demo-vcluster -f vcluster.yaml`

`vcluster list`

### Connect to the virutal cluster and pull the kubeconfig

`vcluster connect demo-vcluster --update-current=false --server=https://demo.vcluster.local`

## Troubleshooting

If you run into issues with the virtual cluster not starting - verify that the ingress resource was created. If the ingress resource is missing a class, check your ingress controller to verify that it has been set to default. If you want to specify the ingress resource within the vCluster.yaml file you can use this under the ingress option:

ingressClass: "nginx" # Replace nginx with the ingressClass you are using if not using nginx