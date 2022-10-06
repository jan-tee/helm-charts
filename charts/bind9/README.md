# bind9



![Version: 1.0.3](https://img.shields.io/badge/Version-1.0.3-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 1.0.09.16-20.04_beta](https://img.shields.io/badge/AppVersion-1.0.09.16--20.04_beta-informational?style=flat-square) 

bind9 DNS Helm chart for simple RFC2136 dynamic DNS self-hosting

**Homepage:** <https://github.com/jan-tee/helm-charts>

This is a simple helm chart to deploy a Ubuntu-based BIND9 DNS server container that can self-host DNS zones that accept RFC2136 dynamic updates in Kubernetes. This is especially useful when deploying on-prem clusters for e.g. lab settings, such as k3s.

To deploy, typically you will generate a TSIG key to use for dynamic updates:

```
tsig-keygen -a hmac-sha256 k8s-external-dns
```

Then, add the repo and install:

```bash
helm repo add tietze.io https://charts.tietze.io
helm upgrade --install --namespace external-dns \
  authoritative-dns tietze.io/bind9 \
  --set service.annotations."metallb\.universe\.tf/loadBalancerIPs"="<IP for MetalLB>" \
  --set service.annotations."metallb\.universe\.tf/allow-shared-ip"="<key to share IP for TCP/UDP DNS in MetalLB>" \
  --set keys[0].name="k8s-external-dns" \
  --set keys[0].secret="<TSIG secret>" \
  --set zones[0].zone="k8s.lab" \
  --set zones[0].keys[0]="k8s-external-dns" \
  --set zones[0].records[0]="firewall IN A 192.168.42.1" \
  --set zones[0].records[1]="another-record IN A 192.168.42.100"
```







## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| extraFiles | list | `{"named.conf.local":"//\n// Do any local configuration here\n//\n \n// Consider adding the 1918 zones here, if they are not used in your\n// organization\n//include \"/etc/bind/zones.rfc1918\";\n\nacl \"internals\" {\n  10.0.0.0/8;\n  192.168.0.0/16;\n  172.16.0.0/12;\n};\n"}` | Any extra files that should go into `/etc/bind/` |
| extraFiles."named.conf.local" | string | `"//\n// Do any local configuration here\n//\n \n// Consider adding the 1918 zones here, if they are not used in your\n// organization\n//include \"/etc/bind/zones.rfc1918\";\n\nacl \"internals\" {\n  10.0.0.0/8;\n  192.168.0.0/16;\n  172.16.0.0/12;\n};\n"` | Any additional settings for `named.conf.local`; the ACL "internals" MUST remain defined, as it is used to give "AXFR" zone privileges (zone transfer) |
| image | string | `"ubuntu/bind9:9.16-20.04_beta"` | The image to use |
| imagePullSecrets | string | `nil` | The name of the registry secret to use |
| keys | list | `[{"algo":"hmac-sha256","name":"k8s-external-dns","secret":null}]` | List of TSIG keys for dynamic updates. Generate keys in BIND with this command: `tsig-keygen -a hmac-sha256 k8s-external-dns`` |
| keys[0].algo | string | `"hmac-sha256"` | The key algo; defaults to "hmac-sha256" |
| keys[0].name | string | `"k8s-external-dns"` | The name of the key |
| keys[0].secret | string | `nil` | The TSIG secret for this key |
| persistence.enabled | bool | `true` | Set to `true` to enable persistance for zone files |
| persistence.volume | object | `{"accessModes":["ReadWriteOnce"],"resources":{"requests":{"storage":"100M"}}}` | The data for the `PersistentVolumeClaim` for state storage. Typically you'll want to add at least a storageClassName |
| service | object | `{"annotations":{}}` | Service settings |
| service.annotations | object | `{}` | object Annotations to add to the service |
| zones | list | `[{"keys":["k8s-external-dns"],"records":"- \"frosty IN A 192.168.42.1\"\n- \"leo IN A 192.168.42.23\"\n","zone":"k8s.lab"}]` | list DNS zones (domains). |
| zones[0].keys | list | `["k8s-external-dns"]` | list(string) The names of keys authorized to update the zone |
| zones[0].records | string | `"- \"frosty IN A 192.168.42.1\"\n- \"leo IN A 192.168.42.23\"\n"` | list(string) Any extra records you want to add for the zone. E.g. `frosty IN A 192.168.42.1`. One record per list entry. |
| zones[0].zone | string | `"k8s.lab"` | zone name |