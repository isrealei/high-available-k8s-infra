resource "helm_release" "cilium" {
  name       = "cilium"
  repository = "https://helm.cilium.io/"
  chart      = "cilium"
  version    = "1.16.0"
  namespace  = "kube-system"
  set {
    name  = "ipam.operator.clusterPoolIPv4PodCIDRList"
    value = "172.16.0.0/12"
  }
}
