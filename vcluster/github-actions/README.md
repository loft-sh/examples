# GitHub Actions Example

In this example we will show how to use a GitHub action to create a virtual cluster with vCluster Platform. We will use tags on the pull request to both create and then delete the virtual cluster.

In our example we are just deploying my-app to the virtual cluster once it has been created. We will build on this idea in future examples so that we can create an image off of the code change, push it to Docker, and then deploy the new application. The scope of this example will introduce you to the ideas behind GitHub Actions and how to use them with vCluster.

# Requirements

GitHub Account and public repository
Kubernetes Cluster with vCluster Platform Installed
Ingress Controller installed on Base Cluster
Wildcard DNS or DNS Record for ingress resource


# Create a template

Create a template in vCluster Platform based on the preview-template.yaml file. This template will be referenced in the workflow. The configuration syncs Ingress Class from the host cluster and then sync the Ingress resource in the virtual cluster back to the Host cluster.


# Create GitHub Secrets

We will need secrets for a few of the settings in the workflow. Credentials are needed to connect to our vCluster Platform endpoint - so we'll need to configure:

VCLUSTER_PLATFORM_URL
VCLUSTER_ACCESS_KEY

The URL will be your publicly accessible vCluster Platform URL. The Access Key will need to be created. Follow along in the video or check out:

https://www.vcluster.com/docs/platform/administer/users-permissions/access-keys

# Create GitHub Actions

Create two GitHub actions using the create-preview-environment.yaml and delete-preview-environment.yaml. Update the create action with ingress hostname you're using for the application.

# Create the deployment

Create a folder and applictaion in your GitHub repository - deployments/my-app.yaml. Update the my-app.yaml's ingress hostname. In the next video / example we'll go over how to automate the ingress hostname so that it will be based on the PR-hostname-URL.

# Create a pull request

Create a pull request and update the image being used. In our example we're just using a "hello-universe" image. In a real environment we wouldn't use "latest" and would probably just update the image with the most recent tag. In the demo I just want to show a different message posted when we hit the preview environment. The image I'm using is `mpetason/hello-universe:latest` but you can use whatever image you want. 

Tag the pull request with `preview` - you'll probably need to create it so just type in preview in the label section and create a new one.

Once the `preview` tag has been added the create action will run. 

# Verify the deployment

Head back to the vCluster Platform UI (or cli) to see the new cluster that was created. The cluster should deploy the new application as well. As long as you have the DNS records configured for the hostname, you should be able to resolve and open the link. 

# Delete the virtual cluster

Remove the preview tag from the pull request. This will kick off the delete-preview-environment. 

# Demo Finished

That concludes the demo. If you run into any issues reach out to me on Slack - Mike Petersen.