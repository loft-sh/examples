# This folder includes the commands used in the snapshot and restore video as well as the files used

The Docker commands assume that I'm logged into Docker. I'm using Docker Desktop to login so that I can upload images + build on a Mac. The commands are exact copies of the script I used for the video, which means you'll need to update some of the values. 

# Build Image

cat Dockerfile

cd html

cat index.html

open vs-rr.gif -a Firefox

cd ..

docker build -t mpetason/vs-rr:1987 --platform linux/amd64 .

docker push mpetason/vs-rr:1987

# Create vCluster

vcluster create test

kubectx

kubectl get crd

kubectl get namespace

kubectl create namespace testc

kubectl apply -f deployment.yaml -n test

kubectl get pods -n test

kubectl port-forward pods/nginx-deployment-6cbdc8c4c9-7vkx9 -n test 8080:80

Back to host Cluster

# OCI Snapshot

vcluster snapshot test oci://docker.io/mpetason/vcluster-test:snapshot1

# Break Stuff

kubectx

kubectl get crd

kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.17.0/cert-manager.yaml

kubectl get crd

# Host Cluster Restore

kubectx default

vcluster restore test oci://docker.io/mpetason/vcluster-test:snapshot1

vcluster list

vcluster connect test

kubectl get crd

# Host Cluster Create

vcluster delete test

vcluster list

vcluster create test --restore oci://docker.io/mpetason/vcluster-test:snapshot1

Look at timestamp of recreated vCluster - it shows a timestamp

kubectl get namespace

kubectl get pods -n test

kubectl port-forward pods/nginx-deployment-6cbdc8c4c9-7vkx9 -n test 8080:80

# Extras

# Local

So if you want to save the file locally you can do so. In future updates it might be easier to upate from a local file, however using the restore option right now assumes some type of endpoint instead of a local directory.

vcluster snapshot test "container:///data/test-snapshot.tar.gz"

kubectl cp vcluster-test/test-0:data/test-snapshot.tar.gz test-snapshot.tar.gz