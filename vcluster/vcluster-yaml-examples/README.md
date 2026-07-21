# vCluster YAML Examples

Reference `vcluster.yaml` configuration files showing two common vCluster setups: ingress-based API access with bidirectional ingress sync, and an external MySQL datastore replacing the built-in etcd.

## Files

### `vcluster.yaml` — Ingress-enabled API with ingress sync

This configuration:
- Exposes the vCluster API over a hostname via an nginx Ingress resource on the host cluster.
- Adds the hostname as a TLS SAN so `kubectl` trusts the API server certificate.
- Syncs IngressClasses from the host into the vCluster (so you can use them in Ingress resources inside the vCluster).
- Syncs Ingress resources created inside the vCluster back to the host cluster (so nginx routes external traffic to your in-cluster apps).

**Before use:** Replace `demo.vcluster.local` with your actual hostname.

```bash
vcluster create my-vcluster -n my-vcluster -f vcluster.yaml
```

### `vcluster-db.yaml` — External MySQL datastore

This configuration replaces the default embedded database with an external MySQL instance. Useful when you want to persist vCluster state independently of the vCluster pod, or when running in a highly available setup.

**Before use:** Update the MySQL connection string to match your environment:
```
mysql://root:password@tcp(192.168.86.9:30360)/vcluster
         ^^^^  ^^^^^^^^     ^^^^^^^^^^^^^  ^^^^^  ^^^^^^^
         user  password     hostname/IP    port   database name
```

The example uses a local IP (`192.168.86.9`) and NodePort (`30360`) — replace with your MySQL host address and port.

```bash
vcluster create my-vcluster-db -n my-vcluster-db -f vcluster-db.yaml
```

## Learn More

- [vcluster.yaml Configuration Reference](https://www.vcluster.com/docs/vcluster/configure/vcluster-yaml/)
- [vCluster ingress configuration](https://www.vcluster.com/docs/vcluster/configure/vcluster-yaml/control-plane/other/ingress)
- [vCluster external datastore docs](https://www.vcluster.com/docs/vcluster/configure/vcluster-yaml/control-plane/backing-store/database/external)
- Community: [https://slack.vcluster.com](https://slack.vcluster.com)
