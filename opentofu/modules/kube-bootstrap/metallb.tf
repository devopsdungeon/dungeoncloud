resource "helm_release" "metallb" {
  name             = "metallb"
  repository       = "https://metallb.github.io/metallb"
  chart            = "metallb"
  version          = "0.14.9"
  namespace        = "metallb-system"
  create_namespace = true
}

resource "kubectl_manifest" "ipaddresspool_metallb_system_pool" {
  depends_on = [helm_release.metallb]
  yaml_body  = <<YAML
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
  name: system-pool-1
  namespace: metallb-system
spec:
  addresses:
  - 10.123.1.100-10.123.1.149
YAML
}

resource "kubectl_manifest" "l2advertisement_metallb_system" {
  depends_on = [kubectl_manifest.ipaddresspool_metallb_system_pool]
  yaml_body  = <<YAML
apiVersion: metallb.io/v1beta1
kind: L2Advertisement
metadata:
  name: l2adv-rancher
  namespace: metallb-system
spec:
  ipAddressPools:
  - system-pool-1
YAML
}
