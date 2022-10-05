kubectx bart
kubectl create namespace external-dns
helm upgrade --install --namespace external-dns ^
  authoritative-dns . ^
  --set service.annotations."metallb\.universe\.tf/loadBalancerIPs"="192.168.42.230" ^
  --set service.annotations."metallb\.universe\.tf/allow-shared-ip"="main-ip" ^
  --set keys.k8s-external-dns.secret="XFf2PPo0p4HLdkOlnTT4KKQl01apR3BXPaLBhtSY6H8="
@rem   --dry-run --debug