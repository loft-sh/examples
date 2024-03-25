# vCluster Sync

These are the resources that are associated with the YouTube video on vCluster Sync:

https://youtu.be/6dIplR8_z38

Note - updates need to be made to many of the files to match your domain.

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

## Cert-Manager

Next up we need to install Cert-Manager on the base cluster. This will allow us to request certificates for the subdomains we create for our applications running within the virtual cluster.

https://cert-manager.io/docs/installation/kubectl/

Note - the version can change in the command below depending on the current version that is available, so check with the documentation to see the latest version.

`kubectl apply -f https://github.com/cert-manager/releases/download/v1.13.3/cert-manager.yaml`

Now that we have Cert-Manager configured we can create a cluster-issuer. The file used for the cluster-issuer needs an update before you apply it, add your email address so you can be updated when your certificates are expiring.

`kubectl create -f cluster-issuer.yaml`

# vCluster

## Namespace

Now we can move on to creating our vCluster. Start out by creating the namespace, we'll need this to install the vCluster.

`kubectl create namespace demo-vcluster`

## Ingress

Then we can create the ingress resource needed to expose our vCluster API endpoint. The ingress resource we are using is for nginx, if you are using a different ingress controller then some of the configuration options will need to be updated, such as annotations and ingressClassName. We are installing this into the same namespace `demo-vcluster` which is configured within the yaml.

`kubectl create -f demo-vcluster-ingress.yaml`

## Install the vCluster

Now we can install the vCluster using our values file. If you look at the values file we have configured a couple of things. We set the domain and then also set ingress to sync so that we can create ingerss resources within the vCluster and have them sync to the base cluster.

`vcluster create demo-vcluster --namespace demo-vcluster --connect=false -f values.yaml`