# vCluster YAML

Examples from the vCluster.yaml video.

## Example 1 (vcluster.yaml)

The first example enables ingress for the vCluster API and also syncs ingressclasses from the host cluster to the vCluster. It also syncs ingress from the virtual cluster to the host cluster.

Change the hostname from `demo.vcluster.local` to hostname you are going to use for the virtual cluster.


## Example 2 (vcluster-db.yaml)

The second example changes the backing datastore for the virtual cluster. In the example, we are using MySQL.

Modify the MySQL string to match where MySQL is running. Update the user:password and change 192.168.86.9 to your hostname or IP address for MySQL. Then update the DB being used from vcluster to whatever you have created or are using.

 `"mysql://root:password@tcp(192.168.86.9:30360)/vcluster"`