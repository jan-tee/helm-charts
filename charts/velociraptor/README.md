# velociraptor



![Version: 1.0.0](https://img.shields.io/badge/Version-1.0.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 0.6.7-4](https://img.shields.io/badge/AppVersion-0.6.7--4-informational?style=flat-square) 

Velociraptor Helm chart for deployment in Kubernetes

**Homepage:** <https://github.com/jan-tee/helm-charts>

This is a simple helm chart to deploy a single-server Ubuntu-based Velociraptor server container in Kubernetes. It will deploy:

- The Velociraptor server (frontend, API, GUI)
- The frontend will be deployed to `https://<DNS name>` (port 443)
- API (8001) and frontend (8000) will be deployed to their standard ports
- On port 9000, a `nginx` will be deployed that serves repacked client binaries including configuration, and a MSI with `velociraptor.msi` and `velociraptor.yaml` for MSI-based Windows installs
- A link to the nginx server with the client binaries is added to the Velociraptor GUI

*NOTE*: _Multi-server ("cloud") deployments are not yet supported, but will be supported at a later date._

To deploy, typically you will generate certificates (e.g. using `cert-manager`) first and have them stored as a secret.

To install, add the repo and deploy:

```bash
helm repo add tietze.io https://charts.tietze.io
helm upgrade --install -n prod raptor \
    velociraptor/ \
    --set tls.secretName="<secretName, e.g. kuberaptor.customer.lab-tls>" \
    --set server_name="<DNS name that agents use to reach this instance>" \
    --set persistence.volume.storageClassName=nfs \
    --set imagePullSecrets=ghcr-pat \
    --set image=ghcr.io/jan-tee/velociraptor-docker/velociraptor:0.0.3 \
    --set admin_user=<admin user> ^
    --set admin_password=<password>
```
To e.g. register the DNS name for the service with `externald-dns`, you can add service annotations:

```
    --set service.annotations."external-dns\.alpha\.kubernetes\.io/hostname"="my.dns.name"
```

## FAQ

*Why does this use a special image for Velociraptor and not the 'official' wlambert Docker image?*

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| Jan Tietze | <jan@tietze.io> | <http://tietze.io> |





## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| admin_password | string | `nil` | The administrator password |
| admin_user | string | `"admin"` | The administrator's user name |
| image | string | `"ghcr.io/jan-tee/velociraptor-docker/velociraptor:latest"` | The image to use. Defaults to ubuntu/bind9 and in the chart's `appVersion`. |
| imagePullSecrets | string | `nil` | The name of the registry secret to use |
| persistence.volume | object | `{"accessModes":["ReadWriteOnce"],"resources":{"requests":{"storage":"10Gi"}}}` | The data for the `PersistentVolumeClaim` for state storage. Typically you'll want to add at least a storageClassName |
| server_name | string | `nil` | The DNS name that a browser connects to |
| service | object | `{"annotations":{},"type":"LoadBalancer"}` | Service settings |
| service.annotations | object | `{}` | object Annotations to add to the service |
| service.type | string | `"LoadBalancer"` | Service type |
| tls.secretName | string | `nil` | Name of the TLS secret |