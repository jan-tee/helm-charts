kubectx k3s-demo
kubectl create namespace external-dns
helm upgrade --install --namespace external-dns ^
  my-dns . ^
  --set service.annotations."metallb\.universe\.tf/loadBalancerIPs"="10.41.0.107"