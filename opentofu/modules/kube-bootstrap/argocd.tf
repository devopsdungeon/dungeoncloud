resource "helm_release" "argocd" {
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  version          = "7.7.13"
  namespace        = "argocd"
  create_namespace = true
  values = [
    "${file("${path.module}/argocd/values.yaml")}"
  ]
}
