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


# ingress niginx  helm releaset terraform

# resource "helm_release" "ingress_nginx" {
#   name       = "ingress-nginx"
#   repository = "https://kubernetes.github.io/ingress-nginx"
#   chart      = "ingress-nginx"
#   namespace  = "ingress-nginx"
#   create_namespace = true
#   values = [
#     yamlencode({
#       controller = {
#         nodeSelector = {
#           "ingress-controller" = "True"  # Adjust the key-value pair as needed
#         }
#       }
#     })
#   ]
# }