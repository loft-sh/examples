# Argo CD + Helm + vCluster

## Steps

### Install the vCluster CLI

https://www.vcluster.com/docs/get-started


### Some Pre-reqs
Next, you'll need access to a Kubernetes cluster with the KubeConfig matching the location in the main.tf. In the example I also already have an ingress controller running on the base cluster - nginx. You will need an ingress controller on the host cluster to get ingress configured for access to the vCluster API. Check out this video if you need help:

https://youtu.be/0ic7oe8fd4o

### Create an application in Argo CD using the application.yaml file

Next use the reference file and update the name, namespace, and hostname.

### Accessing the virtual cluster using the vcluster cli

`vcluster connect demo-vcluster --update-current=false --server=https://demo.vcluster.local`

## Conclusion

If you run into any issues, reach out to us on slack - slack.loft.sh