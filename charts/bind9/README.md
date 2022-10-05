# bind9 helm chart

This is a simple helm chart to deploy a Ubuntu-based BIND9 DNS server
container that can self-host DNS zones that accept RFC2136 dynamic updates
in Kubernetes. This is especially useful when deploying on-prem clusters
for e.g. lab settings, such as k3s.

To deploy, generate a TSIG key to use for dynamic updates:

```
tsig-keygen -a hmac-sha256 k8s-external-dns
```

Then, deploy:

```bash
helm repo add tietze.io https://charts.tietze.io
helm upgrade --install --namespace external-dns \
  authoritative-dns tietze.io/bind9 \
  --set service.annotations."metallb\.universe\.tf/loadBalancerIPs"="<IP for MetalLB>" \
  --set service.annotations."metallb\.universe\.tf/allow-shared-ip"="<key to share IP for TCP/UDP DNS in MetalLB>" \
  --set keys.k8s-external-dns.secret="<TSIG secret>"
```