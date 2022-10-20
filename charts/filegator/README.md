# FileGator



![Version: 1.0.0](https://img.shields.io/badge/Version-1.0.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: v7.8.7](https://img.shields.io/badge/AppVersion-v7.8.7-informational?style=flat-square) 

Deploys the 'FileGator' web file sharing solution

**Homepage:** <https://github.com/jan-tee/helm-charts>

Deploys the FileGator application with or without persistent storage and with anonymous ("guest") access enabled.

Example deployment:

```bash
helm repo add tietze.io https://charts.tietze.io
helm upgrade --install \
  filegator . \
  --set persistence.enabled=true \ 
  --set persistence.repository.volume.storageClassName=nfs \ 
  --set persistence.private.volume.storageClassName=nfs \ 
  --set service.annotations."external-dns\.alpha\.kubernetes\.io/hostname"="filegator.customer.lab" \
  --set defaults.password="mypassword"
```

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| Jan Tietze | <jan@tietze.io> | <http://tietze.io> |





## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| defaults.password | string | `nil` | Default password for admin user |
| image | string | `nil` | The image to use. Defaults to ubuntu/bind9 and in the chart's `appVersion`. |
| imagePullSecrets | string | `nil` | The name of the registry secret to use |
| persistence.enabled | bool | `true` | Set to `true` to enable persistence  |
| persistence.private | object | `{"volume":{"accessModes":["ReadWriteOnce"],"resources":{"requests":{"storage":"100M"}}}}` | The data for the `PersistentVolumeClaim` for config storage. Typically you'll want to add at least a storageClassName |
| persistence.repository | object | `{"volume":{"accessModes":["ReadWriteOnce"],"resources":{"requests":{"storage":"2Gi"}}}}` | The data for the `PersistentVolumeClaim` for data storage. Typically you'll want to add at least a storageClassName |
| service | object | `{"annotations":{}}` | Service settings |
| service.annotations | object | `{}` | object Annotations to add to the service |