# vCluster Sync

These are the resources that are associated with the YouTube video on vCluster Sync:

https://youtu.be/6dIplR8_z38

# Install on the base cluster

Before creating the vCluster we need to get nginx and Cert-Manager running on the base cluster.

## Nginx Ingress Controller

https://docs.nginx.com/nginx-ingress-controller/installation/installing-nic/installation-with-helm/

Here is the one liner used in the video. We need to install nginx with ssl-passthrough enabled so that we can create an ingress resource to access the vCluster API:

`helm install nginx-ingress --create-namespace -n nginx-ingress ingress-nginx/ingress-nginx --set "controller.extraArgs.enable-ssl-passthrough=true`

Time to find the address for our LoadBalancer. This is the one liner used in the video to pull the automatically created EKS LoadBalancer (for our nginx ingress controller). 

`kubectl get service -n nginx-ingress | grep LoadBalancer | awk {'print $4'}`

The result is something like `UUID-us-west-1.elb.amazonaws.com` which we can then use to create a CNAME record for whichever resources we want to create in the cluster. If you're using a service that gives you an IP address for the LoadBalancer service then you would want to create an A record instead.

demo IN CNAME UUID-us-west-1.elb.amazonaws.com

